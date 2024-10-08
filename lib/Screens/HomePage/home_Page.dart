import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:octane_pro/CustomWidgets/CustomInputField.dart';
import 'package:octane_pro/GetxControllers/Sale-Controller/SaleSummaryController.dart';
import 'package:octane_pro/untils/assetImages.dart';
import 'package:octane_pro/untils/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  // New Animation for Sale Summary
  late AnimationController _summaryController;
  late Animation<double> _scaleAnimation;
  final SaleSummaryController saleSummaryController = Get.put(SaleSummaryController());
  @override
  void initState() {
    super.initState();
    saleSummaryController.listenForSaleSummary();
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

    // Start the animations
    _controller.forward();
    _summaryController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _summaryController.dispose();
    super.dispose();
  }
  List<Map<String, dynamic>> fuelData = [
    {"type": "Petrol", "liter": 2200, "price": 1234567},
    {"type": "Diesel", "liter": 1500, "price": 1234567},
    {"type": "HOBC", "liter": 1800, "price": 1234567},
  ];

  final List<Map<String, dynamic>> fuelStockData = [
    {"type": "Petrol", "liter": 2200, "price": 1234.56, "progress": 0.9},
    {"type": "Diesel", "liter": 1500, "price": 987.65, "progress": 0.7},
    {"type": "HOBC", "liter": 1800, "price": 543.21, "progress": 0.5},
  ];

  final List<Map<String, String>> items = [
    {"title": "Store", "image": AppImages.shop, "count": "102,341"},
    {"title": "Food", "image": AppImages.food, "count": "45,123"},
    {"title": "Toilet", "image": AppImages.toilet, "count": "10,00"},
  ];

  // Format price function
  // Format price function
  String formatPrice(double price) {
    final formatter = NumberFormat('#,##0'); // Adjust this format pattern if you want decimals
    return formatter.format(price);
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0.h, horizontal: 16.0.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SvgPicture.asset(
                          AppIcons.drawer,
                          height: 30.h,
                          width: 30.w,
                          fit: BoxFit.fill,
                        )
                      ],
                    ),
                  ),
                ),

                // SALE SUMMARY
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: saleSummaryController.getSaleSummaryStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No sales data available.'));
                      }

                      final List<Map<String, dynamic>> fuelData = snapshot.data!;

                      // Initialize totals for petrol, diesel, and hobc
                      double petrolTotalLiters = 0.0;
                      double petrolTotalPrice = 0.0;
                      double dieselTotalLiters = 0.0;
                      double dieselTotalPrice = 0.0;
                      double hobcTotalLiters = 0.0;
                      double hobcTotalPrice = 0.0;

                      // Calculate totals
                      for (var fuel in fuelData) {
                        String type = fuel['type'] as String; // Cast to String
                        double liters = (fuel['liter'] as num?)?.toDouble() ?? 0.0; // Cast to double
                        double price = (fuel['price'] as num?)?.toDouble() ?? 0.0; // Cast to double

                        if (type == 'Petrol') {
                          petrolTotalLiters += liters;
                          petrolTotalPrice += price;
                        } else if (type == 'Diesel') {
                          dieselTotalLiters += liters;
                          dieselTotalPrice += price;
                        } else if (type == 'Hobc') {
                          hobcTotalLiters += liters;
                          hobcTotalPrice += price;
                        }
                      }

                      // Create a list to display
                      final totals = [
                        {'type': 'Petrol', 'liters': petrolTotalLiters, 'price': petrolTotalPrice},
                        {'type': 'Diesel', 'liters': dieselTotalLiters, 'price': dieselTotalPrice},
                        {'type': 'Hobc', 'liters': hobcTotalLiters, 'price': hobcTotalPrice},
                      ];

                      return Container(
                        padding: EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color.fromRGBO(30, 31, 35, 1),
                              Color.fromRGBO(9, 10, 10, 1),
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Sale Summary",
                              style: AppColors.headingStyle.copyWith(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.summryRed,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Column(
                              children: totals.map((fuel) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 10.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          fuel['type'] as String, // Cast to String
                                          textAlign: TextAlign.center,
                                          style: AppColors.small.copyWith(
                                            fontSize: 16.sp,
                                            color: AppColors.primaryTextColor,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 97.w,
                                        height: 33.h,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "${fuel['liters']}", // Show liters
                                                  style: AppColors.subtitleStyle.copyWith(
                                                    fontSize: 20.sp,
                                                    color: AppColors.primaryTextColor,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: " ltr",
                                                  style: AppColors.subtitleStyle.copyWith(
                                                    fontSize: 10.sp,
                                                    color: AppColors.primaryTextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 7.w),
                                      Container(
                                        width: 101.w,
                                        height: 33.h,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: formatPrice(fuel['price'] as double), // Cast to double
                                                  style: AppColors.headingStyle.copyWith(
                                                    fontSize: 16.sp,
                                                    color: AppColors.primaryTextColor,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: " rs.",
                                                  style: AppColors.small.copyWith(
                                                    fontSize: 10.sp,
                                                    color: AppColors.primaryTextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 20.w),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 10.h),

                // Stock
                Center(
                  child: Text(
                    "Stock",
                    style: AppColors.headingStyle.copyWith(fontSize: 20.sp, color: Colors.red),
                  ),
                ),
                SizedBox(height: 5.h),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: fuelStockData.map((fuel) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: MyCircularContainer(
                            progressValue: fuel["progress"]?.toDouble() ?? 0.0,
                            petrolLiter: fuel["liter"]?.toInt() ?? 0,
                            petrolPrice: fuel["price"]?.toDouble() ?? 0.0,
                            fuelType: fuel["type"] ?? '',
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(height: 31.h),

                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: EdgeInsets.all(7),
                    width: Get.width,
                    height: 158.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color.fromRGBO(30, 31, 35, 1),
                          Color.fromRGBO(9, 10, 10, 1),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Other Sales",
                          style: AppColors.headingStyle.copyWith(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.summryRed,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: items.map((item) {
                              return Container(
                                width: 118.w,
                                height: 90.h,
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(34, 34, 34, 1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          item["image"]!,
                                          height: 19.h,
                                          width: 19.w,
                                          fit: BoxFit.fill,
                                        ),
                                        SizedBox(width: 5.w),
                                        Text(
                                          item["title"]!,
                                          style: AppColors.small.copyWith(
                                            fontSize: 20.sp,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 118.w,
                                      height: 45.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.red
                                      ),
                                      child: Center(
                                        child: Text(
                                          item["count"]!,
                                          style: AppColors.headingStyle.copyWith(
                                            fontSize: 22.sp,
                                            color: AppColors.primaryTextColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class MyCircularContainer extends StatelessWidget {
  final double progressValue; // Example progress value
  final int petrolLiter; // Example petrol liter
  final double petrolPrice; // Example petrol price
  final String fuelType; // Fuel type

  MyCircularContainer({
    required this.progressValue,
    required this.petrolLiter,
    required this.petrolPrice,
    required this.fuelType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      child: Center(
        child: Container(
          width: 150.w,
          height: 150.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromRGBO(42, 42, 42, 1),
          ),
          child: Center(
            child: Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromRGBO(55, 55, 55, 1),
              ),
              child: Center(
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            fuelType,
                            style: AppColors.headingStyle.copyWith(
                              color: Colors.white,
                              fontSize: 14.sp,
                            ),
                          ),
                          Text(
                            "$petrolLiter ltr",
                            style: AppColors.subtitleStyle.copyWith(
                              color: Colors.white,
                              fontSize: 12.sp,
                            ),
                          ),
                          Text(
                            "${petrolPrice.toStringAsFixed(2)} rs",
                            style: AppColors.small.copyWith(
                              color: Colors.white,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 84.w,
                        height: 84.w,
                        child: CircularProgressIndicator(
                          value: progressValue.isNaN ? 0.0 : progressValue, // Prevent NaN
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                          strokeWidth: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

