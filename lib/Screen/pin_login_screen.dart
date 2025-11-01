import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Home_screen.dart';
import 'auth_screen.dart';

class PinLoginScreen extends StatefulWidget {
  @override
  _PinLoginScreenState createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final _pinCtrl = TextEditingController();
  final _email = TextEditingController();
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
        automaticallyImplyLeading: false,
        title: Text(
          'Enter PIN',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFF6B00),
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(height: 30),
            Text(
              'Welcome Back!',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B00)
              ),
            ),
            SizedBox(height: 30),
            
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

            SizedBox(height: 40),

            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              maxLength: 4,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Email',
                counterText: '',
                prefixIcon: Icon(Icons.email_outlined, color: Color(0xFFFF6B00)),
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
                style: TextStyle(color: Color(0xFFFF6B00),fontSize: 18), // Orange text ✅
              ),
            ),
          ],
        ),
      ),
    );
  }
}
