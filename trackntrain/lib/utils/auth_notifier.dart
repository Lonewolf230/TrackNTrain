
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trackntrain/utils/auth_service.dart';

class AuthNotifier extends ChangeNotifier{
  late StreamSubscription<User?> _authSubscription;
  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AuthNotifier(){
    _currentUser = AuthService.currentUser;
    _authSubscription=AuthService.authStateChanges.listen((User? user){
      print('AuthNotifier: User state changed: ${user?.uid}');
      _currentUser = user; 
      notifyListeners();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _authSubscription.cancel();
    super.dispose();
  }
}