import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waiting_list2/Screen/waiting_list_screen.dart';
import 'Home_screen.dart';
import 'Business_profile_screen.dart';
import '../services/restaurant_service.dart';
import '../services/auth_service.dart';

class PinSetupScreen extends StatefulWidget {
  @override
  _PinSetupScreenState createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final _pinCtrl = TextEditingController();
  final _pin2Ctrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final AuthService _authService = AuthService();
  bool _saving = false;
  bool _pinValid = false;
  bool _pinsMatch = false;

  @override
  void initState() {
    super.initState();
    _pinCtrl.addListener(_validatePin);
    _pin2Ctrl.addListener(_validatePin);
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

  void _validatePin() {
    setState(() {
      // Validate first PIN
      if (_pinCtrl.text.length == 4 && RegExp(r'^[0-9]+$').hasMatch(_pinCtrl.text)) {
        _pinValid = true;
      } else {
        _pinValid = false;
      }

      // Check if PINs match
      if (_pinValid && _pinCtrl.text == _pin2Ctrl.text && _pin2Ctrl.text.isNotEmpty) {
        _pinsMatch = true;
      } else {
        _pinsMatch = false;
      }
    });
  }

  Future<void> _savePin() async {
    if (_saving) return;

    final pin = _pinCtrl.text.trim();
    final pin2 = _pin2Ctrl.text.trim();

    // Validation
    if (pin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter 4-digit PIN')),
      );
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PIN must contain only digits')),
      );
      return;
    }

    // Check for weak PINs
    // final weakPins = ['0000', '1111', '2222', '3333', '4444', '5555', '6666', '7777', '8888', '9999', '1234', '4321'];
    // if (weakPins.contains(pin)) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Please choose a stronger PIN')),
    //   );
    //   return;
    // }

    if (pin != pin2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PINs do not match')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      // Use the API service to set the PIN
      final success = await _authService.setPin(pin);

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PIN saved successfully!')),
        );

        // Check if user has restaurant account
        final hasRestaurant = await _checkUserHasRestaurant();

        if (mounted) {
          if (hasRestaurant) {
            // Check show home page flag
            final sp = await SharedPreferences.getInstance();
            final showHomePage = sp.getInt('show_home_page') ?? 1;

            if (showHomePage == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => WaitingListScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen(refreshKey: UniqueKey())),
              );
            }
          } else {
            // Redirect to restaurant creation page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => Business_profile_screen()),
            );
          }
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save PIN. Please try again.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save PIN. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  // Check if user has a restaurant account
  Future<bool> _checkUserHasRestaurant() async {
    try {
      // Check with backend API if user has restaurant account
      return await RestaurantService.userHasRestaurant();
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _pinCtrl.removeListener(_validatePin);
    _pin2Ctrl.removeListener(_validatePin);
    _pinCtrl.dispose();
    _pin2Ctrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Set 4-digit PIN',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Color(0xFFFF6B00),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
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
                )

            ),
            SizedBox(height: 20),
            Text(
              'Create a secure 4-digit PIN to protect your app',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _emailCtrl,
              enabled: false,
              decoration: InputDecoration(
                hintText: "Email (for display only)",
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.email, color: Colors.grey),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _pinCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Enter PIN',
                counterText: "",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.lock, color: Color(0xFFFF6B00)),
                errorText: _pinCtrl.text.isNotEmpty && !_pinValid
                  ? 'PIN must be 4 digits'
                  : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _pin2Ctrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm PIN',
                counterText: "",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.lock_outline, color: Color(0xFFFF6B00)),
                errorText: _pin2Ctrl.text.isNotEmpty && _pinCtrl.text.isNotEmpty && !_pinsMatch
                  ? 'PINs do not match'
                  : null,
              ),
            ),
            SizedBox(height: 30),
            _saving
                ? Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
                : SizedBox(
              width: double.infinity,
                  child: ElevatedButton(
                                  onPressed: _pinsMatch ? _savePin : null,
                                  style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
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
                      fontSize: 18),
                                  ),
                                ),
                ),
          ],
        ),
      ),
    );
  }
}