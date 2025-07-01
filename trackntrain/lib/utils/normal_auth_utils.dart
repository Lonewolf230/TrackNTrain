import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trackntrain/utils/auth_service.dart';

Future<String?> signUpWithEmailAndPassword(String email,String password,String name,BuildContext context) async{
  try {
    final credential=await AuthService.auth.createUserWithEmailAndPassword(
      email: email, 
      password: password
    );
    await credential.user?.updateDisplayName(name);
    await credential.user?.reload();
    await Future.delayed(const Duration(seconds: 1));
    // await credential.user?.reload();
    return credential.user?.uid;
  }on FirebaseAuthException catch (e) {
    if(e.code == 'weak-password') {
      throw Exception('The password provided is too weak.');
    } else if (e.code == 'invalid-email') {
      throw Exception('The email address is not valid.');
    } else if (e.code == 'email-already-in-use') {
      throw Exception('The email address is already in use by another account.');
    } else {
      throw Exception('Error signing up: ${e.message}');
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
      throw Exception('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      throw Exception('Wrong password provided for that user.');
    } else {
      throw Exception('Error signing in: ${e.message}');
    }
  } catch (e) {
    throw Exception('Error signing in: $e');
  }
}