import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lifetrack/api/firebase_api.dart';
import 'package:lifetrack/providers/firestore_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CarouselController carouselController = CarouselController(initialItem: 1);
  int currentIndex = 0;
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

  void initState() {
    super.initState();
    getVisits();
  }

  Future<void> getVisits() async {
    DateTime now = DateTime.now();
    String date =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    List<dynamic> visits = await context.read<FirestoreProvider>().fetchVisits(
      "aoFkTzmVJUXE0vRRIJACPcHWo3m1",
      date,
    );
    if (visits[1] == false) {
      FirebaseExerciseAPI().addVisit(
        date,
        "aoFkTzmVJUXE0vRRIJACPcHWo3m1",
        visits[0] + 1,
        true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Stream<DocumentSnapshot> visitsEntries =
        context.read<FirestoreProvider>().visits;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 240,
              child: CarouselView(
                itemSnapping: true,
                controller: carouselController,
                itemExtent: MediaQuery.sizeOf(context).width - 32,
                elevation: 4,
                onTap: (index) {
                  if (index == 0) {
                    Navigator.pushReplacementNamed(context, '/gym');
                  } else {
                    Navigator.pushReplacementNamed(context, '/expenses');
                  }
                },
                shrinkExtent: 100,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width - 32,
                        height: MediaQuery.sizeOf(context).height,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/images/gym.jpg',
                            ), // Replace with your image path
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Text(
                          'Gym',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width - 32,
                        height: MediaQuery.sizeOf(context).height,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/images/expenses.jpg',
                            ), // Replace with your image path
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Text(
                          'Expenses',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'App visits and contributions',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16, // Large font size
                    fontWeight: FontWeight.bold, // Bold for emphasis
                  ),
                ),
              ),
            ),

            StreamBuilder(
              stream: visitsEntries,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Waiting for data...');
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData) {
                  return Text('No data yet');
                }

                final rawdata = snapshot.data!.data() as Map<String, dynamic>;

                final keys = rawdata.keys.toList();
                keys.sort();
                Map<DateTime, int> dates = {};
                for (int i = 0; i < keys.length; i++) {
                  dates[DateTime.parse(keys[i])] = rawdata[keys[i]]["quantity"];
                }
                DateTime now = DateTime.now();

                return SizedBox(
                  width: 400,
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: HeatMap(
                        textColor: Colors.black,
                        size: 35,
                        startDate: DateTime(now.year, now.month, 1),
                        endDate: DateTime(now.year, now.month + 1, 0),
                        datasets: dates,
                        defaultColor: Color(0xFFE0E0E0),
                        colorMode: ColorMode.opacity,
                        showColorTip: false,
                        showText: true,
                        scrollable: true,
                        colorsets: {
                          1: Color.fromARGB(255, 33, 150, 243),
                          2: Color.fromARGB(265, 33, 150, 243),
                          3: Color.fromARGB(275, 33, 150, 243),
                          4: Color.fromARGB(285, 33, 150, 243),
                          5: Color.fromARGB(295, 33, 150, 243),
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
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
          else if (labels[currentIndex] == "Gym")
          {
            Navigator.pushReplacementNamed(context, '/gym');
          }

        },
        items: navItems,
      ),
    );
  }
}
