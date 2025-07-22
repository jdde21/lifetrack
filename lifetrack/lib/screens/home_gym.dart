import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lifetrack/api/firebase_api.dart';
import 'package:lifetrack/providers/auth_provider.dart';
import '../api/auth.dart';
import 'package:lifetrack/providers/firestore_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../graphs/bar_chart.dart';
import '../resources/topPortion.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePageGym extends StatefulWidget {
  const HomePageGym({super.key});

  @override
  State<HomePageGym> createState() => _HomeState();
}

class _HomeState extends State<HomePageGym> {
  final User? user = AuthService().currentUser;
  final _formKey = GlobalKey<FormState>();
  final List<double> weekly = [74, 80, 20, 50, 60, 90, 120];
  bool refresh = false;
  List<Widget> previousRecords = [];

  @override
  Widget build(BuildContext context) {
    String uid = "aoFkTzmVJUXE0vRRIJACPcHWo3m1";
    int currentIndex = 1;
    List<String> labels = ["Home", "Gym", "Expenses"];
    List<BottomNavigationBarItem> navItems = [
      BottomNavigationBarItem(
        label: "Home",
        icon: FaIcon(FontAwesomeIcons.house, size: 15),
      ),
      BottomNavigationBarItem(
        label: "Gym",
        icon: FaIcon(FontAwesomeIcons.dumbbell, size: 15),
      ),
      BottomNavigationBarItem(
        label: "Expenses",
        icon: FaIcon(FontAwesomeIcons.moneyBill, size: 15),
      ),
    ];
    Stream<DocumentSnapshot> exerciseEntries = context.read<FirestoreProvider>().exercises;

    StreamBuilder sessionBuilder() {
      return StreamBuilder(
        stream: exerciseEntries,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error encountered! ${snapshot.error}"));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No Todos Found"));
          }

          final rawdata = snapshot.data!.data() as Map<String, dynamic>;
          final keys = rawdata.keys.toList();
          final testData = [[], [], [], [], []];
          keys.sort();

          for (int i = 0; i < keys.length; i++) {
            testData[0].add(rawdata[keys[i]]["exercises"]);
            testData[1].add(rawdata[keys[i]]["sets"]);
            testData[2].add(rawdata[keys[i]]["reps"]);
            testData[3].add(rawdata[keys[i]]["weight"]);
            testData[4].add(keys[i]);
          }

          List<Column> columns = [];
          int counter = keys.length - 2;
          List<dynamic> sets = [];
          List<dynamic> reps = [];
          List<dynamic> weights = [];

          dynamic temp = rawdata[keys[counter]];

          return Container(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: keys.length - 1,
              itemBuilder: (context, index) {
                if (testData[4][index] == "list") {
                  return SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.all(5),
                  child: buildCard(
                    testData[4][((testData[4].length - 2) - index)],
                    ((testData[4].length - 2) - index),
                    testData,
                  ),
                );
              },
            ),
          );
        },
      );
    }

    StreamBuilder columnsBuilder(dynamic stream) {
      return StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error encountered! ${snapshot.error}"));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No Todos Found"));
          }

          final rawdata = snapshot.data!.data() as Map<String, dynamic>;
          final keys = rawdata.keys.toList();
          keys.sort();

          List<Column> columns = [];
          int counter = keys.length - 2;
          List<dynamic> sets = [];
          List<dynamic> reps = [];
          List<dynamic> weights = [];

          dynamic temp = rawdata[keys[counter]];

          for (int i = 0; i < temp["exercises"].length; i++) {
            List<Widget> children = [];
            children.add(
              Text(
                "Exercise: ${temp["exercises"][i]}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            );

            children.add(
              Text(
                "Sets: ${temp["sets"][i]}",
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            );
            children.add(
              Text(
                "Reps: ${temp["reps"][i]}",
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            );
            children.add(
              Text(
                "Weight (In Lbs): ${temp["weight"][i]}",
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            );
            columns.add(Column(children: children));
          }

          return SizedBox(
            height: 50,
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                runSpacing: 8,
                spacing: 11,
                children: columns,
              ),
            ),
          );
        },
      );
    }

    void _showAddTaskDialog(List<dynamic> rawData, dynamic exerciseStream) {
      List<dynamic> exercises = rawData[0][0];
      TextEditingController _dateController = TextEditingController();
      List<dynamic> repsSetsWeight = [];
      List<dynamic> data = [exercises.length];
      List<int> extraList = [];

      int counter = 0;
      List<dynamic> sets = [];
      List<dynamic> reps = [];
      List<dynamic> weights = [];
      int numberOfExer = rawData[0][0].length;
      String date = rawData[4][rawData[4].length - 2];

      for (int i = 0; i < exercises.length; i++) {
        extraList.add(i);
      }

      List<Column> columns = [];

      if (rawData[4].length == 1 && rawData[4][0] == "list") {
      } else {
        for (int i = 0; i < rawData[3].length; i++) {
          if (rawData[4][i] == date) {
            counter = i;
            break;
          }
        }

        for (int i = 0; i < numberOfExer; i++) {
          sets.add(rawData[1][counter]);
          reps.add(rawData[2][counter]);
          weights.add(rawData[3][counter]);
        }

        for (int i = 0; i < numberOfExer; i++) {
          List<Widget> children = [];
          children.add(
            Text(
              "Exercise: ${rawData[0][counter][i]}",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          );
          children.add(
            Text(
              "Sets: ${sets[0][i]}",
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          );
          children.add(
            Text(
              "Reps: ${reps[0][i]}",
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          );
          children.add(
            Text(
              "Weight (In Lbs): ${weights[0][i]}",
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          );
          columns.add(Column(children: children));
        }
      }

      for (int i = 0; i < exercises.length; i++) {
        repsSetsWeight.add([]);
        data.add(exercises[i]);
      }
      showDialog(
        useSafeArea: false,
        context: context,
        builder: (BuildContext context) {
          return MediaQuery.removeViewInsets(
            removeBottom: true,
            context: context,
            child: AlertDialog(
              title: Text('Add Gym Session'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      elevation: 4,
                      margin: EdgeInsets.all(16),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: TextFormField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            label: Text("Date"),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter an input";
                            } else {
                              return null;
                            }
                          },
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );

                            if (pickedDate != null) {
                              _dateController.text =
                                  "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 300,
                      height: 250,
                      child: Column(
                        children: [
                          Card(
                            elevation: 4,
                            margin: EdgeInsets.all(16),
                            child: SizedBox(
                              height: 200,
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Column(
                                    children:
                                        extraList.map((index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  exercises[index],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.all(10),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextFormField(
                                                          decoration: const InputDecoration(
                                                            label: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Text(
                                                                'Sets',
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return "Please enter an input";
                                                            } else {
                                                              return null;
                                                            }
                                                          },
                                                          onSaved: (value) {
                                                            repsSetsWeight[index]
                                                                .add(value);
                                                          },
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Expanded(
                                                        child: TextFormField(
                                                          decoration: const InputDecoration(
                                                            label: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Text(
                                                                'Reps',
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return "Please enter an input";
                                                            } else {
                                                              return null;
                                                            }
                                                          },
                                                          onSaved: (value) {
                                                            repsSetsWeight[index]
                                                                .add(value);
                                                          },
                                                        ),
                                                      ),
                                                      SizedBox(width: 10),
                                                      Expanded(
                                                        child: TextFormField(
                                                          decoration: const InputDecoration(
                                                            label: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Text(
                                                                'Weight',
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return "Please enter an input";
                                                            } else {
                                                              return null;
                                                            }
                                                          },
                                                          onSaved: (value) {
                                                            repsSetsWeight[index]
                                                                .add(value);
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text("Previous Gym Session"),
                    columnsBuilder(exerciseStream),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: Text('Add'),
                  onPressed: () async {
                    bool isValid = _formKey.currentState!.validate();

                    data.add(repsSetsWeight);
                    for (int i = 1; i < data.length; i++) {
                      if (data[i] == data[0]) {
                        data.removeAt(i);
                      }
                    }

                    data[0] = data[0].toString();
                    if (isValid) {
                      String uid = "";
                      if (context.read<UserAuthProvider>().curUser == null) {
                        uid = "aoFkTzmVJUXE0vRRIJACPcHWo3m1";
                      } else {
                        uid = context.read<UserAuthProvider>().curUser!.uid;
                      }
                      _formKey.currentState!.save();
                      await context.read<FirestoreProvider>().addExercise(
                        data,
                        _dateController.text,
                        uid,
                      );
                      List<dynamic> visits = await context.read<FirestoreProvider>().fetchVisits(uid, _dateController.text);
                      await context.read<FirestoreProvider>().addVisit(_dateController.text, uid, visits[0] + 1, visits[1]);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    }

    StreamBuilder graphBuilder() {
      return StreamBuilder(
        stream: exerciseEntries,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error encountered! ${snapshot.error}"));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No Todos Found"));
          }

          final rawdata = snapshot.data!.data() as Map<String, dynamic>;
          final keys = rawdata.keys.toList();
          keys.sort();
          final testData = [[], [], [], [], []];

          for (int i = 0; i < keys.length; i++) {
            testData[0].add(rawdata[keys[i]]["exercises"]);
            testData[1].add(rawdata[keys[i]]["sets"]);
            testData[2].add(rawdata[keys[i]]["reps"]);
            testData[3].add(rawdata[keys[i]]["weight"]);
            testData[4].add(keys[i]);
          }

          List<dynamic> sets = [];
          List<dynamic> reps = [];
          List<dynamic> weights = [];
          List<dynamic> dates = [];
          int numberOfExer = testData[0][0].length;

          if (testData[4][0] == "list" && testData[4].length == 1) {
          } else {
            for (int i = 0; i < testData[4].length - 1; i++) {
              sets.add(testData[1][i]);
              reps.add(testData[2][i]);
              weights.add(testData[3][i]);
              dates.add(testData[4][i]);
            }
          }

          return Container(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: numberOfExer,
              itemBuilder: (context, index) {
                List<String> finalSets = [];
                List<String> finalReps = [];
                List<String> finalWeights = [];

                List<String> tempSets = [];

                for (int i = 0; i < keys.length; i++) {
                  if (keys[i] != "list") {
                    finalSets.add(rawdata[keys[i]]["sets"][index].toString());
                    finalReps.add(rawdata[keys[i]]["reps"][index].toString());
                    finalWeights.add(
                      rawdata[keys[i]]["weight"][index].toString(),
                    );
                  }
                }

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: EdgeInsets.only(bottom: 16, left: 16, top: 16),
                  child: Column(
                    children: [
                      Text(
                        testData[0][0][index],
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14, // Large font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      BarChartSample6(
                        sets: sets.isEmpty ? [] : finalSets,
                        reps: reps.isEmpty ? [] : finalReps,
                        weights: weights.isEmpty ? [] : finalWeights,
                        dates: dates.isEmpty ? [] : keys,
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Exercise summary',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16, // Large font size
                      fontWeight: FontWeight.bold, // Bold for emphasis
                    ),
                  ),
                ),
              ),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      "Sets",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      "Reps",
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 9,
                      decoration: BoxDecoration(
                        color: Colors.cyan,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      "Weights",
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                ),
              ),
            ],
          ),
          graphBuilder(),
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'My gym sessions',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16, // Large font size
                  fontWeight: FontWeight.bold, // Bold for emphasis
                ),
              ),
            ),
          ),
          sessionBuilder(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          dynamic exerciseStream =
              FirebaseFirestore.instance
                  .collection("exercises")
                  .doc("aoFkTzmVJUXE0vRRIJACPcHWo3m1")
                  .snapshots();
          List<dynamic> data = await context
              .read<FirestoreProvider>()
              .fetchData(uid);
          _showAddTaskDialog(data, exerciseStream);
        },
        tooltip: 'Add Task',
        child: Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        currentIndex: currentIndex,
        onTap: (value) {
          currentIndex = value;
          if (labels[currentIndex] == "Expenses")
          {
            Navigator.pushReplacementNamed(context, '/expenses');
          }
          else if (labels[currentIndex] == "Home")
          {
            Navigator.pushReplacementNamed(context, '/home');
          }

        },
        items: navItems,
      ),
    );
  }

  String getDaySuffix(int day) {
    if ((day % 10) > 3 || (day % 10) == 0 || day == 11) {
      return "th";
    } else if ((day % 10) == 3) {
      return "rd";
    } else if ((day % 10) == 2) {
      return "nd";
    } else {
      return "st";
    }
  }

  List<Widget> cardChildren(int index, List<dynamic> data) {
    DateTime date = DateTime.parse(data[4][index]);

    String day = date.day.toString();
    String suffix = getDaySuffix(date.day);
    String monthYear = DateFormat('MMMM yyyy').format(date);

    List<Widget> children = [
      Dismissible(
        background: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface, // Background color
            borderRadius: BorderRadius.circular(12), // Rounded corners
          ),
          child: Icon(Icons.delete),
        ),
        key: ValueKey(date),
        direction: DismissDirection.down,
        onDismissed: (DismissDirection direction) async {
          await context.read<FirestoreProvider>().deleteSession(
            data[4][index],
            "",
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 200, // Image width
              height: 200, // Image height
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      height: 100,
                      width: 100,
                      'assets/images/weight-plates.png',
                    ),
                    Text(
                      "$day$suffix, $monthYear",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ];

    return children;
  }

  Widget buildCard(String date, int index, List<dynamic> data) {
    return GestureDetector(
      onTap: () {
        int counter = 0;
        List<dynamic> exercises = [];
        List<dynamic> sets = [];
        List<dynamic> reps = [];
        List<dynamic> weights = [];
        int numberOfExer = data[0][0].length;

        for (int i = 0; i < data[3].length; i++) {
          if (data[4][i] == date) {
            counter = i;
            break;
          }
        }

        for (int i = 0; i < numberOfExer; i++) {
          sets.add(data[1][counter]);
          reps.add(data[2][counter]);
          weights.add(data[3][counter]);
        }

        List<Column> columns = [];

        for (int i = 0; i < numberOfExer; i++) {
          List<Widget> children = [];
          children.add(
            Text(
              "Exercise: ${data[0][counter][i]}",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          );
          children.add(
            Text(
              "Sets: ${sets[0][i]}",
              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
            ),
          );
          children.add(
            Text(
              "Reps: ${reps[0][i]}",
              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
            ),
          );
          children.add(
            Text(
              "Weight (In Lbs): ${weights[0][i]}",
              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
            ),
          );
          columns.add(Column(children: children));
        }

        print(data);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            return Container(
              width: 500,
              height: 300,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runSpacing: 8,
                  spacing: 11,
                  children: columns,
                ),
              ),
            );
          },
        );
      },
      child: Container(
        width: 200,
        child: Column(children: cardChildren(index, data)),
      ),
    );
  }

  void formBuilder(
    List<dynamic> repsSetsWeight,
    int index,
    List<dynamic> exercises,
  ) {
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            exercises[index],
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      label: Align(
                        alignment: Alignment.center,
                        child: Text('Sets'),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter an input";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      repsSetsWeight[index].add(value);
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      label: Align(
                        alignment: Alignment.center,
                        child: Text('Reps'),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter an input";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      repsSetsWeight[index].add(value);
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      label: Align(
                        alignment: Alignment.center,
                        child: Text('Weight'),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter an input";
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) {
                      repsSetsWeight[index].add(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
