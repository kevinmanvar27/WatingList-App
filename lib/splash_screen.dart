import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Screen/Home_screen.dart';
import 'Screen/auth_screen.dart';
import 'Screen/Business_profile_screen.dart';
import 'Screen/pin_login_screen.dart';
import 'Screen/waiting_list_screen.dart';
import 'services/restaurant_service.dart';
import 'services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> decide() async {
    // Fetch public settings and log show_home_page flag
    await _fetchAndLogPublicSettings();

    await Future.delayed(Duration(seconds: 2));
    if (!mounted) return;

    final sp = await SharedPreferences.getInstance();
    final authToken = sp.getString('auth_token');
    final userPin = sp.getString('user_pin');
    final userEmail = sp.getString('user_email');
    // print(userEmail);

    // 1. Check if user is logged in (Valid Token)
    if (authToken != null && authToken.isNotEmpty) {
      if (!mounted) return;

      try {
        // Verify token is valid by checking if restaurant exists
        final hasRestaurant = await _checkUserHasRestaurant(authToken);

        if (!mounted) return;

        if (hasRestaurant) {
          // User has restaurant - check showHomePage flag
          // print('✅ User has restaurant - Checking showHomePage flag');
          if (_showHomePage == 0) {
            // print('➡️ showHomePage is 0 - Going to WaitingListScreen');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => WaitingListScreen()),
            );
          } else {
            // print('➡️ showHomePage is 1 - Going to HomeScreen');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen(refreshKey: UniqueKey(), showHomePage: _showHomePage)),
            );
          }
        } else {
          // User has token but no restaurant - needs to setup
          // print('⚠️ User has token but no restaurant - Going to Business Profile');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => Business_profile_screen()),
          );
        }
      } catch (e) {
        // print('❌ Error checking restaurant: $e');

        // Token might be invalid - handle not logged in
        if (mounted) {
          _handleNotLoggedIn(userPin, userEmail);
        }
      }
    } else {
      // No token found
      // print('ℹ️ No auth token found');
      if (mounted) {
        _handleNotLoggedIn(userPin, userEmail);
      }
    }
  }

  int _showHomePage = 1; // Default to 1 (show home page)

  Future<void> _fetchAndLogPublicSettings() async {
    try {
      final response = await http
          .get(Uri.parse('https://waitinglist.rektech.work/api/settings/public'))
          .timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'] as Map<String, dynamic>?;
        _showHomePage = data?['show_home_page'] ?? 1;
        // print('show_home_page from settings: $_showHomePage');
        
        // Save show_home_page to shared preferences
        final sp = await SharedPreferences.getInstance();
        await sp.setInt('show_home_page', _showHomePage);
      } else {
        // print('Failed to fetch public settings. Status: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error fetching public settings: $e');
    }
  }

  // NEW: Direct API call to check if restaurant exists
  Future<bool> _checkUserHasRestaurant(String token) async {
    try {
      // print('🔍 Checking if user has restaurant with token: ${token.substring(0, 10)}...');

      final response = await http.get(
        Uri.parse('https://waitinglist.rektech.work/api/restaurants/my-restaurant'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      // print('📊 Restaurant check - Status Code: ${response.statusCode}');
      // print('📊 Response: ${response.body}');

      if (response.statusCode == 200) {
        // print('✅ Restaurant found');
        return true;
      } else if (response.statusCode == 404) {
        // print('⚠️ No restaurant found (404)');
        return false;
      } else if (response.statusCode == 401) {
        // print('❌ Unauthorized - Token expired (401)');
        throw Exception('Token expired');
      } else {
        // print('❌ Error: ${response.statusCode}');
        throw Exception('Failed to check restaurant: ${response.statusCode}');
      }
    } catch (e) {
      // print('❌ Exception in _checkUserHasRestaurant: $e');
      rethrow;
    }
  }

  void _handleNotLoggedIn(String? userPin, String? userEmail) {
    // print('📱 Handling not logged in scenario');

    // 2. If user has data (PIN exists) but not logged in -> Go to Pin Login
    if (userPin != null && userEmail != null) {
      // print('✅ PIN exists - Going to PinLoginScreen');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PinLoginScreen()),
      );
    } else {
      // 1. New User (No data, No login) -> Go to Auth Screen
      // print('✅ New user - Going to AuthScreen');


      if (_showHomePage == 0) {
        // print('➡️ showHomePage is 0 - Going to WaitingListScreen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AuthScreen()),
        );
      } else {
        // print('➡️ showHomePage is 1 - Going to HomeScreen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(refreshKey: UniqueKey(), showHomePage: _showHomePage)),
        );
      }
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
        child: Column(
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
              child: Image.asset(
                'assets/Images/re.png',
                width: 100,
                height: 100,
              ),
            ),
            SizedBox(height: 25),
            Text(
              "Waitinglist",
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
        ),
      ),
    );
  }
}