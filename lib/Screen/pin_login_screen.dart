import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Home_screen.dart';
import 'auth_screen.dart';

class PinLoginScreen extends StatefulWidget {
  @override
  _PinLoginScreenState createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();

  String? storedEmail;
  String? storedPin;
  bool _isPinHidden = true;

  @override
  void initState() {
    super.initState();
    _loadStoredData();
  }

  Future<void> _loadStoredData() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      storedEmail = sp.getString('user_email');
      storedPin = sp.getString('user_pin');

      if (storedEmail != null) {
        _emailCtrl.text = storedEmail!;
      }
    });
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pin = _pinCtrl.text.trim();

    if (email.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter Email & PIN")),
      );
      return;
    }

    final url = Uri.parse("https://waitinglist.rektech.work/api/auth/pin-login");

    try {
      final response = await http.post(
        url,
        body: {
          "email": email,
          "pin": pin,
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['message'] == "PIN authentication successful") {
        final sp = await SharedPreferences.getInstance();

        await sp.setBool("is_logged_in", true);
        await sp.setString("user_email", email);
        await sp.setString("user_pin", pin);
        
        // ✅ Save token and user data from API response
        if (data['data'] != null) {
          final user = data['data']['user'];
          final token = data['data']['token'];
          
          await sp.setString("token", token ?? "");
          await sp.setString("user_name", user["name"] ?? "");
          
          print("✅ PIN Login - Token Saved: $token");
          print("✅ PIN Login - User Name: ${user["name"]}");
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Invalid Email or PIN")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong!")),
      );
    }
  }


  @override
  void dispose() {
    _emailCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Login with PIN',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Color(0xFFFF6B00),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  )),
              SizedBox(height: 20),

              TextField(
                controller: _emailCtrl,
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Email',
                  counterText: '',
                  prefixIcon: Icon(Icons.email, color: Color(0xFFFF6B00)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 20),
        
              TextField(
                obscureText: _isPinHidden,
                controller: _pinCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: 'PIN',
                  counterText: '',
                  prefixIcon: Icon(Icons.lock, color: Color(0xFFFF6B00)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPinHidden ? Icons.visibility_off : Icons.visibility,
                      color: Color(0xFFFF6B00),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPinHidden = !_isPinHidden;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 30),
        
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF6B00),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Login',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color:Colors.white)),
                ),
              ),
        
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => AuthScreen()));
                },
                child: Text('Sign in with Google instead',
                    style: TextStyle(color: Color(0xFFFF6B00), fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}