import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Google Sign-in
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      // Backend API Call
      final response = await http.post(
        Uri.parse("https://waitinglist.rektech.work/api/auth/google?access_token=${googleAuth.accessToken}"),
        body: {
          "access_token": accessToken,
          "id_token": idToken,
        },
      );

      print("Backend Response Status: ${response.statusCode}");
      print("Backend Body: ${response.body}");
      print("Backend Body: ${accessToken}");
      final data = jsonDecode(response.body);

      if (data["success"] == true) {
        return data;
      } else {
        return null;
      }

    } catch (e) {
      print("Google Sign-in Error: $e");
      return null;
    }
  }


  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}