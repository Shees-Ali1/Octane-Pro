import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:octane_pro/untils/utils.dart';

class CustomLineChartWeek extends StatefulWidget {
  const CustomLineChartWeek({super.key});

  @override
  State<CustomLineChartWeek> createState() => _CustomLineChartWeekState();
}

class _CustomLineChartWeekState extends State<CustomLineChartWeek> {
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
      case 0:
        text = Text('Mon', style: AppColors.small.copyWith(fontSize: 14.sp, color: AppColors.primaryTextColor));
        break;
      case 1:
        text = Text('Tue', style: AppColors.small.copyWith(fontSize: 14.sp, color: AppColors.primaryTextColor));
        break;
      case 2:
        text = Text('Wed', style: AppColors.small.copyWith(fontSize: 14.sp, color: AppColors.primaryTextColor));
        break;
      case 3:
        text = Text('Thu', style: AppColors.small.copyWith(fontSize: 14.sp, color: AppColors.primaryTextColor));
        break;
      case 4:
        text = Text('Fri', style: AppColors.small.copyWith(fontSize: 14.sp, color: AppColors.primaryTextColor));
        break;
      case 5:
        text = Text('Sat', style: AppColors.small.copyWith(fontSize: 14.sp, color: AppColors.primaryTextColor));
        break;
      case 6:
        text = Text('Sun', style: AppColors.small.copyWith(fontSize: 14.sp, color: AppColors.primaryTextColor));
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
      minX: -1,
      maxX: 7, // Change maxX to 7 for a week display
      minY: 0,
      maxY: 10, // Adjust as needed for your data range
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 2), // Monday
            FlSpot(1, 3), // Tuesday
            FlSpot(2, 5), // Wednesday
            FlSpot(3, 4), // Thursday
            FlSpot(4, 6), // Friday
            FlSpot(5, 3), // Saturday
            FlSpot(6, 5), // Sunday
          ],
          isCurved: true,
          gradient: LinearGradient(colors: gradientColors),
          barWidth: 2,
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
      minX: 0,
      maxX: 7,
      minY: 0,
      maxY: 10, // Adjust as needed
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3), // Monday
            FlSpot(1, 3),
            FlSpot(2, 3),
            FlSpot(3, 3),
            FlSpot(4, 3),
            FlSpot(5, 3),
            FlSpot(6, 3), // Sunday
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
