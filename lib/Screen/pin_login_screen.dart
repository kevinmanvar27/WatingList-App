import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waiting_list2/Screen/waiting_list_screen.dart';
import 'Home_screen.dart';
import 'auth_screen.dart';
import '../services/auth_service.dart';

class PinLoginScreen extends StatefulWidget {
  @override
  _PinLoginScreenState createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final _pinCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final sp = await SharedPreferences.getInstance();
    final userEmail = sp.getString('user_email');
    if (userEmail != null && mounted) {
      setState(() {
        _emailCtrl.text = userEmail;
      });
    }
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pin = _pinCtrl.text.trim();

    if (email.isEmpty || pin.isEmpty) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Email and PIN are required';
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    
    try {
      final user = await _authService.loginWithPin(email, pin);
      if (user != null && mounted) {
        // Check show home page flag
        final sp = await SharedPreferences.getInstance();
        final showHomePage = sp.getInt('show_home_page') ?? 1;
        
        if (showHomePage == 0) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => WaitingListScreen()));
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomeScreen(refreshKey: UniqueKey())));
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Invalid email or PIN';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Login failed. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    _emailCtrl.dispose();
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
            
            if (_errorMessage != null)
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),

            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Enter your email",
                prefixIcon: Icon(Icons.email_outlined, color: Color(0xFFFF6B00)),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
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
                    borderSide: BorderSide(color: Color(0xFFFF6B00)),
                    borderRadius: BorderRadius.circular(12)),
              ),
              style: TextStyle(letterSpacing: 10),
              onSubmitted: (_) => _login(),
            ),

            SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF6B00),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                ),
                child: _isLoading 
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
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
                style: TextStyle(color: Color(0xFFFF6B00),fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}