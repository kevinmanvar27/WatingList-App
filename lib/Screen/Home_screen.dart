import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waiting_list/Screen/pin_login_screen.dart';
import 'package:waiting_list/Screen/waiting_list_screen.dart';
import '../Api_Model/restaurant_model.dart';
import '../Api_Model/restaurant_user_model.dart';
import '../services/add_person_service.dart';
import 'auth_screen.dart';
import '../services/auth_service.dart';
import 'Setting_Screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchText = "";
  TextEditingController searchCtrl = TextEditingController();
  final GlobalKey<WaitingListScreenState> waitingListKey = GlobalKey<WaitingListScreenState>();

  List<RestaurantUser> users = [];
  void loadUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("SAVED TOKEN: ${prefs.getString("token")}");
    users = await ApiService.fetchUsers();
    setState(() {});
  }

  bool isLoggedIn = false;
  String appName = "Waitinglist";
  String appLogo = "";
  String selectedLocation = "";
  bool showAddress = false;
  bool isRestaurantOpen = false;
  int? currentRestaurantId; // ✅ Store current restaurant ID

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    _loadBranding();
    _loadRestaurantStatus();
    _loadCurrentRestaurantId(); // ✅ Load current restaurant ID
    _getLocation();
    checkLoginStatus();
    loadUsers();
  }

  void refreshUsers() {
    loadUsers();
  }

  void refreshRestaurantStatus() {
    _loadRestaurantStatus();
  }

  Future<void> _loadRestaurantStatus() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      isRestaurantOpen = sp.getBool("restaurant_open_status") ?? false;
    });
  }

  Future<void> _loadCurrentRestaurantId() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final token = sp.getString("token");

      if (token != null && token.isNotEmpty) {
        final restaurantData = await AuthService.fetchRestaurantDetail();
        setState(() {
          currentRestaurantId = restaurantData["id"];
        });
        await sp.setInt("current_restaurant_id", currentRestaurantId!);
      }
    } catch (e) {
      print("Error loading current restaurant ID: $e");
    }
  }

  Future<void> checkLoginStatus() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = sp.getBool("is_logged_in") ?? false;
    });
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks[0];

    String fullAddress = "${place.locality}, ${place.administrativeArea}";

    setState(() {
      selectedLocation = fullAddress;
      showAddress = true;
    });
  }


  Future<void> _loadBranding() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      appName = sp.getString("app_name") ?? "Waitinglist";
      appLogo = sp.getString("app_logo") ?? "";
    });
  }

  Future<List<RestaurantModel>> fetchRestaurants({String search = "", String location = ""}) async {
    final response = await http.get(
      Uri.parse("https://waitinglist.rektech.work/api/restaurants/public?search=$search"),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      List data = body["data"]["data"];
      List<RestaurantModel> restaurants = data.map((e) => RestaurantModel.fromJson(e)).toList();

      // ✅ Filter by location if selected
      if (location.isNotEmpty) {
        restaurants = restaurants.where((restaurant) {
          // Check if restaurant location contains selected city/state
          final restaurantLocation = restaurant.location.toLowerCase();
          final restaurantAddress = restaurant.fullAddress.toLowerCase();
          final selectedLoc = location.toLowerCase();

          return restaurantLocation.contains(selectedLoc) ||
                 restaurantAddress.contains(selectedLoc);
        }).toList();
      }

      return restaurants;
    } else {
      throw Exception("Failed to load restaurants");
    }
  }


  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();

    Future<void> _signOut() async {
      await _auth.signOut();
      final sp = await SharedPreferences.getInstance();
      await sp.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: Duration(seconds: 2),
            content: Text("Logout Successfully ✅",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => PinLoginScreen()),
            (route) => false,
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: selectedIndex == 0
          ? AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Image.asset("assets/Images/re2.png", height: 40),
            /*Image.network(
              appLogo,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Image.asset("assets/Images/re2.png", height: 40),
            ),*/
            const SizedBox(width: 30),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF6F00),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 32),
                elevation: 0,
              ),
              child: Text(
                isLoggedIn ? "Add Person" : "Login",
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              onPressed: () async {
                if (!isLoggedIn) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AuthScreen()),
                  ).then((value) => checkLoginStatus());
                  return;
                }

                if (!isRestaurantOpen) {
                  bool? proceed = await showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, size: 26, color: Color(0xFFFF6F00)),
                                SizedBox(width: 10),
                                Text(
                                  "Restaurant Closed",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Text(
                              "Your restaurant is currently closed.\nDo you still want to add a person?",
                              style: TextStyle(fontSize: 16, height: 1.4),
                            ),
                            SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: Text("Cancel", style: TextStyle(color: Colors.black87)),
                                ),
                                SizedBox(width: 6),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFFF6F00),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text("Continue", style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );

                  if (proceed != true) return; // Cancel kare → kuch nahi
                }

                // Restaurant open hoy ke user OK kare → Add Dialog open
                _showAddUserDialog(context);
              },
            ),

          ],
        ),
      ) : null,

      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: IndexedStack(
          index: selectedIndex,
          children: [
            _homeContent(),
            WaitingListScreen(
              key: waitingListKey,
              onStatusChanged: refreshRestaurantStatus,
            ),
            Setting_Screen(
              isVisible: selectedIndex == 2, // ✅ Pass visibility state
              onRefreshWaitingList: () {
                waitingListKey.currentState?.refreshUsers();
              },
            ),
            SizedBox(),
          ],
        ),
      ),

      bottomNavigationBar: isLoggedIn
          ? Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _NavItem(
                icon: Icons.home,
                label: "Home",
                bgColor: selectedIndex == 0 ? Color(0xFFFFF0E6) : Colors.white,
                textColor: selectedIndex == 0 ? Color(0xFFFF6B00) : Colors.black,
                onTap: () => setState(() => selectedIndex = 0),
              ),
            ),

            Expanded(
              child: _NavItem(
                icon: Icons.list_alt,
                label: "Waiting List",
                bgColor: selectedIndex == 1 ? Color(0xFFFFF0E6) : Colors.white,
                textColor: selectedIndex == 1 ? Color(0xFFFF6B00) : Colors.black,
                onTap: () => setState(() => selectedIndex = 1),
              ),
            ),

            Expanded(
              child: _NavItem(
                icon: Icons.settings,
                label: "Settings",
                bgColor: selectedIndex == 2 ? Color(0xFFFFF0E6) : Colors.white,
                textColor: selectedIndex == 2 ? Color(0xFFFF6B00) : Colors.black,
                onTap: () => setState(() => selectedIndex = 2),
              ),
            ),

            Expanded(
              child: _NavItem(
                icon: Icons.logout,
                label: "Logout",
                bgColor: selectedIndex == 3 ? Color(0xFFFFF0E6) : Color(0xFFFFE3E3),
                textColor: Color(0xFFD9534F),
                onTap: () {
                  setState(() => selectedIndex = 3);
                  _showLogoutDialog(context, _signOut);
                },
              ),
            ),
          ],
        ),
      )
          : null,


    );
  }

  Widget restaurantCard(RestaurantModel model) {
    final bool isOpenForThis = (model.id == currentRestaurantId) ? isRestaurantOpen : model.operationalStatus;
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

          /// LEFT (Image + Button)
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  (model.profile.isEmpty || model.profile == null)
                      ? "https://cdn-icons-png.flaticon.com/128/562/562678.png"
                      : "https://waitinglist.rektech.work${model.profile}",
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 25,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOpenForThis ? Colors.green : Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isOpenForThis ? "Open" : "Closed",
                    style: TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ),

              ),
            ],
          ),

          SizedBox(width: 15),

          /// MIDDLE (Expanded text)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on, size: 18, color: Colors.red),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        model.fullAddress,
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// RIGHT (Waiting + Call)
          SizedBox(width: 10), // ✅ extra spacing
          Column(
            mainAxisSize: MainAxisSize.min,
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
                      model.waiting.toString(),
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
                onPressed: () async {
                  final phone = model.contactNumber.trim();

                  if (phone.isNotEmpty) {
                    final Uri callUri = Uri(scheme: 'tel', path: phone);
                    await launchUrl(callUri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Contact number not available")),
                    );
                  }
                },
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
                    onChanged: (value) {
                      setState(() {
                        searchText = value.trim(); // ✅ Search text store
                      });
                    },
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

              Expanded(
                child: InkWell(
                  onTap: () {
                    _getLocation();
                  },
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
                        Expanded(
                          child: Text(
                            selectedLocation.isEmpty ? "📍 Getting location..." : selectedLocation,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, color: Colors.black87,),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10),

          Expanded(
            child: FutureBuilder<List<RestaurantModel>>(
              future: fetchRestaurants(
                search: searchCtrl.text.trim(),
                location: selectedLocation, // ✅ Pass selected location for filtering
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Something went wrong"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No restaurants found"));
                }

                final restaurants = snapshot.data!;

                if (restaurants.isEmpty) {
                  return Center(child: Text("No restaurants found"));
                }

                // ✅ Separate current restaurant from others
                final currentRestaurant = restaurants.firstWhere(
                  (r) => r.id == currentRestaurantId,
                  orElse: () => restaurants.first,
                );

                final otherRestaurants = restaurants
                    .where((r) => r.id != currentRestaurantId)
                    .toList();

                // ✅ Filter current restaurant card visibility
                final shouldShowCurrentRestaurant =
                    (currentRestaurant.waiting > 0 && isRestaurantOpen) ||
                    !(currentRestaurant.waiting == 0 && !isRestaurantOpen);

                return ListView.builder(
                  itemCount: shouldShowCurrentRestaurant
                      ? 1 + otherRestaurants.length
                      : otherRestaurants.length,
                  itemBuilder: (context, index) {
                    if (shouldShowCurrentRestaurant && index == 0) {
                      return restaurantCard(currentRestaurant);
                    }

                    final adjustedIndex = shouldShowCurrentRestaurant ? index - 1 : index;
                    return restaurantCard(otherRestaurants[adjustedIndex]);
                  },
                );
              },
            ),
          ),


        ],
      ),
    );
  }


  void _showAddUserDialog(BuildContext context, {RestaurantUser? user}) {
    final _formKey = GlobalKey<FormState>();

    final TextEditingController mobileCtrl =
    TextEditingController(text: user?.mobile ?? "");
    final TextEditingController nameCtrl =
    TextEditingController(text: user?.username ?? "");
    final TextEditingController personsCtrl =
    TextEditingController(text: user?.personCount.toString() ?? "1");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Center(
                        child: Text(
                          user == null ? "Add New Person" : "Edit Person",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(height: 20),

                      Text("Mobile Number *", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: mobileCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Enter mobile number";
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) return "Only numbers allowed";
                          if (value.length != 10) return "Mobile must be exactly 10 digits";
                          return null;
                        },
                        onChanged: (value) async {
                          if (value.length == 10) {
                            final foundUser = await AuthService.searchUserByPhone(value.trim());

                            if (foundUser != null) {
                              setStateDialog(() {
                                nameCtrl.text = foundUser.username;
                                personsCtrl.text = foundUser.personCount.toString();
                              });
                            } else {
                              setStateDialog(() {
                                nameCtrl.clear();
                                personsCtrl.text = "1";
                              });
                            }
                          }
                        },
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: "Enter mobile number",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),

                      SizedBox(height: 12),

                      Text("Total Persons", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: personsCtrl,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) return "Enter persons count";
                          if (int.tryParse(value) == null) return "Enter valid number";
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "Enter total persons",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),

                      SizedBox(height: 12),

                      Text("Person Name *", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      TextFormField(
                        controller: nameCtrl,
                        validator: (value) =>
                        value == null || value.isEmpty ? "Enter person name" : null,
                        decoration: InputDecoration(
                          hintText: "Enter person name",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),

                      SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                side: BorderSide(color: Color(0xFFFF6B00)),
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: Text("Cancel", style: TextStyle(color: Color(0xFFFF6B00))),
                            ),
                          ),
                          SizedBox(width: 12),

                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFFF6B00),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {

                                  final personCount = personsCtrl.text.isEmpty ? "1" : personsCtrl.text;

                                  if (user == null) {
                                    await ApiService.addRestaurantUser(
                                        nameCtrl.text, mobileCtrl.text, personCount);
                                  } else {
                                    await ApiService.editUser(
                                        user.id, nameCtrl.text, mobileCtrl.text, personCount);
                                  }

                                  Navigator.pop(context);
                                  loadUsers();
                                  waitingListKey.currentState?.refreshUsers();
                                }
                              },
                              child: Text(
                                user == null ? "Add Person" : "Update",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }


  void _showLogoutDialog(BuildContext context, Function signOut) {
    showDialog(
      context: context,
      barrierDismissible: true,
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

              /// Icon Circle
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.logout, size: 30, color: Colors.red),
              ),

              const SizedBox(height: 20),

              /// Title
              Text(
                "Confirm Logout",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              /// Subtitle
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

                  /// Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text("Cancel", style: TextStyle(color: Colors.black87, fontSize: 16)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  SizedBox(width: 10),

                  /// Logout Button
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text("Logout", style: TextStyle(color: Colors.white, fontSize: 16)),
                      onPressed: () {
                        Navigator.pop(context);
                        signOut();
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

}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: textColor),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
