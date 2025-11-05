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

    final response = await http.post(
      Uri.parse("$baseUrl/restaurant-users"),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: {
        "username": name,
        "mobile_number": mobile,
        "total_users_count": totalPersons
      },
    );

    print("POST RESPONSE: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
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

    print("GET RESPONSE: ${response.body}");

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

    print("DELETE STATUS: ${response.statusCode}");
    return response.statusCode == 200 || response.statusCode == 204;
  }

  static Future<bool> editUser(int id, String name, String mobile, String persons) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final url = Uri.parse("$baseUrl/restaurant-users/$id");

    final response = await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "username": name,
        "mobile_number": mobile,
        "total_users_count": persons,
        "status": "waiting"
      }),
    );

    print("EDIT STATUS: ${response.statusCode}");
    print("EDIT RESPONSE: ${response.body}");

    return response.statusCode == 200;
  }

  // ✅ Correct Mark Dine-In
  static Future<bool> markDineIn(int id) async {
    final response = await postApi("$baseUrl/restaurant-users/$id/mark-dine-in");
    print("MARK DINE-IN STATUS: ${response.statusCode}");
    return response.statusCode == 200;
  }

  // ✅ Correct Mark Waiting
  static Future<bool> markWaiting(int id) async {
    final response = await postApi("$baseUrl/restaurant-users/$id/mark-waiting");
    print("MARK WAITING STATUS: ${response.statusCode}");
    return response.statusCode == 200;
  }
}
