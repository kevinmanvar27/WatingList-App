import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Api_Model/restaurant_user_model.dart';

class ApiService {
  static const String baseUrl = "https://waitinglist.rektech.work/api";

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

}
