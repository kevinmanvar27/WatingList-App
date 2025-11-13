import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waiting_list/Screen/pin_login_screen.dart';
import '../services/auth_service.dart';
import 'Home_screen.dart';
import 'pin_setup_screen.dart';
import 'Business_profile_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _auth = AuthService();
  bool _loading = false;

  Future<void> _googleSignIn() async {
    setState(() => _loading = true);

    try {
      final res = await _auth.signInWithGoogle();

      if (res != null) {
        final user = res['data']['user'];
        final token = res['data']['token'];

        String email = user['email'];

        final sp = await SharedPreferences.getInstance();

        // 1) Clear old session keys (prevents using stale token)
        await sp.remove('token');
        await sp.remove('user_name');
        await sp.remove('user_email');
        await sp.remove('restaurant_open_status');
        await sp.remove('current_restaurant_id');
        await sp.remove('profile_image');
        await sp.remove('is_logged_in');
        await sp.remove('user_id');

        // 2) Persist new session atomically
        await sp.setString('token', token);
        await sp.setBool('is_logged_in', true);
        await sp.setString('user_email', email);
        await sp.setString('user_name', user['name'] ?? "");
        if (user['id'] != null) {
          await sp.setInt('user_id', user['id']);
        }

        if (!mounted) return;

        if(user['has_pin'] == false) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => PinSetupScreen(email: email)),
          );
        } else {
          // Post-auth routing: check profile -> subscription -> home
          _navigateBasedOnStatus();
        }

      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign in cancelled')),
        );
      }

    } catch (e) {
      print("signin failed:---- $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign-in failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB), // Light smooth background
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(flex: 1),
                    Container(
                        padding: EdgeInsets.all(screenWidth * 0.08),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              spreadRadius: 2,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/Images/re.png',
                          width: screenWidth * 0.25,
                          height: screenWidth * 0.25,
                          fit: BoxFit.contain,
                        )
                    ),

                    SizedBox(height: screenHeight * 0.025),

                    // Title
                    Text(
                      'Welcome!',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.bold),
                    ),

                    SizedBox(height: screenHeight * 0.015),

                    Text(
                      'Sign in with your Google account to continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: screenWidth * 0.04,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // Button
                    _loading
                        ? CircularProgressIndicator(color: Color(0xFFFF6B00))
                        : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding:
                        EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        backgroundColor: Color(0xFFFF6B00),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        'Sign in with Google',
                        style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _googleSignIn,
                    ),
                    SizedBox(height: 10,),
                    TextButton(
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>PinLoginScreen()));
                      },
                      child: Text("Login With PIN",style: TextStyle(color: Color(0xFFFF6B00),fontSize: 18),),
                    ),
                    Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateBasedOnStatus() async {
    if (!mounted) return;
    
    try {
      final restaurant = await AuthService.fetchRestaurantDetail();
      final needsProfile = (restaurant["name"] == null || (restaurant["name"] as String).trim().isEmpty);

      if (needsProfile) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Business_profile_screen()),
        );
        return;
      }

      final sub = await AuthService.fetchSubscriptionStatus();
      final hasActiveSubscription = sub != null && (sub["is_active"] == true);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => hasActiveSubscription ? HomeScreen() : HomeScreen(initialIndex: 2)),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    }
  }
}