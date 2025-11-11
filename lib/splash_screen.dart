import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screen/Home_screen.dart';
import 'Screen/pin_setup_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Future<void> decide() async {
    await Future.delayed(Duration(seconds: 0));

    final sp = await SharedPreferences.getInstance();
    final token = sp.getString('token');
    final email = sp.getString('user_email');
    final pin = sp.getString('user_pin'); // ✅ PIN check

    if (token != null && email != null) {
      if (pin != null && pin.isNotEmpty) {
        // ✅ PIN set che → HomeScreen ma jai
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PinSetupScreen(email: email)),
        );
      }
    } else {
      // 🔄 Login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()), // Auth screen
      );
    }
  }


  @override
  void initState() {
    super.initState();
    decide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: FutureBuilder(
          future: SharedPreferences.getInstance(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator(strokeWidth: 2);
            }

            final sp = snapshot.data!;
            final logo = sp.getString("app_logo") ?? "";
            final appName = sp.getString("app_name") ?? "Waitinglist";

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Container(
                  padding: EdgeInsets.all(25),
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
                  child: Image.network(
                    logo,
                    width: 100,
                    height: 100,
                    errorBuilder: (_, __, ___) =>
                        Image.asset("assets/Images/re.png", width: 100, height: 100),
                  ),
                ),

                SizedBox(height: 25),

                Text(
                  appName,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                SizedBox(height: 25),

                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  strokeWidth: 3,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}