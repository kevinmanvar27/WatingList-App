import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Home_screen.dart';
import 'package:http/http.dart' as http;

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

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
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


  @override
  void dispose() {
    _pinCtrl.dispose();
    _pin2Ctrl.dispose();
    _email.dispose();
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
                )),
            SizedBox(height: 20),
            Text(
              'Create a secure 4-digit PIN to protect your app',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _email,
              enabled: false,
              readOnly: true,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: "Email",
                filled: true,
                fillColor: Colors.grey.shade300,
                prefixIcon: Icon(Icons.email, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),

            SizedBox(height: 20),
            TextField(
              obscureText: _isPinHiddenn,
              controller: _pinCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: 'Enter PIN',
                counterText: "",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.lock, color: Color(0xFFFF6B00)),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPinHiddenn ? Icons.visibility_off : Icons.visibility,
                    color: Color(0xFFFF6B00),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPinHiddenn = !_isPinHiddenn;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              obscureText: _isPinHidden,
              controller: _pin2Ctrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: 'Confirm PIN',
                counterText: "",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.lock_outline, color: Color(0xFFFF6B00)),
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
              ),
            ),
            SizedBox(height: 30),
            _saving
                ? Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00)))
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
            ),
          ],
        ),
      ),
    );
  }
}