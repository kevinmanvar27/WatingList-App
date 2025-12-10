import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class RestaurantService {
  static const String _baseUrl = "https://waitinglist.rektech.work/api";
  
  // Check if user has a restaurant account
  static Future<bool> userHasRestaurant() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final token = sp.getString('auth_token');
      
      if (token == null) {
        developer.log('No auth token found', name: 'RestaurantService.userHasRestaurant');
        return false;
      }
      
      final response = await http.get(
        Uri.parse("$_baseUrl/user/restaurant/my-restaurant"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));
      // print("tokennnnnnnnnnnnn===> ${token}");
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Check if the response has success=true and data is not null
        // This is the correct way to check if user has a restaurant
        return data['success'] == true && data['data'] != null;
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        developer.log('Unauthorized access - token may be expired', 
          name: 'RestaurantService.userHasRestaurant');
        return false;
      } else if (response.statusCode >= 500) {
        // Server error
        developer.log('Server error. Status code: ${response.statusCode}', 
          name: 'RestaurantService.userHasRestaurant');
        return false;
      } else if (response.statusCode >= 400) {
        // Client error
        developer.log('Client error. Status code: ${response.statusCode}', 
          name: 'RestaurantService.userHasRestaurant');
        return false;
      }
      
      return false;
    } on SocketException catch (e) {
      developer.log('Network error: $e', 
        name: 'RestaurantService.userHasRestaurant', error: e);
      return false;
    } on TimeoutException catch (e) {
      developer.log('Request timeout: $e', 
        name: 'RestaurantService.userHasRestaurant', error: e);
      return false;
    } catch (e) {
      developer.log('Unexpected error: $e', 
        name: 'RestaurantService.userHasRestaurant', error: e);
      return false;
    }
  }
  
  // Get user's restaurant details
  static Future<Map<String, dynamic>?> getRestaurantDetails() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final token = sp.getString('auth_token');
      
      if (token == null) {
        developer.log('No auth token found', name: 'RestaurantService.getRestaurantDetails');
        return null;
      }
      
      final response = await http.get(
        Uri.parse("$_baseUrl/user/restaurant"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        developer.log('Unauthorized access - token may be expired', 
          name: 'RestaurantService.getRestaurantDetails');
        return null;
      } else if (response.statusCode >= 500) {
        // Server error
        developer.log('Server error. Status code: ${response.statusCode}', 
          name: 'RestaurantService.getRestaurantDetails');
        return null;
      } else if (response.statusCode >= 400) {
        // Client error
        developer.log('Client error. Status code: ${response.statusCode}', 
          name: 'RestaurantService.getRestaurantDetails');
        return null;
      }
      
      return null;
    } on SocketException catch (e) {
      developer.log('Network error: $e', 
        name: 'RestaurantService.getRestaurantDetails', error: e);
      return null;
    } on TimeoutException catch (e) {
      developer.log('Request timeout: $e', 
        name: 'RestaurantService.getRestaurantDetails', error: e);
      return null;
    } catch (e) {
      developer.log('Unexpected error: $e', 
        name: 'RestaurantService.getRestaurantDetails', error: e);
      return null;
    }
  }
}