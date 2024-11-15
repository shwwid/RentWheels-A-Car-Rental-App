import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthGoogle {
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser  = await GoogleSignIn().signIn();

      if (gUser  == null) {
        // The user canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication gAuth = await gUser .authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (error) {
      print("Error signing in with Google: $error");
      return null; // or handle the error as needed
    }
  }
}