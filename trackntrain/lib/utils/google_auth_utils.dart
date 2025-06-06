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

    return await AuthService.auth.signInWithCredential(credential);
  }on Exception catch (e) {
    return 'Google Sign-In failed: $e';
  }
}
