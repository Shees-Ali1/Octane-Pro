import 'package:flutter/material.dart';


class AppColors {// Define the colors
  // splash backgound colroi
  static const Color backgroundColorWhite = Color.fromRGBO(49, 51, 62, 1); // For Dark Blue
  static const Color backgroundColor = Color.fromRGBO(0, 0, 0, 1); // For Dark Blue
  static const Color inputBtnColor = Color.fromARGB(255, 232, 244, 255);
  static const Color borderColor = Color.fromARGB(255, 163, 213, 255);
  static const Color bottomColor = Color(0xFF2690EA); // Powder Blue
  static const Color forgot = Color.fromRGBO(255, 63, 62, 1);
  static const Color summryRed = Color.fromRGBO(255, 62, 71, 1);
  static const Color darkBlack = Color.fromRGBO(9, 10, 10, 1);
  static const Color primaryWhiteText = Color.fromRGBO(255, 255, 255, 1);

  // Define text colors with good contrast
  static const Color primaryTextColor = Colors.white; // For Dark Blue
  static const Color secondaryTextColor = Colors.black; // For Light Blue

  // Define text styles with local font and ScreenUtil for dynamic font sizes
  static TextStyle headingStyle = TextStyle(
    fontFamily: 'Jost',
    color: primaryTextColor,
    fontSize: 24, // Dynamic font size
    fontWeight: FontWeight.bold,
  );

  static TextStyle subtitleStyle = TextStyle(
    fontFamily: 'Jost',
    color: secondaryTextColor,
    fontSize: 18, // Dynamic font size
    fontWeight: FontWeight.w600,
  );

  static TextStyle descriptionStyle = TextStyle(
    fontFamily: 'Jost',
    color: secondaryTextColor,
    fontSize: 14, // Dynamic font size
    fontWeight: FontWeight.normal,
  );

  static TextStyle small = TextStyle(
    fontFamily: 'Jost',
    color: secondaryTextColor,
    fontSize: 10, // Dynamic font size
    fontWeight: FontWeight.normal,
  );
}
