import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:waiting_list/Screen/waiting_list_screen.dart';
import '../Api_Model/restaurant_model.dart';
import 'auth_screen.dart';
import '../services/auth_service.dart';
import 'Setting_Screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  String appName = "Waitinglist";
  String appLogo = "";
  String selectedLocation = "";
  bool showAddress = false;

  @override
  void initState() {
    super.initState();
    _loadBranding();
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

  Future<List<RestaurantModel>> fetchRestaurants() async {
    final response = await http.get(
      Uri.parse("https://waitinglist.rektech.work/api/restaurants/public"),
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      List data = body["data"]["data"];
      return data.map((e) => RestaurantModel.fromJson(e)).toList();
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

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => AuthScreen()),
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
                backgroundColor: Colors.green,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(0, 32),
                elevation: 0,
              ),
              child: const Text(
                "Add Person",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              onPressed: () {
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
            WaitingListScreen(),
            Setting_Screen(),
            SizedBox(),
          ],
        ),
      ),

      bottomNavigationBar: Container(
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
      ),

    );
  }

  Widget restaurantCard(RestaurantModel model) {
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
                    backgroundColor: Colors.green.shade400,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("Open", style: TextStyle(fontSize: 13, color: Colors.white)),
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
    final TextEditingController searchCtrl = TextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          const SizedBox(height: 10),

          Row(
            children: [
              // SEARCH BOX
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
                            "📍 Current Location..",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, color: Colors.black87),
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

          AnimatedSwitcher(
            duration: Duration(milliseconds: 400),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: showAddress
                ? Container(
              key: ValueKey(selectedLocation),
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedLocation,
                      style: TextStyle(fontSize: 14, color: Colors.blue.shade900),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
                : SizedBox(),
          ),


          Expanded(
            child: FutureBuilder<List<RestaurantModel>>(
              future: fetchRestaurants(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Something went wrong"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No restaurants found"));
                }

                final restaurants = snapshot.data!;

                return ListView.builder(
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    return restaurantCard(restaurants[index]);
                  },
                );
              },
            ),
          ),

        ],
      ),
    );
  }


  void _showAddUserDialog(BuildContext context) {
    final TextEditingController mobileCtrl = TextEditingController();
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController personsCtrl = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Center(
                  child: Text(
                    "Add New Person",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                Text("Mobile Number *",style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 5),
                TextField(
                  controller: mobileCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "Enter mobile number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 12),

                Text("Person Name *",style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 5),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: "Enter person name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 12),

                Text("Total Persons",style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(height: 5),
                TextField(
                  controller: personsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter total persons (optional)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 25),

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
                        child: Text("Cancel", style: TextStyle(color: Color(0xFFFF6B00),fontWeight: FontWeight.bold)),
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Add Person", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
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

