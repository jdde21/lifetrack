import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lifetrack/providers/firestore_provider.dart';
import 'package:provider/provider.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import '../graphs/line_chart.dart';

class HomePageStudy extends StatefulWidget {
  const HomePageStudy({super.key});

  @override
  State<HomePageStudy> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<HomePageStudy> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer();

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int currentIndex = 3;
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
    Stream<DocumentSnapshot> studyEntries =
        context.read<FirestoreProvider>().studies;

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder(
              stream: studyEntries,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                final rawdata = snapshot.data!.data() as Map<String, dynamic>;
                final keys = rawdata.keys.toList();
                keys.sort();
                List<FlSpot> coordinates = [];
                int currentDay = DateTime.now().day;
                int currentYear = DateTime.now().year;
                int currentMonth = DateTime.now().month;
                int topRange = DateTime.now().weekday - 1;
                int bottomRange = 0;
                String summary = "";
                double sum = 0;
                double prevSum = 0;
                int previousMonday = currentDay - (topRange + 7);

                for (int i = 0; i < keys.length; i++) 
                {
                  DateTime date = DateTime.parse(keys[i]);
                  int difference = currentDay - date.day;
                  if (currentYear == date.year && currentMonth == date.month) 
                  {
                    if (difference <= topRange && difference >= bottomRange) 
                    {
                      int weekday = date.weekday;
                      coordinates.add(
                        FlSpot(weekday.toDouble(), rawdata[keys[i]].toDouble()),
                      );
                    }
                  }
                }

    
                return LineChartSample1(coordinates: coordinates);
              },
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Card(
                                color: Colors.blue,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: SizedBox(
                                  height: 30,
                                  width: 200,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Record study time',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16, // Large font size
                                        fontWeight:
                                            FontWeight
                                                .bold, // Bold for emphasis
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.20,
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  StreamBuilder<int>(
                                    stream: _stopWatchTimer.rawTime,
                                    initialData: 0,
                                    builder: (context, snap) {
                                      final value = snap.data;
                                      final displayTime =
                                          StopWatchTimer.getDisplayTime(value!);
                                      return Center(
                                        child: Column(
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.all(8),
                                              child: Text(
                                                displayTime,
                                                style: TextStyle(
                                                  fontSize: 40,
                                                  fontFamily: 'Helvetica',
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    _stopWatchTimer
                                                        .onStartTimer();
                                                  },
                                                  child: Text('Play'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    _stopWatchTimer
                                                        .onStopTimer();
                                                  },
                                                  child: Text('Stop'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    _stopWatchTimer
                                                        .onStopTimer();
                                                    int seconds =
                                                        ((snap.data! / 1000) /
                                                                60)
                                                            .toInt();
                                                    String uid =
                                                        "aoFkTzmVJUXE0vRRIJACPcHWo3m1";
                                                    DateTime now =
                                                        DateTime.now();
                                                    String date =
                                                        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
                                                    int studyTime =
                                                        await context
                                                            .read<
                                                              FirestoreProvider
                                                            >()
                                                            .fetchStudyTime(
                                                              uid,
                                                              date,
                                                            );
                                                    await context
                                                        .read<
                                                          FirestoreProvider
                                                        >()
                                                        .addStudyTime(
                                                          studyTime + seconds,
                                                          date,
                                                          uid,
                                                        );
                                                    _stopWatchTimer
                                                        .onResetTimer();
                                                  },
                                                  child: Text('Record'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
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
          } else if (labels[currentIndex] == "Expenses") {
            Navigator.pushReplacementNamed(context, '/expenses');
          }
        },
        items: navItems,
      ),
    );
  }
}
