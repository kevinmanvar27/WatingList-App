import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Screen/Home_screen.dart';
import 'Screen/auth_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Future<void> decide() async {
    await Future.delayed(Duration(seconds: 2));

    /// ✅ Load App Branding API
    try {
      final response = await http.get(
        Uri.parse("https://waitinglist.rektech.work/api/settings/public"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)["data"];
        final sp = await SharedPreferences.getInstance();

        await sp.setString("app_name", data["application_name"] ?? "");
        await sp.setString("app_logo", "https://waitinglist.rektech.work${data["app_logo"]}");
        await sp.setString("app_version", data["app_version"] ?? "");
      }
    } catch (_) {}

    /// ✅ Check Login Session
    final sp = await SharedPreferences.getInstance();
    final isLoggedIn = sp.getBool("is_logged_in") ?? false;

    if (isLoggedIn) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AuthScreen()));
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
