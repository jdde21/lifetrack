import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lifetrack/api/firebase_api.dart';
import 'package:lifetrack/graphs/line_chart.dart';
import 'package:lifetrack/graphs/pie_chart.dart';
import 'package:lifetrack/providers/auth_provider.dart';
import 'package:lifetrack/resources/topPortion.dart';
import '../api/auth.dart';
import 'package:lifetrack/providers/firestore_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../graphs/bar_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePageExpenses extends StatefulWidget {
  const HomePageExpenses({super.key});

  @override
  State<HomePageExpenses> createState() => _HomeStateExpenses();
}

class _HomeStateExpenses extends State<HomePageExpenses> {
  bool weekly = true;
  bool monthly = false;
  bool yearly = false;

  List<String> labels = ["Home", "Gym", "Expenses", "Study"];
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
    BottomNavigationBarItem(
      label: "Study",
      icon: FaIcon(FontAwesomeIcons.book, size: 15),
    ),
  ];

  int currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    Stream<DocumentSnapshot> expenseEntries =
        context.read<FirestoreProvider>().expenses;

    StreamBuilder sessionBuilder() {
      return StreamBuilder(
        stream: expenseEntries,
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
          final nameOfExpenses = rawdata[keys[0]].keys.toList();
          keys.sort();

          List<String> days = [
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday",
            "Sunday",
          ];

          Map<String, dynamic> summaryExpenses = {};
          Map<String, dynamic> prevSummaryExpenses = {};
          Map<String, dynamic> totalSummaryExpenses = {};
          for (int i = 0; i < nameOfExpenses.length; i++) {
            summaryExpenses[nameOfExpenses[i]] = 0;
            prevSummaryExpenses[nameOfExpenses[i]] = 0;
            totalSummaryExpenses[nameOfExpenses[i]] = 0;
          }

          int currentDay = DateTime.now().day;
          int currentYear = DateTime.now().year;
          int currentMonth = DateTime.now().month;
          int topRange = DateTime.now().weekday - 1;
          int bottomRange = 0;
          String summary = "";
          double sum = 0;
          double prevSum = 0;
          int previousMonday = currentDay - (topRange + 7);

          if (yearly) {
            for (int i = 0; i < keys.length; i++) {
              DateTime date = DateTime.parse(keys[i]);
              if (currentYear == date.year) {
                Map<String, dynamic> temp = rawdata[keys[i]];
                List<String> tempKeys = temp.keys.toList();
                tempKeys.sort();
                for (int i = 0; i < tempKeys.length; i++) {
                  double toBeAdded = double.parse(temp[tempKeys[i]]);
                  summaryExpenses[tempKeys[i]] += toBeAdded;
                  sum += toBeAdded;
                }
              } else if ((currentYear - 1) == date.year) {
                Map<String, dynamic> temp = rawdata[keys[i]];
                List<String> tempKeys = temp.keys.toList();
                tempKeys.sort();
                for (int i = 0; i < tempKeys.length; i++) {
                  double toBeAdded = double.parse(temp[tempKeys[i]]);
                  prevSummaryExpenses[tempKeys[i]] += toBeAdded;
                  prevSum += toBeAdded;
                }
              }
            }
            summary = "Yearly summary:";
          } else if (monthly) {
            for (int i = 0; i < keys.length; i++) {
              DateTime date = DateTime.parse(keys[i]);
              if (currentYear == date.year) {
                if (currentMonth == date.month) {
                  Map<String, dynamic> temp = rawdata[keys[i]];
                  List<String> tempKeys = temp.keys.toList();
                  tempKeys.sort();
                  for (int i = 0; i < tempKeys.length; i++) {
                    double toBeAdded = double.parse(temp[tempKeys[i]]);
                    summaryExpenses[tempKeys[i]] += toBeAdded;
                    sum += toBeAdded;
                  }
                } else if ((currentMonth - 1) == date.month) {
                  Map<String, dynamic> temp = rawdata[keys[i]];
                  List<String> tempKeys = temp.keys.toList();
                  tempKeys.sort();
                  for (int i = 0; i < tempKeys.length; i++) {
                    double toBeAdded = double.parse(temp[tempKeys[i]]);
                    prevSummaryExpenses[tempKeys[i]] += toBeAdded;
                    prevSum += toBeAdded;
                  }
                }
              }
            }
            summary = "Monthly summary:";
          } else if (weekly) {
            for (int i = 0; i < keys.length; i++) {
              DateTime date = DateTime.parse(keys[i]);
              int difference = currentDay - date.day;
              if (currentYear == date.year && currentMonth == date.month) {
                if (difference <= topRange && difference >= bottomRange) {
                  Map<String, dynamic> temp = rawdata[keys[i]];
                  List<String> tempKeys = temp.keys.toList();
                  tempKeys.sort();
                  for (int i = 0; i < tempKeys.length; i++) {
                    double toBeAdded = double.parse(temp[tempKeys[i]]);
                    summaryExpenses[tempKeys[i]] += toBeAdded;
                    sum += toBeAdded;
                  }
                } else if (date.day >= previousMonday &&
                    date.day <= (previousMonday + 6)) {
                  Map<String, dynamic> temp = rawdata[keys[i]];
                  List<String> tempKeys = temp.keys.toList();
                  tempKeys.sort();
                  for (int i = 0; i < tempKeys.length; i++) {
                    double toBeAdded = double.parse(temp[tempKeys[i]]);
                    prevSummaryExpenses[tempKeys[i]] += toBeAdded;
                    prevSum += toBeAdded;
                  }
                }
              }
            }
            summary = "Weekly summary:";
          }

          dynamic total = 0;
          Map<String, dynamic> percentages = {};

          for (int i = 0; i < keys.length; i++) {
            for (int j = 0; j < nameOfExpenses.length; j++) {
              double toBeAdded = double.parse(
                rawdata[keys[i]][nameOfExpenses[j]],
              );
              total += toBeAdded;
              totalSummaryExpenses[nameOfExpenses[j]] += toBeAdded;
            }
          }

          if (weekly || monthly || yearly) {
            for (int i = 0; i < nameOfExpenses.length; i++) {
              percentages[nameOfExpenses[i]] =
                  (((summaryExpenses[nameOfExpenses[i]] / sum) * 100)
                      .toStringAsFixed(2));
            }
          } else {
            for (int i = 0; i < nameOfExpenses.length; i++) {
              percentages[nameOfExpenses[i]] =
                  (((totalSummaryExpenses[nameOfExpenses[i]] / total) * 100)
                      .toStringAsFixed(2));
            }
          }

          print("percents");
          print(percentages);
          double expenseRatio = 0;
          if (prevSum == 0) {
            expenseRatio = 0;
          } else {
            expenseRatio = sum / prevSum;
          }

          String subtitle = "";
          if (weekly) {
            subtitle = "week-over-week change";
          } else if (monthly) {
            subtitle = "month-over-month change";
          } else if (yearly) {
            subtitle = "year-over-year change";
          }
          print("im adsd");

          List<PieChartSectionData> sectionData = [];
          int touchedIndex = -1;
          for (int i = 0; i < nameOfExpenses.length; i++) {
            final isTouched = i == touchedIndex;
            final fontSize = isTouched ? 25.0 : 16.0;
            final radius = isTouched ? 60.0 : 50.0;
            const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
            sectionData.add(
              PieChartSectionData(
                value:
                    double.parse(percentages[nameOfExpenses[i]]).isNaN
                        ? 0
                        : double.parse(percentages[nameOfExpenses[i]]),
                title:
                    percentages[nameOfExpenses[i]] == "Nan"
                        ? 0
                        : percentages[nameOfExpenses[i]],
                radius: radius,
                titleStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: shadows,
                ),
              ),
            );
          }

          List<Widget> expandedChildren = List.generate(nameOfExpenses.length, (
            index,
          ) {
            return Container(
              width: 170,
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            nameOfExpenses[index],
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: [
                            Card(
                              color: Colors.blue,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SizedBox(
                                height: 20,
                                width: 100,
                                child: Center(
                                  child: Text(
                                    summary.isEmpty
                                        ? "Total summary: ${totalSummaryExpenses[nameOfExpenses[index]]} PHP"
                                        : "$summary ${summaryExpenses[nameOfExpenses[index]]} PHP",
                                    style: TextStyle(
                                      fontSize: 6,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              color: Colors.blue,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SizedBox(
                                height: 20,
                                width: 100,
                                child: Center(
                                  child: Text(
                                    "Total summary: ${totalSummaryExpenses[nameOfExpenses[index]]} PHP",
                                    style: TextStyle(
                                      fontSize: 7,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
          return Column(
            children: [
              SizedBox(height: 15),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Cost allocation',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16, // Large font size
                      fontWeight: FontWeight.bold, // Bold for emphasis
                    ),
                  ),
                ),
              ),
              double.parse(percentages[nameOfExpenses[0]]).isNaN
                  ? Container(
                    width: 350,
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "No data available",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Upload your expenses for today",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  : Container(
                    width: 350,
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: PieChartSample1(percentages: percentages),
                      ),
                    ),
                  ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Expense ratio',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16, // Large font size
                      fontWeight: FontWeight.bold, // Bold for emphasis
                    ),
                  ),
                ),
              ),
              Container(
                width: 400,
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${expenseRatio.toStringAsFixed(2)}%",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Categories',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16, // Large font size
                      fontWeight: FontWeight.bold, // Bold for emphasis
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: Container(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: expandedChildren.length,
                    itemBuilder: (context, index) {
                      return expandedChildren[index];
                    },
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          sessionBuilder(),
          Container(
            width: 500,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        activeColor: Colors.blue,
                        value: weekly,
                        onChanged: (bool? value) {
                          setState(() {
                            weekly = value ?? false;
                            monthly = false;
                            yearly = false;
                          });
                        },
                      ),
                      Text('Weekly', style: TextStyle(fontSize: 12)),
                    ],
                  ),

                  Row(
                    children: [
                      Checkbox(
                        activeColor: Colors.blue,
                        value: monthly,
                        onChanged: (bool? value) {
                          setState(() {
                            monthly = value ?? false;
                            weekly = false;
                            yearly = false;
                          });
                        },
                      ),
                      Text('Monthly', style: TextStyle(fontSize: 12)),
                    ],
                  ),

                  Row(
                    children: [
                      Checkbox(
                        activeColor: Colors.blue,
                        value: yearly,
                        onChanged: (bool? value) {
                          setState(() {
                            yearly = value ?? false;
                            weekly = false;
                            monthly = false;
                          });
                        },
                      ),
                      Text('Yearly', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          List<String> categories = await context
              .read<FirestoreProvider>()
              .fetchCategories("aoFkTzmVJUXE0vRRIJACPcHWo3m1");
          _showAddTaskDialog(categories);
        },
        tooltip: 'Add Task',
        child: Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        currentIndex: currentIndex,
        onTap: (value) {
          currentIndex = value;
          if (labels[currentIndex] == "Gym") {
            Navigator.pushReplacementNamed(context, '/gym');
          } else if (labels[currentIndex] == "Home") {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (labels[currentIndex] == "Study") {
            Navigator.pushReplacementNamed(context, '/study');
          }
        },
        items: navItems,
      ),
    );
  }

  void _showAddTaskDialog(List<String> categories) {
    final _formKey = GlobalKey<FormState>();
    TextEditingController _dateController = TextEditingController();
    List<List<String>> data = [[], []];
    categories.sort();
    for (int i = 0; i < categories.length; i++) {
      data[0].add(categories[i]);
    }
    String uid = "aoFkTzmVJUXE0vRRIJACPcHWo3m1";
    DateTime now = DateTime.now();
    String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    _dateController.text = formattedDate;

    showDialog(
      useSafeArea: false,
      context: context,
      builder: (BuildContext context) {
        return MediaQuery.removeViewInsets(
          removeBottom: true,
          context: context,
          child: AlertDialog(
            title: Text('Add New Expense'),
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
                        decoration: const InputDecoration(label: Text("Date")),
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
                                      categories.map((category) {
                                        return Container(
                                          height: 100,
                                          child: Padding(
                                            padding: EdgeInsets.all(16),
                                            child: TextFormField(
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                label: Text(category),
                                              ),
                                              validator: (value) {
                                                RegExp hasLetters = RegExp(
                                                  r"\D",
                                                ); // reference: https://blog.0xba1.xyz/0522/dart-flutter-regexp/ matches any character that is a digit
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return "Please enter your amount";
                                                } else if (hasLetters.hasMatch(
                                                  value,
                                                )) {
                                                  return "Please enter a valid amount";
                                                } else if (int.parse(value) <=
                                                    0) {
                                                  return "Please enter a valid amount";
                                                }

                                                return null;
                                              },
                                              onSaved: (value) {
                                                data[1].add(value!);
                                              },
                                            ),
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

                  if (isValid) {
                    _formKey.currentState!.save();
                    await context.read<FirestoreProvider>().addExpense(
                      data,
                      _dateController.text,
                      uid,
                    );
                    List<dynamic> visits = await context
                        .read<FirestoreProvider>()
                        .fetchVisits(uid, _dateController.text);
                    await context.read<FirestoreProvider>().addVisit(
                      _dateController.text,
                      uid,
                      visits[0] + 1,
                      visits[1],
                    );
                    Navigator.of(context).pop();
                  }
                  
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
