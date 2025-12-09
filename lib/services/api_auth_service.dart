import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import '../Api_Model/user_model.dart';

class ApiAuthService {
  static const String baseUrl = 'https://waitinglist.rektech.work/api/auth';
  static const String googleLoginEndpoint = '$baseUrl/google';
  static const String userDetailsEndpoint = '$baseUrl/user';
  static const String logoutEndpoint = '$baseUrl/logout';
  static const String setPinEndpoint = '$baseUrl/set-pin';
  static const String pinLoginEndpoint = '$baseUrl/pin-login';
  static const String profileEndpoint = '$baseUrl/profile';
  static const String changePinEndpoint = '$baseUrl/change-pin';

  String? _authToken;
  UserModel? _currentUser;

  // Getters
  String? get authToken => _authToken;
  UserModel? get currentUser => _currentUser;

  // Singleton instance
  static final ApiAuthService _instance = ApiAuthService._internal();
  factory ApiAuthService() => _instance;
  ApiAuthService._internal();

  /// Initialize the service by checking for saved token
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');

    if (_authToken != null) {
      // Try to fetch user details
      await fetchUserDetails();
    }
  }

  /// Set the authentication token
  Future<void> _setAuthToken(String? token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString('auth_token', token);
    } else {
      await prefs.remove('auth_token');
    }
  }

  /// Save user data to shared preferences
  Future<void> _saveUserData(UserModel user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', user.id);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
    await prefs.setBool('user_has_pin', user.hasPin);
    await prefs.setBool('user_is_admin', user.isAdmin);
    if (user.profilePicture != null) {
      await prefs.setString('user_profile_picture', user.profilePicture!);
    }
  }

  /// Clear user data from shared preferences
  Future<void> _clearUserData() async {
    _currentUser = null;
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_has_pin');
    await prefs.remove('user_is_admin');
    await prefs.remove('user_profile_picture');
  }

  /// Fetch current user details
  Future<UserModel?> fetchUserDetails() async {
    if (_authToken == null) return null;

    try {
      final response = await http.get(
        Uri.parse(userDetailsEndpoint),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _currentUser = UserModel.fromJson(data['data']);
          await _saveUserData(_currentUser!);
          return _currentUser;
        } else {
          developer.log('Failed to fetch user details: ${data['message'] ?? 'Unknown error'}',
              name: 'ApiAuthService.fetchUserDetails');
        }
      } else {
        developer.log('Failed to fetch user details. Status code: ${response.statusCode}',
            name: 'ApiAuthService.fetchUserDetails');
      }
    } catch (e) {
      developer.log('Exception in fetchUserDetails: $e',
          name: 'ApiAuthService.fetchUserDetails', error: e);
    }
    return null;
  }

  /// Login with Google using OAuth tokens
  Future<Map<String, dynamic>?> loginWithGoogle(String idToken, String accessToken) async {
    try {
      final response = await http.post(
        Uri.parse(googleLoginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_token': idToken,
          'access_token': accessToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _authToken = data['data']['token'];
          _currentUser = UserModel.fromJson(data['data']['user']);

          await _setAuthToken(_authToken);
          await _saveUserData(_currentUser!);

          return {
            'user': _currentUser,
            'token': _authToken,
          };
        } else {
          developer.log('Google login failed: ${data['message'] ?? 'Unknown error'}',
              name: 'ApiAuthService.loginWithGoogle');
        }
      } else {
        developer.log('Google login failed. Status code: ${response.statusCode}',
            name: 'ApiAuthService.loginWithGoogle');
      }
    } catch (e) {
      developer.log('Exception in loginWithGoogle: $e',
          name: 'ApiAuthService.loginWithGoogle', error: e);
    }
    return null;
  }

  /// Logout user
  Future<bool> logout() async {
    try {
      if (_authToken != null) {
        final response = await http.post(
          Uri.parse(logoutEndpoint),
          headers: {
            'Authorization': 'Bearer $_authToken',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode != 200) {
          developer.log('Logout failed. Status code: ${response.statusCode}',
              name: 'ApiAuthService.logout');
        }
      }
    } catch (e) {
      developer.log('Exception in logout: $e',
          name: 'ApiAuthService.logout', error: e);
    } finally {
      await _clearUserData();
    }
    return true;
  }

  /// Set PIN for user
  Future<bool> setPin(String pin) async {
    if (_authToken == null) return false;

    // Validate input
    if (pin.isEmpty) {
      developer.log('Set PIN failed: PIN cannot be empty',
          name: 'ApiAuthService.setPin');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(setPinEndpoint),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'pin': pin}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Update user data
          _currentUser = UserModel.fromJson(data['data']['user']);
          await _saveUserData(_currentUser!);
          return true;
        } else {
          developer.log('Set PIN failed: ${data['message'] ?? 'Unknown error'}',
              name: 'ApiAuthService.setPin');
        }
      } else {
        developer.log('Set PIN failed. Status code: ${response.statusCode}',
            name: 'ApiAuthService.setPin');
      }
    } catch (e) {
      developer.log('Exception in setPin: $e',
          name: 'ApiAuthService.setPin', error: e);
    }
    return false;
  }

  /// Login with PIN
  Future<Map<String, dynamic>?> loginWithPin(String email, String pin) async {
    // Validate inputs
    if (email.isEmpty || pin.isEmpty) {
      developer.log('PIN login failed: Email and PIN cannot be empty',
          name: 'ApiAuthService.loginWithPin');
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse(pinLoginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'pin': pin,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _authToken = data['data']['token'];
          _currentUser = UserModel.fromJson(data['data']['user']);

          await _setAuthToken(_authToken);
          await _saveUserData(_currentUser!);

          return {
            'user': _currentUser,
            'token': _authToken,
          };
        } else {
          developer.log('PIN login failed: ${data['message'] ?? 'Unknown error'}',
              name: 'ApiAuthService.loginWithPin');
        }
      } else {
        developer.log('PIN login failed. Status code: ${response.statusCode}',
            name: 'ApiAuthService.loginWithPin');
      }
    } catch (e) {
      developer.log('Exception in loginWithPin: $e',
          name: 'ApiAuthService.loginWithPin', error: e);
    }
    return null;
  }

  /// Update user profile
  Future<bool> updateProfile(String name, String? profilePicture) async {
    if (_authToken == null) return false;

    // Validate input
    if (name.isEmpty) {
      developer.log('Update profile failed: Name cannot be empty',
          name: 'ApiAuthService.updateProfile');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(profileEndpoint),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          if (profilePicture != null) 'profile_picture': profilePicture,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Update user data
          _currentUser = UserModel.fromJson(data['data']['user']);
          await _saveUserData(_currentUser!);
          return true;
        } else {
          developer.log('Update profile failed: ${data['message'] ?? 'Unknown error'}',
              name: 'ApiAuthService.updateProfile');
        }
      } else {
        developer.log('Update profile failed. Status code: ${response.statusCode}',
            name: 'ApiAuthService.updateProfile');
      }
    } catch (e) {
      developer.log('Exception in updateProfile: $e',
          name: 'ApiAuthService.updateProfile', error: e);
    }
    return false;
  }

  /// Change PIN
  Future<bool> changePin(String currentPin, String newPin, String confirmPin) async {
    if (_authToken == null) return false;

    // Validate inputs
    if (currentPin.isEmpty || newPin.isEmpty || confirmPin.isEmpty) {
      developer.log('Change PIN failed: All PIN fields are required',
          name: 'ApiAuthService.changePin');
      return false;
    }

    if (newPin != confirmPin) {
      developer.log('Change PIN failed: New PIN and confirmation do not match',
          name: 'ApiAuthService.changePin');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(changePinEndpoint),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'current_pin': currentPin,
          'new_pin': newPin,
          'confirm_pin': confirmPin,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Update user data
          _currentUser = UserModel.fromJson(data['data']['user']);
          await _saveUserData(_currentUser!);
          return true;
        } else {
          developer.log('Change PIN failed: ${data['message'] ?? 'Unknown error'}',
              name: 'ApiAuthService.changePin');
        }
      } else {
        developer.log('Change PIN failed. Status code: ${response.statusCode}',
            name: 'ApiAuthService.changePin');
      }
    } catch (e) {
      developer.log('Exception in changePin: $e',
          name: 'ApiAuthService.changePin', error: e);
    }
    return false;
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    // First check if we have a token
    if (_authToken == null || _authToken!.isEmpty) {
      return false;
    }

    // Try to fetch user details to verify token validity
    final user = await fetchUserDetails();
    return user != null;
  }
}