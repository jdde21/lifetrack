import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

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
    await _stopWatchTimer.dispose(); // Need to call dispose function.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          StreamBuilder<int>(
            stream: _stopWatchTimer.rawTime,
            initialData: 0,
            builder: (context, snap) {
              final value = snap.data;
              final displayTime = StopWatchTimer.getDisplayTime(value!);
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
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Helvetica',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  _stopWatchTimer.onStartTimer();
                },
                child: Text('Play'),
              ),
              TextButton(
                onPressed: () {
                  _stopWatchTimer.onStopTimer();
                  _stopWatchTimer.secondTime.listen((value) => print('secondTime $value'));
                },
                child: Text('Stop'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
