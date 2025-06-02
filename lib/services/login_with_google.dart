
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginWithGoogle {
 static Future<void> signInWithGoogle() async {
    // begin interactive sign-in process
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      // The user canceled the sign-in
      return;
    }
    // obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    //finally sign in
    return await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      print("User signed in: ${value.user?.displayName}");
    }).catchError((e) {
      print("Error signing in with Google: $e");
    });
    
  }
}