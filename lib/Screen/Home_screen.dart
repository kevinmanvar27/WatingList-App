import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:waiting_list2/Screen/waiting_list_screen.dart';
import '../Api_Model/Restaurent/All_Restaurant.dart';
import '../Api_Model/Restaurent_users/restaurant_model.dart';
import '../Appbar.dart';
import 'auth_screen.dart';
import '../services/auth_service.dart';
import 'Setting_Screen.dart';
import 'Business_profile_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/restaurant_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../widgets/main_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  final int showHomePage;
  const HomeScreen({super.key, required UniqueKey refreshKey, this.showHomePage = 1});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool _isDisposed = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isUserLoggedIn = false;
  List<Datum>? _cachedRestaurants;
  List<Datum>? _filteredRestaurants;
  String selectedLocation = "Fetching...";
  String? currentCity;
  late int selectedIndex;
  final TextEditingController searchCtrl = TextEditingController();
  
  Position? _currentUserPosition; // Added to store current user position

  int operationalStatus = 1;
  bool isLoadingStatus = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Set initial selected index based on showHomePage flag
    // Always start at index 0 (which will be Home when shown, or Waiting List when hidden)
    selectedIndex = 0;
    _initConnectivity();
    _checkUserLoginStatus();
    _getCurrentLocation();
    _fetchRestaurantsOnce();
    _startPeriodicRefresh();
    searchCtrl.addListener(_onSearchChanged);
  }

  Future<void> _checkUserLoginStatus() async {
    final sp = await SharedPreferences.getInstance();
    final authToken = sp.getString('auth_token');

    if (mounted) {
      setState(() {
        _isUserLoggedIn = authToken != null && authToken.isNotEmpty;
      });

      if (_isUserLoggedIn) {
        _fetchOperationalStatus();
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            selectedLocation = "Gujarat";
            currentCity = null;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          selectedLocation = "Gujarat";
          currentCity = null;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Store the current user position
      _currentUserPosition = position;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks[0];
        String city = place.locality ?? place.subAdministrativeArea ?? "Gujarat";

        setState(() {
          currentCity = city;
          selectedLocation = city;
        });

        _applyFilters();
      }
    } catch (e) {
      //print("Error getting location: $e");
      if (mounted) {
        setState(() {
          selectedLocation = "Gujarat";
          currentCity = null;
        });
      }
    }
  }

  Future<void> _initConnectivity() async {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (!_isDisposed && result.isNotEmpty && result.first != ConnectivityResult.none) {
        setState(() {});
      }
    });
  }

  Future<void> _fetchRestaurantsOnce() async {
    if (_cachedRestaurants == null && !_isDisposed) {
      final restaurants = await fetchRestaurants();
      if (mounted) {
        setState(() {
          _cachedRestaurants = restaurants;
          _applyFilters();
        });
      }
    }
  }

  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(minutes: 3), (timer) {
      if (!_isDisposed) {
        _fetchRestaurantsOnce();
      }
    });
  }

  Future<List<Datum>> fetchRestaurants() async {
    if (_cachedRestaurants != null) {
      return _cachedRestaurants!;
    }

    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        return [];
      }

      List<Datum> allRestaurants = [];
      int currentPage = 1;
      int lastPage = 1;

      // Fetch all pages
      while (currentPage <= lastPage) {
        final response = await http.get(
          Uri.parse("https://waitinglist.rektech.work/api/restaurants/public?page=$currentPage"),
        );

        if (_isDisposed) return [];

        if (response.statusCode == 200) {
          final allRestaurant = allRestaurantFromJson(response.body);

          // Add restaurants from this page
          allRestaurants.addAll(allRestaurant.data.data);

          // Get total pages
          lastPage = allRestaurant.data.lastPage;
          currentPage++;

          // print("📄 Fetched page $currentPage-1 of $lastPage - Total restaurants: ${allRestaurants.length}");
        } else {
          throw Exception("Failed to load restaurants: ${response.statusCode}");
        }
      }

      if (allRestaurants.isEmpty) {
        return [];
      }

      if (mounted) {
        setState(() {
          _cachedRestaurants = allRestaurants;
        });
      }

      // print("✅ Total restaurants fetched: ${allRestaurants.length}");
      return allRestaurants;
    } catch (e) {
      // print("Error fetching restaurants: $e");
      return [];
    }
  }


  Future<void> _fetchOperationalStatus() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final authToken = sp.getString('auth_token');

      if (authToken == null) return;

      final response = await http.get(
        Uri.parse("https://waitinglist.rektech.work/api/restaurants/my-restaurant/toggle-status"),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final data = json.decode(response.body);
        setState(() {
          operationalStatus = data['data']['operational_status'] ?? 1;
        });
      }
    } catch (e) {
      // print("Error fetching operational status: $e");
    }
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    if (_cachedRestaurants == null) return;

    List<Datum> filtered = _cachedRestaurants!;

    // First, filter by city
    if (currentCity != null && currentCity!.isNotEmpty && currentCity != "Fetching...") {
      final String cityQuery = currentCity!.toLowerCase();
      filtered = filtered.where((restaurant) {
        final String city = (restaurant.city ?? "").toLowerCase();
        final String location = (restaurant.location ?? "").toLowerCase();
        final String address = (restaurant.fullAddress ?? "").toLowerCase();
        return city.contains(cityQuery) || location.contains(cityQuery) || address.contains(cityQuery);
      }).toList();
    }

    // Then, apply open/close visibility rules
    filtered = filtered.where((restaurant) {
      final bool isOpen = restaurant.operationalStatus == 1;
      final int waitingCount = restaurant.currentWaitingCount ?? 0;

      // Rule 1: If the restaurant is open, always show it.
      if (isOpen) {
        return true;
      }

      // Rule 2: If the restaurant is closed, only show it if there are people waiting.
      if (!isOpen && waitingCount > 0) {
        return true;
      }

      // Otherwise, hide the restaurant.
      return false;
    }).toList();

    // City filter applied above

    // Apply search filter
    String searchQuery = searchCtrl.text.toLowerCase().trim();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((restaurant) {
        String name = restaurant.name ?? "";
        String city = restaurant.city ?? "";
        String location = restaurant.location ?? "";
        String address = restaurant.fullAddress ?? "";

        return name.toLowerCase().contains(searchQuery) ||
            city.toLowerCase().contains(searchQuery) ||
            location.toLowerCase().contains(searchQuery) ||
            address.toLowerCase().contains(searchQuery);
      }).toList();
    }

    setState(() {
      _filteredRestaurants = filtered;
    });
  }

  Future<void> _callRestaurant(String? contactNumber) async {
    if (contactNumber == null || contactNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No contact number available')),
      );
      return;
    }

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: contactNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch phone call')),
        );
      }
    } catch (e) {
      // print("Error launching call: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _connectivitySubscription.cancel();
    _refreshTimer?.cancel();
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();

    Future<void> _signOut() async {
      await _auth.signOut();
      try {
        final google = GoogleSignIn();
        await google.signOut();
      } catch (_) {}
      final sp = await SharedPreferences.getInstance();
      await sp.remove('user_pin');
      await sp.remove('auth_token');
      await sp.remove('user_id');
      await sp.remove('user_name');
      await sp.remove('user_email');
      await sp.remove('user_has_pin');
      await sp.remove('user_is_admin');
      await sp.remove('user_profile_picture');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => AuthScreen()),
            (route) => false,
      );
    }



    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: selectedIndex == 0
          ? _buildAppBar()
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          _cachedRestaurants = null; // Clear cache
          await _fetchRestaurantsOnce();
        },
        child: IndexedStack(
          index: selectedIndex,
          children: _buildIndexedStackChildren(),
        ),
      ),
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: selectedIndex,
        isLoggedIn: _isUserLoggedIn,
        showHomePage: widget.showHomePage,
        onHomeTap: widget.showHomePage == 1 
          ? () => setState(() => selectedIndex = 0)
          : null, // Home tap only available when home is shown
        onWaitingTap: () => setState(() => selectedIndex = (widget.showHomePage == 1) ? 1 : 0),
        onSettingsTap: () => setState(() => selectedIndex = (widget.showHomePage == 1) ? 2 : 1),
        onLogoutTap: () {
          _showLogoutDialog(context, _signOut);
        },
        onLoginTap: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => AuthScreen()),
                (route) => false,
          );
        },
      ),
    );
  }

  PreferredSizeWidget? _buildAppBar() {
    // If user is logged in, show DynamicAppBar (with Open/Close button)
    if (_isUserLoggedIn) {
      return DynamicAppBar(
        rightButtonLabel: null,
        showRightButton: true,
        onStatusChanged: (isOpen) {
          setState(() {});
        },
      );
    }

    // If user is not logged in, show simple AppBar with Login button
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      toolbarHeight: 70,
      title: Row(
        children: [
          Image.asset("assets/Images/re2.png", height: 40),
          const Spacer(),
          ElevatedButton(

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => AuthScreen()),
                    (route) => false,
              );

            },
            child: Row(
              children: [
                Icon(Icons.login,color: Colors.white,),
                SizedBox(width: 8,),
                Text(
                  "Log in restaurant ",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildIndexedStackChildren() {
    if (widget.showHomePage == 1) {
      // Show all tabs: Home, Waiting List, Settings
      return [
        _homeContent(),
        WaitingListScreen(),
        Setting_Screen(),
      ];
    } else {
      // Hide home tab: Only Waiting List, Settings
      return [
        WaitingListScreen(),
        Setting_Screen(),
      ];
    }
  }

  Widget restaurantCard(Datum model) {
    final statusRaw = model.operationalStatus.toString().toLowerCase();
    final bool isOpen = statusRaw == '1' || statusRaw == 'true' || statusRaw == 'open' || statusRaw == 'active' || statusRaw == 'yes' || statusRaw == 'enabled';
    
    // Calculate distance string
    final String distanceStr = _calculateDistance(model);
    
    return Container(
      margin: EdgeInsets.only(top: 15),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              SizedBox(
                height: 55,
                width: 55,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (model.profile == null || model.profile!.isEmpty)
                      ? Image.asset("assets/Images/app_logo.png")
                      : Image.network(
                    "https://waitinglist.rektech.work/${model.profile}",
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset("assets/Images/app_logo.png");
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 25,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: isOpen ? Colors.green.shade400 : Colors.red.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isOpen ? " Open " : "Closed",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              )

            ],
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.name ?? "Unknown",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 18, color: Colors.red),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        model.fullAddress ?? "No address",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // Show distance if available
                if (distanceStr.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.navigation, size: 16, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(
                          "$distanceStr away",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      (model.currentWaitingCount ?? 0).toString(),
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text("Waiting", style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              SizedBox(height: 5),
              IconButton(
                onPressed: isOpen ? () => _callRestaurant(model.contactNumber) : null,
                icon: Icon(Icons.call, color: Colors.green, size: 26),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _homeContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  child: TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: "Search restaurants...",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              GestureDetector(
                onTap: _getCurrentLocation,
                child: Container(
                  height: 48,
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 20),
                      SizedBox(width: 6),
                      Text(
                        selectedLocation,
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: _cachedRestaurants == null
                ? Center(child: CircularProgressIndicator())
                : _filteredRestaurants == null || _filteredRestaurants!.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("No restaurants found"),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _cachedRestaurants = null;
                      });
                      _fetchRestaurantsOnce();
                    },
                    child: Icon(Icons.refresh),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _filteredRestaurants!.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: restaurantCard(_filteredRestaurants![index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, Function signOut) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.logout, size: 30, color: Colors.red),
              ),
              const SizedBox(height: 20),
              Text(
                "Confirm Logout",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Are you sure you want to log out of your account?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text("Cancel", style: TextStyle(color: Colors.black87, fontSize: 16)),
                      onPressed: () {
                        Navigator.pop(context);
                        // Return to settings screen (index 2) when cancel is pressed
                        // setState(() {
                        //   selectedIndex = 2;
                        // });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text("Logout", style: TextStyle(color: Colors.white, fontSize: 16)),
                      onPressed: () {
                        if (context.mounted) {
                          Navigator.pop(context);
                          signOut();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method to calculate distance between two points in kilometers
  String _calculateDistance(Datum restaurant) {
    // If we don't have user's current position, return empty string
    if (_currentUserPosition == null) {
      return "";
    }
    
    // If restaurant already has coordinates, use them
    if (restaurant.latitude != null && restaurant.longitude != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        _currentUserPosition!.latitude,
        _currentUserPosition!.longitude,
        restaurant.latitude!,
        restaurant.longitude!,
      );
      
      // Print the distance for debugging
      // print('Distance to restaurant ${restaurant.name}: ${distanceInMeters} meters');
      
      // If user is very close to the restaurant (within 50 meters), print special message
      if (distanceInMeters <= 50) {
        // print('You are now in ${restaurant.name}');
      }
      
      // Convert to kilometers or meters based on distance
      if (distanceInMeters >= 1000) {
        double distanceInKm = distanceInMeters / 1000;
        return "${distanceInKm.toStringAsFixed(1)} km";
      } else {
        return "${distanceInMeters.round()} m";
      }
    }
    
    // If restaurant doesn't have coordinates, geocode the address
    if ((restaurant.latitude == null || restaurant.longitude == null) && 
        (restaurant.fullAddress != null || restaurant.addressLine1 != null)) {
      
      // Create address string
      String address = restaurant.fullAddress ?? 
                      "${restaurant.addressLine1 ?? ''}, ${restaurant.city ?? ''}, ${restaurant.state ?? ''}";
      
      // Geocode the address (this should be done asynchronously)
      _geocodeAndCalculateDistance(restaurant, address);
      return "Calculating..."; // Show temporary message
    }
    
    // If restaurant doesn't have coordinates, we can't calculate distance
    // print('No coordinates available for restaurant ${restaurant.name}');
    return "";
  }
  
  // Method to geocode restaurant address and update restaurant coordinates
  Future<void> _geocodeAndCalculateDistance(Datum restaurant, String address) async {
    try {
      // print('Geocoding address for restaurant ${restaurant.name}: $address');
      
      // Geocode the address
      List<Location> locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        Location location = locations.first;
        // print('Geocoded coordinates for ${restaurant.name}: ${location.latitude}, ${location.longitude}');
        
        // Update the restaurant object with the geocoded coordinates
        restaurant.latitude = location.latitude;
        restaurant.longitude = location.longitude;
        
        // Trigger a rebuild to show the distance
        if (mounted) {
          setState(() {
            // This will cause the UI to rebuild with the new distance
          });
        }
      } else {
        // print('Could not geocode address for restaurant ${restaurant.name}');
      }
    } catch (e) {
      // print('Error geocoding address for restaurant ${restaurant.name}: $e');
    }
  }
}