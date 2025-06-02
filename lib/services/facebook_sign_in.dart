import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign in with Facebook using Firebase Authentication
  static Future<UserCredential?> signInWithFacebook() async {
    try {
      // Trigger the Facebook sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      // Check if the login was successful
      if (loginResult.status == LoginStatus.success) {
        // Get the access token
        final AccessToken accessToken = loginResult.accessToken!;

        // Create a credential from the access token
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(accessToken.tokenString);

        // Once signed in, return the UserCredential
        return await _auth.signInWithCredential(facebookAuthCredential);
      } else if (loginResult.status == LoginStatus.cancelled) {
        print('Facebook login was cancelled by user');
        return null;
      } else {
        print('Facebook login failed: ${loginResult.message}');
        return null;
      }
    } catch (e) {
      print('Facebook Sign-In Error: $e');
      return null;
    }
  }

  /// Get user profile information from Facebook
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final userData = await FacebookAuth.instance.getUserData(
        fields: "name,email,picture.width(200)",
      );
      return userData;
    } catch (e) {
      print('Error getting Facebook user profile: $e');
      return null;
    }
  }

  /// Sign out from Facebook
  static Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        FacebookAuth.instance.logOut(),
      ]);
    } catch (e) {
      print('Error signing out from Facebook: $e');
    }
  }

  /// Check if user is logged in to Facebook
  static Future<bool> isLoggedIn() async {
    try {
      final AccessToken? accessToken = await FacebookAuth.instance.accessToken;
      return accessToken != null;
    } catch (e) {
      print('Error checking Facebook login status: $e');
      return false;
    }
  }

  /// Get current Facebook access token
  static Future<AccessToken?> getCurrentAccessToken() async {
    try {
      return await FacebookAuth.instance.accessToken;
    } catch (e) {
      print('Error getting Facebook access token: $e');
      return null;
    }
  }
}
