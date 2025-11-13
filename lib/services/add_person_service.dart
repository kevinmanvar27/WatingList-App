import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Api_Model/restaurant_user_model.dart';

class ApiService {
  static const String baseUrl = "https://waitinglist.rektech.work/api";

  // Common POST Helper Method
  static Future<http.Response> postApi(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    return await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );
  }

  static Future<RestaurantUser?> addRestaurantUser(
      String name, String mobile, String totalPersons) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    print("🔹 Adding restaurant user...");
    print("➡️ Name: $name, Mobile: $mobile, Total Persons: $totalPersons");
    
    // Normalize phone to E.164 if it's 10 digits (Indian format)
    String normalizedMobile = mobile;
    if (mobile.length == 10 && !mobile.startsWith('+')) {
      normalizedMobile = '+91$mobile';
    }
    
    final response = await http.post(
      Uri.parse("$baseUrl/restaurant-users"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: {
        "username": name,
        "mobile_number": normalizedMobile,
        "total_users_count": totalPersons
      },
    );

    print("📩 Response Status Code: ${response.statusCode}");
    print("📩 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      print("response:-${response.body}");

      final jsonData = json.decode(response.body);
      print("✅ User Added Successfully!");
      print("👤 Parsed Data: ${jsonData["data"]}");
      return RestaurantUser.fromJson(jsonData["data"]);

    }
    return null;
  }

  static Future<List<RestaurantUser>> fetchUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("$baseUrl/restaurant-users"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List list = jsonData["data"];
      return list.map((e) => RestaurantUser.fromJson(e)).toList();
    } else {
      return [];
    }
  }

  static Future<bool> deleteUser(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.delete(
      Uri.parse("$baseUrl/restaurant-users/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<bool> editUser(int id, String name, String mobile, String persons) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final url = Uri.parse("$baseUrl/restaurant-users/$id");

    // Normalize phone to E.164 if it's 10 digits (Indian format)
    String normalizedMobile = mobile;
    if (mobile.length == 10 && !mobile.startsWith('+')) {
      normalizedMobile = '+91$mobile';
    }

    final response = await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "username": name,
        "mobile_number": normalizedMobile,
        "total_users_count": persons,
        "status": "waiting"
      }),
    );

    return response.statusCode == 200;
  }

  // ✅ Correct Mark Dine-In
  static Future<bool> markDineIn(int id) async {
    final response = await postApi("$baseUrl/restaurant-users/$id/mark-dine-in");
    return response.statusCode == 200;
  }

  // ✅ Correct Mark Waiting
  static Future<bool> markWaiting(int id) async {
    final response = await postApi("$baseUrl/restaurant-users/$id/mark-waiting");
    return response.statusCode == 200;
  }
}
