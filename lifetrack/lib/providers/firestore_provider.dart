import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lifetrack/api/firebase_api.dart'; 

class FirestoreProvider with ChangeNotifier {
  FirebaseExerciseAPI authService = FirebaseExerciseAPI();
  late Stream<DocumentSnapshot> _exercisesStream;
  late Stream<DocumentSnapshot> _expensesStream;
  late Stream<DocumentSnapshot> _visitsStream;

  FirestoreProvider() {
    fetchExercise();
  }

  Stream<DocumentSnapshot> get exercises => _exercisesStream;
  Stream<DocumentSnapshot> get expenses => _expensesStream;
  Stream<DocumentSnapshot> get visits => _visitsStream;

  void fetchExercise() {
    _exercisesStream = authService.getData();
    _expensesStream = authService.getExpensesData();
    _visitsStream = authService.getVisitsData();
    notifyListeners();
  }


  Future<void> addExercise(List<dynamic> data, String date, String uid) async {
    await authService.addExercise(data, date, uid);
  }

  Future<void> addVisit(String date, String uid, int visit, bool appVisit) async {
    await authService.addVisit(date, uid, visit, appVisit);
  }

  Future<void> addExpense(List<List<String>> data, String date, String uid) async {
    await authService.addExpense(data, date, uid);
  }

  Future<void> addUser(String firstName, String lastName, String uid) async {
    await authService.addUser(firstName, lastName, uid);
  }

  Future<void> deleteSession(String date, String uid) async {
    await authService.deleteSession(date, uid);
  }

  Future<List<dynamic>> fetchData(String uid) async {
    return authService.fetchData(uid);
  }

  Future<List<String>> fetchCategories(String uid) async {
    return authService.fetchCategories(uid);
  }

  Future<List> fetchVisits(String uid, String date) async {
    return authService.fetchVisits(uid, date);
  }
}
