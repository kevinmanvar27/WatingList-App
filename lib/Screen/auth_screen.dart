import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:waiting_list2/Screen/pin_setup_screen.dart';
import '../services/auth_service.dart';
import 'Home_screen.dart';
import 'pin_login_screen.dart';
import 'waiting_list_screen.dart';
import '../services/restaurant_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _auth = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: "466547409106-30coupprt0s68o03t6956ert5cs7mc94.apps.googleusercontent.com",
    scopes: ['email', 'profile'],
  );
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Initialize the auth service
    _auth.init();
  }


  Future<void> _handleGoogleSignIn() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        if (googleAuth.idToken != null && googleAuth.accessToken != null) {
          final res = await _auth.signInWithGoogle(googleAuth.idToken ?? "", googleAuth.accessToken ?? "");

          // print("Debug - res: $res");

          if (res != null) {
            if (mounted) {
              if (res.hasPin == true) {
                final hasRestaurant = await RestaurantService.userHasRestaurant();
                if (hasRestaurant) {
                  // Check show home page flag
                  final sp = await SharedPreferences.getInstance();
                  final showHomePage = sp.getInt('show_home_page') ?? 1;
                  
                  if (showHomePage == 0) {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => WaitingListScreen())
                    );
                  } else {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => HomeScreen(refreshKey: UniqueKey()))
                    );
                  }
                } else {
                  // Also check show home page flag for users without restaurant
                  final sp = await SharedPreferences.getInstance();
                  final showHomePage = sp.getInt('show_home_page') ?? 1;
                  
                  if (showHomePage == 0) {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => WaitingListScreen())
                    );
                  } else {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => HomeScreen(refreshKey: UniqueKey()))
                    );
                  }
                }
              } else {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => PinSetupScreen())
                );
              }
            }
          } else {
            if (mounted) {
              // print("2");
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Backend authentication failed')));
            }
          }
        } else {
          // One of the tokens is null
          if (mounted) {
            // print("3");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Google returned null tokens. Please checks your Google Cloud Console config.')),
            );
          }
        }
        // --- FIX END ---

      } else {
        // User canceled the sign in
        if (mounted) {
          // print("4");
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Google sign in was canceled')));
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        // print("5");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sign in failed: ${e.toString()}')));
      }
      // print("Error details: $e");
    } catch (e) {
      if (mounted) {
        // print("6");
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sign in failed: $e')));
      }
      // print("Error details: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB), // Light smooth background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  padding: EdgeInsets.all(35),
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
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  )
              ),

              SizedBox(height: 20),

              // Title
              Text(
                'Welcome!',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              Text(
                'Sign in with your Google account to continue',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),

              SizedBox(height: 40),

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
                onPressed: _handleGoogleSignIn,
                child: Text(
                  'Sign in with Google',
                  style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10,),
              TextButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>PinLoginScreen()));
                },
                child: Text("Login With PIN",style: TextStyle(color: Color(0xFFFF6B00),fontSize: 18),),
              )
            ],
          ),
        ),
      ),
    );
  }
}