import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart'; // For formatting the timestamp

class CustomLineChartDaily extends StatefulWidget {
  final List<FlSpot> dailyData;

  const CustomLineChartDaily({super.key, required this.dailyData});

  @override
  State<CustomLineChartDaily> createState() => _CustomLineChartDailyState();
}

class _CustomLineChartDailyState extends State<CustomLineChartDaily> {
  List<Color> gradientColors = [
    const Color.fromRGBO(255, 62, 71, 1),
    const Color.fromRGBO(255, 96, 96, 1),
  ];

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    print(widget.dailyData);
    return SingleChildScrollView( // Make the content scrollable
      child: Column(  // Wrap with Column to allow flexibility
        children: <Widget>[
          SizedBox(
            height: 120.h,
            width: 350.w,
            child: AspectRatio(
              aspectRatio: 2.5,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 33,
                  left: 22,
                  top: 11,
                  bottom: 0,
                ),
                child: LineChart(
                  showAvg ? avgData() : mainData(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    String formattedTime = DateFormat('h:mm a').format(timestamp);

    Set<String> timeSet = {};
    if (timeSet.contains(formattedTime)) {
      return Container();
    } else {
      timeSet.add(formattedTime);
    }

    return Column(
      children: [
        Text(
          formattedTime.split(" ")[0],
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
        Text(
          formattedTime.split(" ")[1],
          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
        ),
      ],
    );
  }

  LineChartData mainData() {
    double maxY = 3000.0;

    return LineChartData(
      gridData: FlGridData(show: false, drawHorizontalLine: false),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40.h,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
            interval: 500,
            reservedSize: 40.w,
            getTitlesWidget: (value, meta) => Text(
              value.toStringAsFixed(0),
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
          ),
        ),
      ),
      borderData: FlBorderData(show: false, border: Border.all(color: Colors.grey)),
      minX: 0,
      maxX: widget.dailyData.length.toDouble(),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: widget.dailyData,
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((color) => color.withOpacity(0.4)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 12,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: widget.dailyData.map((spot) => FlSpot(spot.x, 3)).toList(),
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!,
            ],
          ),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!.withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

