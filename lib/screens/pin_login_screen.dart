import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Screen/Home_screen.dart';
import 'auth_screen.dart';

class PinLoginScreen extends StatefulWidget {
  @override
  _PinLoginScreenState createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final _pinCtrl = TextEditingController();
  String? _storedPin;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _storedPin = sp.getString('user_pin');
    });
  }

  Future<void> _login() async {
    final pin = _pinCtrl.text.trim();
    if (_storedPin == null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => AuthScreen()));
      return;
    }
    if (pin == _storedPin) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Incorrect PIN')));
    }
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          'Enter PIN',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFF6B00), // Clean appbar ✅
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(height: 50),

            Text(
              'Welcome Back!',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B00)
              ),
            ),

            SizedBox(height: 40),

            TextField(
              controller: _pinCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'PIN',
                counterText: '',
                prefixIcon: Icon(Icons.lock, color: Color(0xFFFF6B00)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF6B00)), // Orange border ✅
                    borderRadius: BorderRadius.circular(12)),
              ),
              style: TextStyle(letterSpacing: 10),
            ),

            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF6B00), // Orange button ✅
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => AuthScreen()));
              },
              child: Text(
                'Sign in with Google instead',
                style: TextStyle(color: Color(0xFFFF6B00)), // Orange text ✅
              ),
            ),
          ],
        ),
      ),
    );
  }
}
