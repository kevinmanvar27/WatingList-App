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
      print("Google login response:-${response.body}");

      // ✅ Validate and Extract Data
      if (response.statusCode == 200 && data["success"] == true) {
        final user = data["data"]["user"];
        final token = data["data"]["token"];

        // ✅ Save User Data in Local Storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("user_name", user["name"] ?? googleUser.displayName ?? "");
        await prefs.setString("user_email", user["email"] ?? googleUser.email ?? "");
        await prefs.setString("token", token ?? "");

        return data;
      } else {
        return null;
      }

    } catch (e) {
      return null;
    }
  }

  static Future<RestaurantUser?> searchUserByPhone(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final response = await http.get(
        Uri.parse("https://waitinglist.rektech.work/api/restaurant-users/search/by-phone/${phone.trim()}"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json"
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData["success"] == true && jsonData["data"] != null) {
          return RestaurantUser.fromJson(jsonData["data"]);
        }
      }

      return null;
    } catch (e) {
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

    // Check if token exists
    if (token == null || token.isEmpty) {
      // Return empty data structure instead of null
      return {};
    }

    final url = Uri.parse("https://waitinglist.rektech.work/api/restaurants/my-restaurant");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      // Check if response is successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Check if data exists and is a Map
        if (data != null && data["data"] != null && data["data"] is Map<String, dynamic>) {
          return data["data"];
        }
      }
      
      // Return empty map if response is not successful or data is invalid
      return {};
    } catch (e) {
      // Return empty map on error
      return {};
    }
  }
//////////
  Future<List<dynamic>> fetchSubscriptions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("https://waitinglist.rektech.work/api/subscriptions"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["data"];
    } else {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> fetchSubscriptionStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("https://waitinglist.rektech.work/api/subscriptions/status"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData["success"] == true) {
          return jsonData["data"];
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> cancelSubscription() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.post(
        Uri.parse("https://waitinglist.rektech.work/api/subscriptions/cancel"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData["success"] == true;
      }
      return false;

    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> fetchSubscriptionDetails(int id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("https://waitinglist.rektech.work/api/subscriptions/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData["data"];
      }
      return null;

    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> createRazorpayOrder(int planId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.post(
        Uri.parse("https://waitinglist.rektech.work/api/subscriptions/create-razorpay-order?subscription_plan_id=$planId"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)["data"]; // Contains: order_id, amount, currency
      }
      return null;

    } catch (e) {
      return null;
    }
  }

  static Future<List<dynamic>> fetchUserTransactions() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      final response = await http.get(
        Uri.parse("https://waitinglist.rektech.work/api/user-transactions"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return jsonData["data"]; // List of transactions
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
//////////
  Future<void> signOut() async {
    // Try to revoke token on the backend (if endpoint exists). Safe to ignore failures.
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      if (token != null && token.isNotEmpty) {

        await http.post(
          Uri.parse("https://waitinglist.rektech.work/api/auth/logout"),
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        );
      }

      // Explicitly clear user-specific data to avoid leakage across sessions
      await prefs.remove("token");
      await prefs.remove("user_name");
      await prefs.remove("user_email");
      await prefs.remove("restaurant_open_status");
      await prefs.remove("current_restaurant_id");
      await prefs.remove("profile_image");
      await prefs.remove("is_logged_in");
      await prefs.remove("user_id");
    } catch (_) {
      // Swallow errors to ensure sign out continues
    }

    // Sign out from providers
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