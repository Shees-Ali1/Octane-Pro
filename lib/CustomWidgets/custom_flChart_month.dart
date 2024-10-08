import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:octane_pro/untils/utils.dart';

class CustomLineChartMonth extends StatefulWidget {
  const CustomLineChartMonth({super.key});

  @override
  State<CustomLineChartMonth> createState() => _CustomLineChartMonthState();
}

class _CustomLineChartMonthState extends State<CustomLineChartMonth> {
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
          height: 83.h,
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
    int day = value.toInt();
    switch (day) {
      case 1:
        text = Text('1', style: AppColors.small.copyWith(fontSize: 14.sp, color: AppColors.primaryTextColor));
        break;
      case 5:
        text = Text('5', style: AppColors.small.copyWith(fontSize: 14.sp, color: AppColors.primaryTextColor));
        break;
      case 10:
        text = Text('10', style: AppColors.small.copyWith(fontSize: 14.sp, color: AppColors.primaryTextColor));
        break;
      case 15:
        text = Text('15', style: AppColors.small.copyWith(fontSize: 14.sp, color: AppColors.primaryTextColor));
        break;
      case 20:
        text = Text('20', style: AppColors.small.copyWith(fontSize: 14.sp, color: AppColors.primaryTextColor));
        break;
      case 25:
        text = Text('25', style: AppColors.small.copyWith(fontSize: 14.sp, color: AppColors.primaryTextColor));
        break;
      case 30:
        text = Text('30', style: AppColors.small.copyWith(fontSize: 14.sp, color: AppColors.primaryTextColor));
        break;

      default:
        text = Text('', style: AppColors.small.copyWith(fontSize: 14.sp, color: AppColors.primaryTextColor)); // Empty for other values
        break;
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
            interval: 1, // Set interval to 1 for daily
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      minX: 1,
      maxX: 31, // Change maxX to 31 for a month display
      minY: 0,
      maxY: 10, // Adjust as needed for your data range
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(1, 2),  // Day 1
            FlSpot(5, 3),  // Day 5
            FlSpot(10, 5), // Day 10
            FlSpot(15, 4), // Day 15
            FlSpot(20, 6), // Day 20
            FlSpot(25, 3), // Day 25
            FlSpot(31, 5), // Day 31
          ],
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
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
      minX: 1,
      maxX: 31,
      minY: 0,
      maxY: 10, // Adjust as needed
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(1, 3), // Day 1
            FlSpot(5, 3),
            FlSpot(10, 3),
            FlSpot(15, 3),
            FlSpot(20, 3),
            FlSpot(25, 3),
            FlSpot(31, 3), // Day 31
          ],
          isCurved: true,
          gradient: LinearGradient(colors: [
            ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!,
            ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!,
          ]),
          barWidth: 5,
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
