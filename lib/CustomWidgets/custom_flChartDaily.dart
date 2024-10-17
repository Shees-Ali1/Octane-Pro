import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:octane_pro/untils/utils.dart';

class CustomLineChartDaily extends StatefulWidget {
  const CustomLineChartDaily({super.key});

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
    return Stack(
      children: <Widget>[
        SizedBox(
          height: 100.h,
          width: 350.w,
          child: AspectRatio(
            aspectRatio: 2.5,
            child: Padding(
              padding: const EdgeInsets.only(
                right: 18,
                left: 12,
                top: 24,
                bottom: 12,
              ),
              child: LineChart(
                showAvg ? avgData() : mainData(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    Widget text;
    int hour = value.toInt();
    if (hour >= 0 && hour < 13) {
      text = Text(
        hour.toString(), // Display hour on the X-axis
        style: AppColors.small.copyWith(fontSize: 14.sp, color: AppColors.primaryTextColor),
      );
    } else {
      text = Text('', style: AppColors.small.copyWith(fontSize: 14.sp, color: AppColors.primaryTextColor));
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  LineChartData mainData() {
    return LineChartData(

      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30.h,
            interval: 1, // Set interval to 1 for hourly
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 12, // Change maxX to 12 for 12-hour display
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 12), // Example data point
            FlSpot(1, 3),
            FlSpot(2, 5),
            FlSpot(3, 4),
            FlSpot(4, 6),
            FlSpot(5, 3),
            FlSpot(6, 4),
            FlSpot(7, 5),
            FlSpot(8, 2),
            FlSpot(9, 4),
            FlSpot(10, 3),
            FlSpot(11, 6),
            FlSpot(12, 6),
          ],
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((color) => color.withOpacity(0.7)).toList(),
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
          spots: const [
            FlSpot(0, 3),
            FlSpot(1, 3),
            FlSpot(2, 3),
            FlSpot(3, 3),
            FlSpot(4, 3),
            FlSpot(5, 3),
            FlSpot(6, 3),
            FlSpot(7, 3),
            FlSpot(8, 3),
            FlSpot(9, 3),
            FlSpot(10, 3),
            FlSpot(11, 3),
            FlSpot(12, 5),
          ],
          isCurved: true,
          gradient: LinearGradient(colors: [
            ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!,
            ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!,
          ]),
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
