import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartSample6 extends StatelessWidget {
  final List<dynamic> sets;
  final List<dynamic> reps;
  final List<dynamic> weights;
  final List<dynamic> dates;

  const BarChartSample6({
    super.key,
    required this.sets,
    required this.reps,
    required this.weights,
    required this.dates,
  });

  final pilateColor = Colors.purple;
  final cyclingColor = Colors.cyan;
  final quickWorkoutColor = Colors.blue;
  final betweenSpace = 0.2;

  BarChartGroupData generateGroupData(
    int x,
    double pilates,
    double quickWorkout,
    double cycling,
  ) {
    return BarChartGroupData(
      x: x,
      groupVertically: true,
      barRods: [
        BarChartRodData(fromY: 0, toY: pilates, color: pilateColor, width: 5),
        BarChartRodData(
          fromY: pilates + betweenSpace,
          toY: pilates + betweenSpace + quickWorkout,
          color: quickWorkoutColor,
          width: 5,
        ),
        BarChartRodData(
          fromY: pilates + betweenSpace + quickWorkout + betweenSpace,
          toY: pilates + betweenSpace + quickWorkout + betweenSpace + cycling,
          color: cyclingColor,
          width: 5,
        ),
      ],
    );
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 8);
    String text;
    print(value);
    text = dates[value.toInt()];
    print(dates);
    print(text);
    return Padding(
      padding: EdgeInsets.only(top: 13),
      child: SideTitleWidget(
        meta: meta,
        child: Transform.rotate(
          angle: -1.5708,
          child: Text(text, style: style),
        ),
      ),
    );
  }

  List<BarChartGroupData> finalData() {
    List<BarChartGroupData> data = [];
    int numberOfElements = sets.length;
    print(numberOfElements);
    for (int i = 0; i < numberOfElements; i++) {
      data.add(
        generateGroupData(
          i,
          double.parse(sets[i]),
          double.parse(reps[i]),
          double.parse(weights[i]),
        ),
      );
    }
    return data;
  }

  List<HorizontalLine> horizontalLineMaker(double intervals, int quantity) {
    List<HorizontalLine> lines = [];
    for (int i = 0; i < quantity; i++) {
      lines.add(
        HorizontalLine(
          y: intervals * (i + 1),
          color: pilateColor,
          strokeWidth: 1,
          dashArray: [20, 4],
        ),
      );
    }
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 200,
            child: AspectRatio(
              aspectRatio: 1.25,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.start,
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: bottomTitles,
                        reservedSize: 35,
                      ),
                    ),
                  ),
                  barTouchData: const BarTouchData(enabled: false),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  barGroups: finalData(),
                  maxY: 120,
                  
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
