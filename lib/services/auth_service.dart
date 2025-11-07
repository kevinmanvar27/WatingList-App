import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Api_Model/restaurant_user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Google Sign-in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      // Backend API Call
      final response = await http.post(
        Uri.parse("https://waitinglist.rektech.work/api/auth/google?access_token=$accessToken"),
        body: {
          "access_token": accessToken,
          "id_token": idToken,
        },
      );

      final data = jsonDecode(response.body);
      print("✅ Backend Data: $data");

      // ✅ Validate and Extract Data
      if (response.statusCode == 200 && data["success"] == true) {
        final user = data["data"]["user"];
        final token = data["data"]["token"];

        // ✅ Save User Data in Local Storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("user_name", user["name"] ?? "");
        await prefs.setString("user_email", user["email"] ?? "");
        await prefs.setString("token", token ?? "");

        print("✅ Saved User:");
        print("Access Token:- $accessToken");
        print("Name: ${user["name"]}");
        print("Email: ${user["email"]}");
        print("Token: $token");

        return data;
      } else {
        print("❌ Login Failed Response: $data");
        return null;
      }

    } catch (e) {
      print("Google Sign-in Error: $e");
      return null;
    }
  }


  static Future<RestaurantUser?> searchUserByPhone(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      print("🔍 Searching Phone → $phone");
      print("🔑 Token → $token");

      final response = await http.get(
        Uri.parse("https://waitinglist.rektech.work/api/restaurant-users/search/by-phone/${phone.trim()}"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json"
        },
      );

      print("📩 Status Code → ${response.statusCode}");
      print("📦 Response → ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData["success"] == true && jsonData["data"] != null) {
          return RestaurantUser.fromJson(jsonData["data"]);
        }
      }

      return null;
    } catch (e) {
      print("❌ Search User Error: $e");
      return null;
    }
  }

  static Future<bool?> toggleRestaurantStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final url = Uri.parse("https://waitinglist.rektech.work/api/restaurants/my-restaurant/toggle-status");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["data"]["operational_status"];
    } else {
      return null;
    }
  }

  static Future<Map<String, dynamic>> fetchRestaurantDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final url = Uri.parse("https://waitinglist.rektech.work/api/restaurants/my-restaurant");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );
    final data = jsonDecode(response.body);
    final profilePath = data["data"]["profile"];
    final profileUrl = "https://waitinglist.rektech.work/storage/$profilePath";
    print('profile image:-$profileUrl');
    return data["data"];
  }


  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<Map<String, String>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "name": prefs.getString("user_name") ?? "",
      "email": prefs.getString("user_email") ?? "",
      "token": prefs.getString("token") ?? "",
    };
  }
}