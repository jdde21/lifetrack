import 'package:fl_chart/fl_chart.dart';
import 'package:lifetrack/graphs/additional_resources/indicator.dart';
import 'package:flutter/material.dart';

class PieChartSample1 extends StatefulWidget {
  final Map<String, dynamic> percentages;
  const PieChartSample1({super.key, required this.percentages});

  @override
  State<StatefulWidget> createState() => PieChartSample1State();
}

class PieChartSample1State extends State<PieChartSample1> {
  int touchedIndex = -1;

  static const Color primary = contentColorCyan;
  static const Color menuBackground = Color(0xFF090912);
  static const Color itemsBackground = Color(0xFF1B2339);
  static const Color pageBackground = Color(0xFF282E45);
  static const Color mainTextColor1 = Colors.white;
  static const Color mainTextColor2 = Colors.white70;
  static const Color mainTextColor3 = Colors.white38;
  static const Color mainGridLineColor = Colors.white10;
  static const Color borderColor = Colors.white54;
  static const Color gridLinesColor = Color(0x11FFFFFF);

  static const Color contentColorBlack = Colors.black;
  static const Color contentColorWhite = Colors.white;
  static const Color contentColorBlue = Color(0xFF2196F3);
  static const Color contentColorYellow = Color(0xFFFFC300);
  static const Color contentColorOrange = Color(0xFFFF683B);
  static const Color contentColorGreen = Color(0xFF3BFF49);
  static const Color contentColorPurple = Color(0xFF6E1BFF);
  static const Color contentColorPink = Color(0xFFFF3AF2);
  static const Color contentColorRed = Color(0xFFE80054);
  static const Color contentColorCyan = Color(0xFF50E4FF);

  @override
  Widget build(BuildContext context) {
    List<String> keys = widget.percentages.keys.toList();
    const List<Color> pieChartColors = [
        Color(0xFF2196F3),
        Color(0xFF90CAF9),
        Color(0xFFB3E5FC),
        Color(0xFF64B5F6),
        Color(0xFF42A5F5),
      ];
    

    return AspectRatio(
      aspectRatio: 1.3,
      child: Column(
        children: <Widget>[
          const SizedBox(height: 28),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex =
                            pieTouchResponse
                                .touchedSection!
                                .touchedSectionIndex;
                      });
                    },
                  ),
                  startDegreeOffset: 180,
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 1,
                  centerSpaceRadius: 0,
                  sections: showingSections(widget.percentages),
                ),
              ),
            ),
          ),
          SizedBox(height: 25),
          Padding(padding: EdgeInsets.only(left: 80), child: Container(
                height: 50,
                width: double.infinity,
                child: Wrap(
                  runSpacing: 8,
                  spacing: 15,
                  direction: Axis.horizontal,
                  children: List.generate(keys.length, (i) {
                    return Indicator(
                      color: pieChartColors[i],
                      text: keys[i],
                      isSquare: false,
                      size: touchedIndex == i ? 18 : 16,
                      textColor:
                          touchedIndex == i ? Colors.blue : Colors.black,
                    );
                  }),
                ),
              ))
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(Map<String, dynamic> percentages) {
    List<String> keys = percentages.keys.toList();
    return List.generate(keys.length, (i) {
      final isTouched = i == touchedIndex;
      const List<Color> pieChartColors = [
        Color(0xFF2196F3),
        Color(0xFF90CAF9),
        Color(0xFFB3E5FC),
        Color(0xFF64B5F6),
        Color(0xFF42A5F5),
      ];


      return PieChartSectionData(
        color: pieChartColors[i],
        value: double.parse(percentages[keys[i]]),
        title: '',
        radius: 80,
        titlePositionPercentageOffset: 0.55,
        borderSide:
            isTouched
                ? const BorderSide(color: contentColorWhite, width: 6)
                : BorderSide(color: contentColorWhite.withValues(alpha: 0)),
      );
    });
  }
}
