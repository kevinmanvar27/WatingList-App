import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waiting_list/Screen/waiting_list_screen.dart';
import 'auth_screen.dart';
import '../services/auth_service.dart';
import 'Setting_Screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedLocation = "Gujarat";
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();

    Future<void> _signOut() async {
      await _auth.signOut();
      final sp = await SharedPreferences.getInstance();
      await sp.remove('user_pin');
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
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        title: Row(
          children: [
            Image.asset("assets/Images/re2.png", height: 40),
            const SizedBox(width: 100),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: StadiumBorder(),
                elevation: 0,
              ),
              icon: Icon(Icons.add, color: Colors.black,size: 20,),
              label: Text("Add Person", style: TextStyle(color: Color(0xFFF9FAFB),fontWeight: FontWeight.bold)),
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              _NavItem(
                icon: Icons.home,
                label: "Home",
                bgColor: selectedIndex == 0 ? Color(0xFFFFF0E6) : Colors.white,
                textColor: selectedIndex == 0 ? Color(0xFFFF6B00) : Colors.black,
                onTap: () => setState(() => selectedIndex = 0),
              ),

              _NavItem(
                icon: Icons.list_alt,
                label: "Waiting List",
                bgColor: selectedIndex == 1 ? Color(0xFFFFF0E6) : Colors.white,
                textColor: selectedIndex == 1 ? Color(0xFFFF6B00) : Colors.black,
                onTap: () => setState(() => selectedIndex = 1),
              ),

              _NavItem(
                icon: Icons.settings,
                label: "Settings",
                bgColor: selectedIndex == 2 ? Color(0xFFFFF0E6) : Colors.white,
                textColor: selectedIndex == 2 ? Color(0xFFFF6B00) : Colors.black,
                onTap: () => setState(() => selectedIndex = 2),
              ),

              _NavItem(
                icon: Icons.logout,
                label: "Logout",
                bgColor: selectedIndex == 3 ? Color(0xFFFFF0E6) : Color(0xFFFFE3E3),
                textColor: Color(0xFFD9534F),
                onTap: () {
                  setState(() => selectedIndex = 3);
                  _showLogoutDialog(context, _signOut);
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget restaurantCard() {
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

          /// IMAGE + OPEN BUTTON BELOW
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  "assets/Images/app_logo.png",
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

          /// TEXT INFORMATION
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "K-win kitchen",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),

                Row(
                  children: [
                    Icon(Icons.location_on, size: 18, color: Colors.red),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Shivallay Complex, Rajkot, Gujarat",
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

          /// WAITING + CALL (ONLY ICON BUTTONS)
          Column(
            children: [

              /// WAITING (Icon + Count Container)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "0",
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Text("Waitng",style: TextStyle(fontSize: 10),)
                  ],
                ),
              ),


              SizedBox(height: 5),

              /// CALL (Icon Only)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade50
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.call, color: Colors.green, size: 26),
                ),
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

              PopupMenuButton<String>(
                color: Colors.white, // dropdown background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                onSelected: (value) {
                  setState(() {
                    selectedLocation = value;
                  });
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: "Gujarat",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Gujarat"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: "Maharashtra",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Maharashtra"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: "Rajasthan",
                    child: Text("Rajasthan"),
                  ),
                ],
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

          /// RESTAURANT CARD LIST
          Expanded(
            child: ListView(
              children: [
                restaurantCard(),
                // If more restaurants, duplicate or make dynamic later
              ],
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
                    "Add New User",
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
                        child: Text("Add User", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(fontSize: 14, color: textColor)),
          ],
        ),
      ),
    );
  }
}
