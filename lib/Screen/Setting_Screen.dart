import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_screen.dart';
import '../services/auth_service.dart';
import 'Business_profile_screen.dart';
import 'SubscriptionFeatureScreen.dart';

class Setting_Screen extends StatefulWidget {
  const Setting_Screen({super.key});

  @override
  State<Setting_Screen> createState() => _Setting_ScreenState();
}

class _Setting_ScreenState extends State<Setting_Screen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          title: Row(
            children: [
              Image.asset("assets/Images/re2.png", height: 40),
              const SizedBox(width: 30),
              const Spacer(),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF6B00),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 32),
                  elevation: 0,
                ),
                icon: const Icon(Icons.logout, size: 18, color: Colors.white),
                label: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                onPressed: () {
                  _showLogoutDialog(context, _signOut);
                },
              ),
            ],
          ),
        ),


      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ------------ PROFILE TITLE ------------
            const Text(
              "Profile",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // ------------ PROFILE CARD ------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.20),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Color(0xFFFF6B00),
                        child: const Text(
                          "K",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("Kevinmanvar27",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 6),
                            Text("kevinmanvar27@gmail.com",
                                style: TextStyle(fontSize: 14, color: Colors.black54)),
                            SizedBox(height: 6),
                            Text("No restaurant data available",
                                style: TextStyle(fontSize: 13, color: Colors.black45)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                  const Divider(thickness: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Business_profile_screen()));
                    },
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(
                        color: Color(0xFFFF6B00),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ------------ SUBSCRIPTION TITLE ------------
            const Text(
              "Subscription",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

// ------------ SUBSCRIPTION CARD ------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.20),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "No Active Subscription",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),

                  const Text(
                    "Subscribe to unlock premium features",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 14),
                  const Divider(thickness: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>SubscriptionFeatureScreen()));
                    },
                    child: const Text(
                      "View Subscription Plans",
                      style: TextStyle(
                        color: Color(0xFFFF6B00),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),
                  const Text(
                    "Choose a plan to unlock premium features",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),


            const SizedBox(height: 25),

// ------------ ABOUT TITLE ------------
            const Text(
              "About",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

// ------------ ABOUT CARD ------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.20),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: const Text("Version", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text("1.0.0", style: TextStyle(color: Colors.black54)),
                  ),

                  const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: const Text("Privacy Policy", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text("View our privacy policy",
                        style: TextStyle(color: Colors.black54)),
                    onTap: () {

                    },
                  ),

                  const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: const Text("Terms of Service", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text("View terms and conditions",
                        style: TextStyle(color: Colors.black54)),
                    onTap: () {

                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

// ------------ FOOTER TEXT ------------
            Center(
              child: Column(
                children: const [
                  Text("Restaurant User Management App",
                      style: TextStyle(fontSize: 13, color: Colors.black54)),
                  SizedBox(height: 4),
                  Text("Made with ❤️ for restaurant management",
                      style: TextStyle(fontSize: 13, color: Colors.black45)),
                ],
              ),
            ),


          ],
        ),
      ),

    );
  }

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

