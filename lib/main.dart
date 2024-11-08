import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:octane_pro/GetxControllers/AuthController.dart';
import 'package:octane_pro/GetxControllers/Sale-Controller/SaleSummaryController.dart';

import 'GetxControllers/Sale-Controller/FuelDataController.dart';
import 'GetxControllers/dataController.dart';
import 'Screens/Auth/login_page.dart';
import 'Screens/Auth/splash_screen.dart';
import 'Screens/HomePage/home_Page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase here
  Get.put(Authcontroller());
  Get.put(DataController());
  // Get.put(SaleSummaryController());
  Get.put(FuelDataController());

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Ensure design size fits your UI
      child: GetMaterialApp(
        title: 'Octane Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
