import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:octane_pro/CustomWidgets/CustomInputField.dart';
import 'package:octane_pro/CustomWidgets/custom_flChart-week.dart';
import 'package:octane_pro/CustomWidgets/custom_flChart_month.dart';
import 'package:octane_pro/untils/assetImages.dart';
import 'package:octane_pro/untils/utils.dart';
import '../../CustomWidgets/custom_flChartDaily.dart';
import '../../GetxControllers/dataController.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>
    with TickerProviderStateMixin {
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

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _opacityAnimation =
        Tween<double>(begin: 0.1, end: 1.0).animate(_controller);
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
    _tabController = TabController(length: 4, vsync: this);

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
  final DataController dataController = Get.put(DataController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      body: SafeArea(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 16.0.h, horizontal: 16.0.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
              width: 319.w,
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey
                    .shade800, // Background color for the tab bar container
                borderRadius: BorderRadius.circular(
                    10), // Rounding the corners of the container
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      8), // Rounded corners for the selected tab
                  color: Colors
                      .grey.shade600, // Background color for the selected tab
                ),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize
                    .tab, // Ensure indicator spans the entire tab
                labelColor: AppColors
                    .primaryTextColor, // Text color for the selected tab
                unselectedLabelColor:
                    Colors.grey.shade400, // Text color for the unselected tabs
                labelStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Jost"), // Style for selected tab
                unselectedLabelStyle:
                    TextStyle(fontSize: 12.sp), // Style for unselected tabs
                tabs: [
                  Container(
                    width: 102.w,
                    height: 36.h,
                    alignment: Alignment.center,
                    child: Tab(text: 'Live'),
                  ),
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
            SizedBox(height: 22.h), // TabBarView with animation
            Expanded(
              child: PageTransitionSwitcher(
                duration: const Duration(milliseconds: 300),
                reverse: _tabController.indexIsChanging,
                transitionBuilder:
                    (child, primaryAnimation, secondaryAnimation) {
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
                    // SingleChildScrollView(
                    //   child: Column(
                    //     children: [
                    //       ElevatedButton(
                    //           onPressed: () {
                    //             List<int> data = [
                    //               0,
                    //               1,
                    //               21,
                    //               123,
                    //               1267835
                    //             ]; // Your data
                    //             dataController.sendDataAsString(data);
                    //           },
                    //           child: Text('Send Data')),
                    //
                    //       Container(
                    //         width: 162.w,
                    //         height: 181.h,
                    //         decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(20),
                    //           color: Color.fromRGBO(34, 34, 34, 1),
                    //         ),
                    //         child: Column(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           children: [
                    //             // Petrol Text
                    //             Container(
                    //               width: Get.width * 0.3,
                    //               child: Row(
                    //                 mainAxisAlignment:
                    //                     MainAxisAlignment.spaceEvenly,
                    //                 children: [
                    //                   Row(
                    //                     mainAxisAlignment:
                    //                         MainAxisAlignment.center,
                    //                     crossAxisAlignment:
                    //                         CrossAxisAlignment.center,
                    //                     children: [
                    //                       Image.asset(
                    //                         AppImages.petrol,
                    //                         width: 25.w,
                    //                         height: 28.h,
                    //                       ),
                    //                       Text(
                    //                         '1',
                    //                         style: AppColors.subtitleStyle
                    //                             .copyWith(
                    //                                 fontSize: 20.sp,
                    //                                 color: Colors.red),
                    //                       )
                    //                     ],
                    //                   ),
                    //                   Text(
                    //                     "Petrol",
                    //                     style: AppColors.subtitleStyle.copyWith(
                    //                         fontSize: 20.sp, color: Colors.red),
                    //                   )
                    //                 ],
                    //               ),
                    //             ),
                    //
                    //             // first Row
                    //             Container(
                    //               width: 162.w,
                    //               height: 45.h,
                    //               decoration: BoxDecoration(
                    //                   color: Colors.red,
                    //                   borderRadius: BorderRadius.only(
                    //                     topLeft: Radius.circular(20),
                    //                     topRight: Radius.circular(20),
                    //                   )),
                    //               child: Row(
                    //                 mainAxisAlignment:
                    //                     MainAxisAlignment.spaceBetween,
                    //                 children: [
                    //                   Container(
                    //                     width: 48.w,
                    //                     height: 45.h,
                    //                     decoration: BoxDecoration(
                    //                         color:
                    //                             Color.fromRGBO(38, 144, 234, 1),
                    //                         borderRadius: BorderRadius.only(
                    //                             topLeft: Radius.circular(20))),
                    //                     // color: Color.fromRGBO(38, 144, 234, 1),
                    //                     child: Center(
                    //                       child: Text(
                    //                         "Price",
                    //                         style: AppColors.small.copyWith(
                    //                             fontSize: 14.sp,
                    //                             color:
                    //                                 AppColors.primaryTextColor),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   Container(
                    //                     width: 114.w,
                    //                     height: 45.h,
                    //                     decoration: BoxDecoration(
                    //                         color: Colors.red,
                    //                         borderRadius: BorderRadius.only(
                    //                             topRight: Radius.circular(20))),
                    //                     // color: Color.fromRGBO(38, 144, 234, 1),
                    //                     child: Center(
                    //                       child: Text(
                    //                         "248.99",
                    //                         style: AppColors.subtitleStyle
                    //                             .copyWith(
                    //                                 fontSize: 22.sp,
                    //                                 color: AppColors
                    //                                     .primaryTextColor),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //
                    //             // Scnd
                    //             Container(
                    //               width: 162.w,
                    //               height: 45.h,
                    //               decoration: BoxDecoration(
                    //                 color: Colors.red,
                    //               ),
                    //               child: Row(
                    //                 mainAxisAlignment:
                    //                     MainAxisAlignment.spaceBetween,
                    //                 children: [
                    //                   Container(
                    //                     width: 48.w,
                    //                     height: 45.h,
                    //                     decoration: BoxDecoration(
                    //                       color:
                    //                           Color.fromRGBO(38, 144, 234, 1),
                    //                     ),
                    //                     // color: Color.fromRGBO(38, 144, 234, 1),
                    //                     child: Center(
                    //                       child: Text(
                    //                         "Sale",
                    //                         style: AppColors.small.copyWith(
                    //                             fontSize: 14.sp,
                    //                             color:
                    //                                 AppColors.primaryTextColor),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   Container(
                    //                     width: 114.w,
                    //                     height: 45.h,
                    //                     decoration: BoxDecoration(
                    //                       color: Colors.red,
                    //                     ),
                    //                     // color: Color.fromRGBO(38, 144, 234, 1),
                    //                     child: Center(
                    //                       child: Text(
                    //                         "12,049",
                    //                         style: AppColors.subtitleStyle
                    //                             .copyWith(
                    //                                 fontSize: 22.sp,
                    //                                 color: AppColors
                    //                                     .primaryTextColor),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //
                    //             // 3rd
                    //             Container(
                    //               width: 162.w,
                    //               height: 45.h,
                    //               decoration: BoxDecoration(
                    //                   color: Colors.red,
                    //                   borderRadius: BorderRadius.only(
                    //                     bottomLeft: Radius.circular(20),
                    //                     bottomRight: Radius.circular(20),
                    //                   )),
                    //               child: Row(
                    //                 mainAxisAlignment:
                    //                     MainAxisAlignment.spaceBetween,
                    //                 children: [
                    //                   Container(
                    //                     width: 48.w,
                    //                     height: 45.h,
                    //                     decoration: BoxDecoration(
                    //                         color:
                    //                             Color.fromRGBO(38, 144, 234, 1),
                    //                         borderRadius: BorderRadius.only(
                    //                             bottomLeft:
                    //                                 Radius.circular(20))),
                    //                     // color: Color.fromRGBO(38, 144, 234, 1),
                    //                     child: Center(
                    //                       child: Text(
                    //                         "Ltr",
                    //                         style: AppColors.small.copyWith(
                    //                             fontSize: 14.sp,
                    //                             color:
                    //                                 AppColors.primaryTextColor),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   Container(
                    //                     width: 114.w,
                    //                     height: 45.h,
                    //                     decoration: BoxDecoration(
                    //                         color: Colors.red,
                    //                         borderRadius: BorderRadius.only(
                    //                             bottomRight:
                    //                                 Radius.circular(20))),
                    //                     // color: Color.fromRGBO(38, 144, 234, 1),
                    //                     child: Center(
                    //                       child: Text(
                    //                         "18.99",
                    //                         style: AppColors.subtitleStyle
                    //                             .copyWith(
                    //                                 fontSize: 22.sp,
                    //                                 color: AppColors
                    //                                     .primaryTextColor),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),

                    // Weekly Graph
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 22.h),
                          ...fuels.map((fuel) {
                            return Container(
                              width: 327.w,
                              height: 158.h,
                              margin: const EdgeInsets.only(
                                  bottom: 10), // 10 pixels bottom margin
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(34, 34, 34, 1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(width: 1),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          fuel[0], // Fuel name
                                          style:
                                              AppColors.headingStyle.copyWith(
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: fuel[1], // Price
                                                    style: AppColors
                                                        .subtitleStyle
                                                        .copyWith(
                                                      color: AppColors
                                                          .primaryTextColor,
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' rs',
                                                    style: AppColors
                                                        .subtitleStyle
                                                        .copyWith(
                                                      color: AppColors
                                                          .primaryTextColor,
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
                                                    style: AppColors
                                                        .subtitleStyle
                                                        .copyWith(
                                                      color: AppColors
                                                          .primaryTextColor,
                                                      fontSize: 20.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' ltr',
                                                    style: AppColors
                                                        .subtitleStyle
                                                        .copyWith(
                                                      color: AppColors
                                                          .primaryTextColor,
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
                                      child:
                                          const CustomLineChartWeek()), // Custom chart for each fuel type
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
                              margin: const EdgeInsets.only(
                                  bottom: 10), // 10 pixels bottom margin
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(34, 34, 34, 1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(width: 1),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          fuel[0], // Fuel name
                                          style:
                                              AppColors.headingStyle.copyWith(
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: fuel[1], // Price
                                                    style: AppColors
                                                        .subtitleStyle
                                                        .copyWith(
                                                      color: AppColors
                                                          .primaryTextColor,
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' rs',
                                                    style: AppColors
                                                        .subtitleStyle
                                                        .copyWith(
                                                      color: AppColors
                                                          .primaryTextColor,
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
                                                    style: AppColors
                                                        .subtitleStyle
                                                        .copyWith(
                                                      color: AppColors
                                                          .primaryTextColor,
                                                      fontSize: 20.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' ltr',
                                                    style: AppColors
                                                        .subtitleStyle
                                                        .copyWith(
                                                      color: AppColors
                                                          .primaryTextColor,
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
                                      child:
                                          const CustomLineChartMonth()), // Custom chart for each fuel type
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                    SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 22.h),
                          ...fuels.map((fuel) {
                            return Container(
                              width: 327.w,
                              height: 158.h,
                              margin: const EdgeInsets.only(
                                  bottom: 10), // 10 pixels bottom margin
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(34, 34, 34, 1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(width: 1),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          fuel[0], // Fuel name
                                          style:
                                              AppColors.headingStyle.copyWith(
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: fuel[1], // Price
                                                    style: AppColors
                                                        .subtitleStyle
                                                        .copyWith(
                                                      color: AppColors
                                                          .primaryTextColor,
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' rs',
                                                    style: AppColors
                                                        .subtitleStyle
                                                        .copyWith(
                                                      color: AppColors
                                                          .primaryTextColor,
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
                                                    style: AppColors
                                                        .subtitleStyle
                                                        .copyWith(
                                                      color: AppColors
                                                          .primaryTextColor,
                                                      fontSize: 20.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' ltr',
                                                    style: AppColors
                                                        .subtitleStyle
                                                        .copyWith(
                                                      color: AppColors
                                                          .primaryTextColor,
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
                                      child:
                                          const CustomLineChartMonth()), // Custom chart for each fuel type
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
