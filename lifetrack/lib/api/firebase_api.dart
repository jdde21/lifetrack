import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FirebaseExerciseAPI {
  final CollectionReference db = FirebaseFirestore.instance.collection(
    "exercises",
  );

  final CollectionReference expenseDB = FirebaseFirestore.instance.collection(
    "expenses",
  );

  final CollectionReference visitsDB = FirebaseFirestore.instance.collection(
    "visits",
  );

  final CollectionReference userDB = FirebaseFirestore.instance.collection(
      "userinfo",
  );

  final CollectionReference studyDB = FirebaseFirestore.instance.collection(
      "study",
  );


  Future<void> addStudyTime(int minuteTime, String date, String uid) 
  {
    return studyDB.doc(uid).set({
      date: minuteTime
    }, SetOptions(merge: true));
  }

  Future<void> addUser(String firstName, String lastName, String uid) 
  {
    return userDB.doc(uid).set({
      "firstname": firstName,
      "lastname": lastName
    }, SetOptions(merge: true));
  }

  Future<void> addVisit(String date, String uid, int visit, bool appVisit) 
  {
    return visitsDB.doc(uid).set({
      date: {"quantity": visit, "appVisit": appVisit},
    }, SetOptions(merge: true));
  }

  Future<void> deleteSession(String date, String uid)
  {
    return db.doc("aoFkTzmVJUXE0vRRIJACPcHWo3m1").update({date: FieldValue.delete()});
  }

  Future<void> addExpense(List<List<String>> data, String date, String uid)
  {
    List<String> categories = data[0];
    List<String> expenses = data[1];

    Map<String, dynamic> firebaseData = {};

    for (int i = 0; i < categories.length; i++)
    {
      firebaseData[categories[i]] = expenses[i];
    }

    return expenseDB.doc("aoFkTzmVJUXE0vRRIJACPcHWo3m1").set({
      date: firebaseData,
    }, SetOptions(merge: true));
  }


  Future<void> addExercise(List<dynamic> data, String date, String uid) {
    Map<String, dynamic> exercises = {};

    int start = int.parse(data[0]);
    List<String> elements = ["exercises", "content"];

    exercises["exercises"] = [];
    exercises["sets"] = [];
    exercises["reps"] = [];
    exercises["weight"] = [];


    for (int j = 1; j <= start; j++) {
      exercises["exercises"].add(data[j]);
    }

    for (int k = 0; k < data[start + 1].length; k++) {
      exercises["sets"].add(data[start + 1][k][0]);
      exercises["reps"].add(data[start + 1][k][1]);
      exercises["weight"].add(data[start + 1][k][2]);
    }


    return db.doc(uid).set({
      date: exercises,
    }, SetOptions(merge: true));
  }

  Future<List<dynamic>> fetchData(String uid) async {
    DocumentSnapshot doc = await db.doc(uid).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<String> keys = data.keys.toList();
      keys.sort();
      List<dynamic> exercises = [];
      List<dynamic> sets = [];
      List<dynamic> reps = [];
      List<dynamic> weight = [];
      for (int i = 0; i < keys.length; i++) {
        reps.add(data[keys[i]]["reps"]);
        sets.add(data[keys[i]]["sets"]);
        weight.add(data[keys[i]]["weight"]);
        exercises.add(data[keys[i]]["exercises"]);
      }

      return [exercises, sets, reps, weight, keys];
    } else {
      return [];
    }
  }

  Future<List<String>> fetchCategories(String uid) async {
    DocumentSnapshot doc = await expenseDB.doc(uid).get();
    List<String> categories = [];
    if (doc.exists)
    {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<String> keys = data.keys.toList();
      categories = data[keys[0]].keys.toList();
    }
    return categories;
  }

  Future<List> fetchVisits(String uid, String date) async {
    DocumentSnapshot doc = await visitsDB.doc(uid).get();
    List<dynamic> returnList = [0, false];
    if (doc.exists)
    {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data[date] != null)
      {
        returnList[0] = (data[date]["quantity"]);
        returnList[1] = (data[date]["appVisit"]);
      }
    }
    return returnList;
  }

  Future<int> fetchStudyTime(String uid, String date) async {
    DocumentSnapshot doc = await studyDB.doc(uid).get();
    int studyTime = 0;
    if (doc.exists)
    {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data[date] != null)
      {
        studyTime = data[date];
      }
    }
    return studyTime;
  }

  Stream<DocumentSnapshot> getData() {
    return db.doc("aoFkTzmVJUXE0vRRIJACPcHWo3m1").snapshots();
  }

  Stream<DocumentSnapshot> getExpensesData() {
    return expenseDB.doc("aoFkTzmVJUXE0vRRIJACPcHWo3m1").snapshots();
  }

  Stream<DocumentSnapshot> getVisitsData() {
    return visitsDB.doc("aoFkTzmVJUXE0vRRIJACPcHWo3m1").snapshots();
  }

  Stream<DocumentSnapshot> getStudyData() {
    return studyDB.doc("aoFkTzmVJUXE0vRRIJACPcHWo3m1").snapshots();
  }
}
