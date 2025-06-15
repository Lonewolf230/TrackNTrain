import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trackntrain/utils/auth_service.dart';
 

Future<dynamic> signInWithGoogle() async{
  try {
    final GoogleSignInAccount? googleUser=await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth=await googleUser?.authentication;

    final credential=GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    final userCredential=await AuthService.auth.signInWithCredential(credential);
    return userCredential.user?.uid;
  }on FirebaseAuthException catch (e) {
    if (e.code == 'account-exists-with-different-credential') {
      throw Exception('An account already exists with the same email address but different sign-in credentials. Please sign in using a different method.');
    } else if (e.code == 'invalid-credential') {
      throw Exception('The credential received is invalid.');
    } else {
      throw Exception('Error signing in with Google: ${e.message}');
    }
  } catch (e) {
    throw Exception('Error signing in with Google: $e');
  }
}
