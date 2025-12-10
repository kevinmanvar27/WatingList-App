import 'dart:developer' as developer;
import '../Api_Model/user_model.dart';
import 'api_auth_service.dart';

class AuthService {
  final ApiAuthService _apiAuthService = ApiAuthService();

  Future<void> init() async {
    await _apiAuthService.init();
  }

  Future<UserModel?> signInWithGoogle(String idToken, String accessToken) async {
    try {
      final result = await _apiAuthService.loginWithGoogle(idToken, accessToken);
      return result?['user'];
    } catch (e) {
      developer.log('Exception in signInWithGoogle: $e', 
        name: 'AuthService.signInWithGoogle', error: e);
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _apiAuthService.logout();
    } catch (e) {
      developer.log('Exception in signOut: $e', 
        name: 'AuthService.signOut', error: e);
    }
  }
  
  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      return await _apiAuthService.isAuthenticated();
    } catch (e) {
      developer.log('Exception in isAuthenticated: $e', 
        name: 'AuthService.isAuthenticated', error: e);
      return false;
    }
  }

  // PIN-related methods
  Future<bool> setPin(String pin) async {
    return await _apiAuthService.setPin(pin);
  }

  Future<UserModel?> loginWithPin(String email, String pin) async {
    try {
      final result = await _apiAuthService.loginWithPin(email, pin);
      return result?['user'];
    } catch (e) {
      developer.log('Exception in loginWithPin: $e', 
        name: 'AuthService.loginWithPin', error: e);
      return null;
    }
  }

  // Profile methods
  Future<bool> updateProfile(String name, String? profilePicture) async {
    return await _apiAuthService.updateProfile(name, profilePicture);
  }

  Future<bool> changePin(String currentPin, String newPin, String confirmPin) async {
    return await _apiAuthService.changePin(currentPin, newPin, confirmPin);
  }

  // Get current user
  UserModel? getCurrentUser() {
    return _apiAuthService.currentUser;
  }
}