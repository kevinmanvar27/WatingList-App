import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Home_screen.dart';
import 'package:http/http.dart' as http;
import 'Business_profile_screen.dart';
import '../services/auth_service.dart';

class PinSetupScreen extends StatefulWidget {
  final String email;

  PinSetupScreen({required this.email});

  @override
  _PinSetupScreenState createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final _pinCtrl = TextEditingController();
  final _pin2Ctrl = TextEditingController();
  final _email = TextEditingController();
  bool _saving = false;
  bool _isPinHidden = true;
  bool _isPinHiddenn = true;

  @override
  void initState() {
    super.initState();
    _email.text = widget.email;
  }

  Future<void> _savePin() async {
    final pin = _pinCtrl.text.trim();
    final pin2 = _pin2Ctrl.text.trim();

    if (pin.length != 4 || pin2.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter 4-digit PIN')),
      );
      return;
    }

    if (pin != pin2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PINs do not match')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final sp = await SharedPreferences.getInstance();
      final token = sp.getString('token'); // ✅ We saved it in AuthScreen

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Token missing. Please Sign-in again.")),
        );
        return;
      }

      final url = Uri.parse(
          "https://waitinglist.rektech.work/api/auth/set-pin?pin=$pin");

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );
      print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        // ✅ Save PIN locally
        await sp.setString('user_pin', pin);
        await sp.setString('user_email', widget.email);

        _navigateBasedOnStatus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to set PIN, try again.")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong: $e")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
        MaterialPageRoute(builder: (_) => HomeScreen()), // Always go to Home screen after login
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    }
  }


  @override
  void dispose() {
    _pinCtrl.dispose();
    _pin2Ctrl.dispose();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final maxWidth = isTablet ? 500.0 : size.width;
    final horizontalPadding = isTablet ? 48.0 : 24.0;
    final logoSize = isTablet ? 120.0 : 100.0;
    
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Set 4-digit PIN',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 22 : 18,
          ),
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Color(0xFFFF6B00),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isTablet ? 48.0 : 32.0,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 40 : 35),
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
                    width: logoSize,
                    height: logoSize,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: isTablet ? 28 : 20),
                Text(
                  'Create a secure 4-digit PIN to protect your app',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: isTablet ? 40 : 30),
                TextField(
                  controller: _email,
                  enabled: false,
                  readOnly: true,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: isTablet ? 16 : 14,
                  ),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                    filled: true,
                    fillColor: Colors.grey.shade300,
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.grey,
                      size: isTablet ? 24 : 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: isTablet ? 20 : 16,
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 20),
                TextField(
                  obscureText: _isPinHiddenn,
                  controller: _pinCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  style: TextStyle(fontSize: isTablet ? 16 : 14),
                  decoration: InputDecoration(
                    labelText: 'Enter PIN',
                    labelStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                    counterText: "",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Color(0xFFFF6B00),
                      size: isTablet ? 24 : 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPinHiddenn ? Icons.visibility_off : Icons.visibility,
                        color: Color(0xFFFF6B00),
                        size: isTablet ? 24 : 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPinHiddenn = !_isPinHiddenn;
                        });
                      },
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: isTablet ? 20 : 16,
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 20),
                TextField(
                  obscureText: _isPinHidden,
                  controller: _pin2Ctrl,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  style: TextStyle(fontSize: isTablet ? 16 : 14),
                  decoration: InputDecoration(
                    labelText: 'Confirm PIN',
                    labelStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                    counterText: "",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Color(0xFFFF6B00),
                      size: isTablet ? 24 : 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPinHidden ? Icons.visibility_off : Icons.visibility,
                        color: Color(0xFFFF6B00),
                        size: isTablet ? 24 : 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPinHidden = !_isPinHidden;
                        });
                      },
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: isTablet ? 20 : 16,
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 40 : 30),
                _saving
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF6B00),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _savePin,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              vertical: isTablet ? 20 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Color(0xFFFF6B00),
                            elevation: 3,
                          ),
                          child: Text(
                            'Save PIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 20 : 18,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}