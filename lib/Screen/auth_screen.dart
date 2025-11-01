import 'package:flutter/material.dart';
import 'package:waiting_list/Screen/pin_login_screen.dart';
import '../services/auth_service.dart';
import 'pin_setup_screen.dart';

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
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => PinSetupScreen()));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Google sign in cancelled')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Sign in failed: $e')));
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
