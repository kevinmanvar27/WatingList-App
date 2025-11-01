import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waiting_list/Screen/settings_screen.dart';
import 'package:waiting_list/Screen/waiting_list_screen.dart';
import '../screens/auth_screen.dart';
import '../services/auth_service.dart';
import 'App_State.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
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
            Image.asset("assets/Images/re2.png", height: 38),
            const SizedBox(width: 100),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: StadiumBorder(),
              ),
              icon: Icon(Icons.add, color: Color(0xFFF9FAFB)),
              label: Text("Add Person", style: TextStyle(color: Color(0xFFF9FAFB))),
              onPressed: () => _showAddRestaurantDialog(context),
            ),
          ],
        ),
      ) : null,

      body: IndexedStack(
        index: selectedIndex,
        children: [
          _homeContent(appState),
           //WaitingListScreen(),
          const BusinessProfileScreen(),
          SizedBox(), // for logout
        ],
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

  /// ✅ HOME TAB UI KEPT HERE
  Widget _homeContent(AppState appState) {
    final TextEditingController searchCtrl = TextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchCtrl,
                  decoration: InputDecoration(
                    hintText: "Search restaurants...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (val) => appState.searchRestaurants(val),
                ),
              ),
              const SizedBox(width: 10),
              PopupMenuButton<String>(
                onSelected: (value) => appState.setStateFilter(value),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, size: 18, color: Colors.red),
                      Text(" ${appState.selectedState}"),
                    ],
                  ),
                ),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: "Gujarat", child: Text("Gujarat")),
                  PopupMenuItem(value: "Maharashtra", child: Text("Maharashtra")),
                  PopupMenuItem(value: "Rajasthan", child: Text("Rajasthan")),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (appState.restaurants.isEmpty) ...[
            const Spacer(),
            const Text("No restaurants found",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text("Check back later for new restaurants"),
            const Spacer(),
          ]
          else
            Expanded(
              child: ListView.builder(
                itemCount: appState.restaurants.length,
                itemBuilder: (context, i) {
                  final r = appState.restaurants[i];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(r.name),
                      subtitle: Text(r.state),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WaitingListScreen(restaurant: r),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, Function signOut) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Color(0xFFD9534F)),
            SizedBox(width: 10),
            Text("Confirm Logout"),
          ],
        ),
        content: Text("Are you sure you want to logout?",
            style: TextStyle(fontSize: 16, color: Colors.black87)),
        actions: [
          TextButton(
            child: Text("Cancel", style: TextStyle(fontSize: 16, color: Color(0xFFFF6B00))),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFD9534F)),
            child: Text("Logout", style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.pop(context);
              signOut();
            },
          ),
        ],
      ),
    );
  }

  void _showAddRestaurantDialog(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Restaurant'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Restaurant name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                await appState.addRestaurant(ctrl.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
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
