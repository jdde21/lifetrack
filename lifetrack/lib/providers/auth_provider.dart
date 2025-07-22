import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../api/auth.dart';

class UserAuthProvider with ChangeNotifier {
  AuthService authService = AuthService();
  User? user;

  User? get curUser => user;

  UserAuthProvider() {
    fetchUser();
  }

  void fetchUser() {
    user = authService.currentUser;
    notifyListeners();
  }

  Future<int> signIn(String email, String password) async {
    try {
      await authService.signInWithEmailAndPassword(email: email, password: password);
      fetchUser();
      return 1;
    }
    catch (e) {
      return 0;
    }
 
  }

  Future<int> signOut() async {
    try {
      await authService.signOut();
      fetchUser();
      return 1;
    }
    catch (e) {
      return 0;
    }
  }

  Future<int> signUp(String email, String password) async {
    try {
      await authService.createUserWithEmailAndPassword(email: email, password: password);
      fetchUser();
      return 1;
    }
    catch (e) {
      return 0;
    }
  }
}
