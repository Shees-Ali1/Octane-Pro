import 'package:animations/animations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:octane_pro/CustomWidgets/CustomInputField.dart';
import 'package:octane_pro/CustomWidgets/custom_flChart-week.dart';
import 'package:octane_pro/CustomWidgets/custom_flChart_month.dart';
import 'package:octane_pro/GetxControllers/graphController.dart';
import 'package:octane_pro/untils/assetImages.dart';
import 'package:octane_pro/untils/utils.dart';
import '../../CustomWidgets/custom_flChartDaily.dart';

class ListingScreen extends StatefulWidget {
  const ListingScreen({super.key});

  @override
  State<ListingScreen> createState() => _ListingScreenState();
}

class _ListingScreenState extends State<ListingScreen> with TickerProviderStateMixin {
  final GraphDataController graphDataController =
  Get.put(GraphDataController());
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  // New Animation for Sale Summary
  late AnimationController _summaryController;
  late Animation<double> _scaleAnimation;

  // Tab bar controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    graphDataController.fetchFuelData();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.1, end: 1.0).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Initialize the new animation for the Sale Summary
    _summaryController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _summaryController, curve: Curves.easeInOut),
    );

    // Initialize the TabController with the number of tabs
    _tabController = TabController(length: 3, vsync: this);

    // Start the animations
    _controller.forward();
    _summaryController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _summaryController.dispose();
    _tabController.dispose(); // Don't forget to dispose the TabController
    super.dispose();
  }

  List<List<String>> fuels = [
    ['Petrol', '1,234,567', '2200'],
    ['Diesel', '1,000,000', '1500'],
    ['HOBC', '1,500,000', '1800'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0.h, horizontal: 16.0.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      AppIcons.drawer,
                      height: 30.h,
                      width: 30.w,
                      fit: BoxFit.fill,
                    ),
                    SvgPicture.asset(
                      AppIcons.filter,
                      height: 30.h,
                      width: 30.w,
                      fit: BoxFit.fill,
                    ),
                  ],
                ),
              ),
            ),
            // TabBar at the top
            Container(
              width: 279.w,
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade800, // Background color for the tab bar container
                borderRadius: BorderRadius.circular(10), // Rounding the corners of the container
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), // Rounded corners for the selected tab
                  color: Colors.grey.shade600, // Background color for the selected tab
                ),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab, // Ensure indicator spans the entire tab
                labelColor: AppColors.primaryTextColor, // Text color for the selected tab
                unselectedLabelColor: Colors.grey.shade400, // Text color for the unselected tabs
                labelStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, fontFamily: "Jost"), // Style for selected tab
                unselectedLabelStyle: TextStyle(fontSize: 12.sp), // Style for unselected tabs
                tabs: [
                  Container(
                    width: 102.w,
                    height: 36.h,
                    alignment: Alignment.center,
                    child: Tab(text: 'Day'),
                  ),
                  Container(
                    width: 98.w,
                    height: 36.h,
                    alignment: Alignment.center,
                    child: Tab(text: 'Week'),
                  ),
                  Container(
                    width: 98.w,
                    height: 36.h,
                    alignment: Alignment.center,
                    child: Tab(text: 'Month'),
                  ),
                ],
              ),
            ),

            // TabBarView with animation
            Expanded(
              child: PageTransitionSwitcher(
                duration: const Duration(milliseconds: 300),
                reverse: _tabController.indexIsChanging,
                transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                  const curve = Curves.easeInOut;

                  // Slide transition
                  final slideAnimation = Tween<Offset>(
                    begin: const Offset(2, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: primaryAnimation,
                    curve: curve,
                  ));

                  // Fade transition
                  final fadeAnimation = Tween<double>(
                    begin: 0.1,
                    end: 1.0,
                  ).animate(CurvedAnimation(
                    parent: primaryAnimation,
                    curve: curve,
                  ));

                  return SlideTransition(
                    position: slideAnimation,
                    child: FadeTransition(
                      opacity: fadeAnimation,
                      child: child,
                    ),
                  );
                },
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Daily Graph
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 22.h),
                          ...graphDataController.fuels.map((fuel) {
                            // Determine the correct data to pass based on the fuel type
                            List<FlSpot> fuelData;
                            if (fuel[0] == 'Petrol') {
                              fuelData = graphDataController.petrolData;
                            } else if (fuel[0] == 'Diesel') {
                              fuelData = graphDataController.dieselData;
                            } else if (fuel[0] == 'HOB') {
                              fuelData = graphDataController.hobcData;
                            } else {
                              fuelData = [];
                            }

                            return Container(
                              width: 327.w,
                              height: 160.h,
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(34, 34, 34, 1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(width: 1),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          fuel[0], // Fuel name
                                          style: AppColors.headingStyle.copyWith(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.primaryTextColor,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(4.5),
                                        width: 200.w,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            bottomLeft: Radius.circular(20),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: fuel[1], // Price
                                                    style: AppColors.subtitleStyle.copyWith(
                                                      color: AppColors.primaryTextColor,
                                                      fontSize: 16.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' rs',
                                                    style: AppColors.subtitleStyle.copyWith(
                                                      color: AppColors.primaryTextColor,
                                                      fontSize: 10.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: fuel[2], // Quantity
                                                    style: AppColors.subtitleStyle.copyWith(
                                                      color: AppColors.primaryTextColor,
                                                      fontSize: 20.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' ltr',
                                                    style: AppColors.subtitleStyle.copyWith(
                                                      color: AppColors.primaryTextColor,
                                                      fontSize: 10.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Center(
                                    child: CustomLineChartDaily(dailyData: fuelData), // Use the dynamically passed fuelData
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),



                    // Weekly Graph
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 22.h),
                          ...fuels.map((fuel) {
                            return Container(
                              width: 327.w,
                              height: 158.h,
                              margin: const EdgeInsets.only(bottom: 10), // 10 pixels bottom margin
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(34, 34, 34, 1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(width: 1),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          fuel[0], // Fuel name
                                          style: AppColors.headingStyle.copyWith(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.primaryTextColor,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(4.5),
                                        width: 200.w,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            bottomLeft: Radius.circular(20),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: fuel[1], // Price
                                                    style: AppColors.subtitleStyle.copyWith(
                                                      color: AppColors.primaryTextColor,
                                                      fontSize: 16.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' rs',
                                                    style: AppColors.subtitleStyle.copyWith(
                                                      color: AppColors.primaryTextColor,
                                                      fontSize: 10.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: fuel[2], // Quantity
                                                    style: AppColors.subtitleStyle.copyWith(
                                                      color: AppColors.primaryTextColor,
                                                      fontSize: 20.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' ltr',
                                                    style: AppColors.subtitleStyle.copyWith(
                                                      color: AppColors.primaryTextColor,
                                                      fontSize: 10.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Center(child: const CustomLineChartWeek()), // Custom chart for each fuel type
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                    // Monthly Graph
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 22.h),
                          ...fuels.map((fuel) {
                            return Container(
                              width: 327.w,
                              height: 158.h,
                              margin: const EdgeInsets.only(bottom: 10), // 10 pixels bottom margin
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(34, 34, 34, 1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(width: 1),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          fuel[0], // Fuel name
                                          style: AppColors.headingStyle.copyWith(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.primaryTextColor,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(4.5),
                                        width: 200.w,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            bottomLeft: Radius.circular(20),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: fuel[1], // Price
                                                    style: AppColors.subtitleStyle.copyWith(
                                                      color: AppColors.primaryTextColor,
                                                      fontSize: 16.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' rs',
                                                    style: AppColors.subtitleStyle.copyWith(
                                                      color: AppColors.primaryTextColor,
                                                      fontSize: 10.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: fuel[2], // Quantity
                                                    style: AppColors.subtitleStyle.copyWith(
                                                      color: AppColors.primaryTextColor,
                                                      fontSize: 20.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' ltr',
                                                    style: AppColors.subtitleStyle.copyWith(
                                                      color: AppColors.primaryTextColor,
                                                      fontSize: 10.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Center(child: const CustomLineChartMonth()), // Custom chart for each fuel type
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
