import 'package:firebase_auth/firebase_auth.dart';
import 'package:trackntrain/utils/auth_service.dart';

Future<String?> signUpWithEmailAndPassword(String email,String password,String name) async{
  try {
    final credential=await AuthService.auth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );
    await credential.user?.updateDisplayName(name);
    return null;
  }on FirebaseAuthException catch (e) {
    if(e.code == 'weak-password') {
      return'The password provided is too weak.';
    } else if (e.code == 'email-already-in-use') {
      return 'The account already exists for that email.';
    } else {
      return 'Error signing up: ${e.message}';
    }
  }
}

Future<String?> signInWithEmailAndPassword(String email,String password) async{
  try {
    final credential=await AuthService.auth.signInWithEmailAndPassword(
      email: email, password: password
    );
    return null;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      return 'No user found for that email.';
    } else if (e.code == 'wrong-password') {
      return 'Wrong password provided for that user.';
    } else {
      return 'Error signing in: ${e.message}';
    }
  } catch (e) {
    return 'Error signing in: $e';
  }
}