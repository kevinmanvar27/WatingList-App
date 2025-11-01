import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Screen/Home_screen.dart';

class PinSetupScreen extends StatefulWidget {
  @override
  _PinSetupScreenState createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final _pinCtrl = TextEditingController();
  final _pin2Ctrl = TextEditingController();
  bool _saving = false;

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
    final sp = await SharedPreferences.getInstance();
    await sp.setString('user_pin', pin);
    if (mounted) {
      setState(() => _saving = false);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB), // Light background ✅
      appBar: AppBar(
        title: const Text(
          'Set 4-digit PIN',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Color(0xFFFF6B00),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.lock_outline, size: 100, color: Color(0xFFFF6B00)),
              SizedBox(height: 20),
              Text(
                'Create a secure 4-digit PIN to protect your app',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 30),
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
                ),
              ),
              SizedBox(height: 30),
              _saving
                  ? Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
                  : ElevatedButton(
                onPressed: _savePin,
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
            ],
          ),
        ),
      ),
    );
  }
}
