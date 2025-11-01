import 'package:flutter/material.dart';
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
              // Icon
              Icon(Icons.lock_outline, size: 100, color: Color(0xFFFF6B00)),

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
            ],
          ),
        ),
      ),
    );
  }
}
