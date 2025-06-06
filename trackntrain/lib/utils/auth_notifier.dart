
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trackntrain/utils/auth_service.dart';

class AuthNotifier extends ChangeNotifier{
  late StreamSubscription<User?> _authSubscription;

  AuthNotifier(){
    _authSubscription=AuthService.authStateChanges.listen((User? user){
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