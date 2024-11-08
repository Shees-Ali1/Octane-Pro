import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    getUnitsLength();

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

  bool isGridView = true;
  List<List<String>> fuels = [
    ['Petrol', '1,234,567', '2200'],
    ['Diesel', '1,000,000', '1500'],
    ['HOBC', '1,500,000', '1800'],
  ];

  Future<void> getUnitsLength() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    // Get the units length from Firestore (station1 -> units array)
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('stations')
        .doc('station1')
        .get();

    if (docSnapshot.exists) {
      List<dynamic> units = docSnapshot['units'] ?? [];
     dataController.totalUnits.value = units.length;
    }
  }



  Stream<Map<int, Map<String, dynamic>>> getLatestSalesStream(int nozzleCount) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('sales')
        .doc(currentUserId)
        .collection("station1")
        .orderBy('timestamp', descending: true) // Ensure the most recent sale is first
        .snapshots()
        .map((snapshot) {
      Map<int, Map<String, dynamic>> latestSales = {};

      // Iterate over each document in the snapshot
      for (var doc in snapshot.docs) {
        // Access the 'expenses' array from the document
        List<dynamic> expenses = doc['expenses'] ?? [];

        // Iterate over each expense and filter based on the unitNumber (nozzle)
        for (var expense in expenses) {
          // Ensure unitNumber is parsed correctly, as a valid integer
          int unitNumber = int.tryParse(expense['unitNumber'].toString()) ?? -1;

          // Skip if the unitNumber is invalid (not a valid nozzle number)
          if (unitNumber < 1 || unitNumber > nozzleCount) {
            continue; // Skip this expense if the unitNumber is out of range
          }

          // Check if the 'amount' is a valid value (not '0.00' or '000')
          String amount = expense['amount'] ?? "0.00";
          if (amount == '0.00' || amount == '000') {
            continue; // Skip this expense if the amount is invalid
          }

          // Only store the latest sale for each nozzle
          if (!latestSales.containsKey(unitNumber)) {
            latestSales[unitNumber] = {
              'amount': amount,
              'fuelType': expense['fuelType'] ?? "Unknown", // Default to "Unknown" if null
              'liters': expense['liters'] ?? "0.00", // Default to 0.00 if null
              'profit': expense['profit'] ?? "0.00", // Default to 0.00 if null
              'unitNumber': expense['unitNumber'] ?? unitNumber, // Ensure unitNumber is non-null
            };
          }
        }
      }

      // Ensure that we have data for each nozzle (1 to nozzleCount), default to '0.00' if not found
      for (int i = 1; i <= nozzleCount; i++) {
        if (!latestSales.containsKey(i)) {
          // If there's no data for this nozzle, set default values (all zeros)
          latestSales[i] = {
            'amount': '0.00',
            'fuelType': 'N/A', // Default to "N/A" if not found
            'liters': "0.00",
            'profit': "0.00",
            'unitNumber': i.toString(),
          };
        }
      }
      print("Latest Sales: $latestSales");

      return latestSales;
    });
  }





  final DataController dataController = Get.put(DataController());
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> fuelData = [
      {
        'fuelType': 'Petrol',
        'price': "248.99",
        'sale': "12000.00",
        'liters': "18.00"
      },
      {
        'fuelType': 'Diesel',
        'price': "248.99",
        'sale': "12000.00",
        'liters': "18.00"
      },
      {'fuelType': 'CNG', 'price': "45.99", 'sale': "5000.00", 'liters': "15.00"},
      {'fuelType': 'LPG', 'price': "65.99", 'sale': "7000.00", 'liters': "10.00"},
    ];
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
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isGridView ? Icons.list : Icons.grid_view,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isGridView =
                                        !isGridView; // Toggle the boolean value
                                  });
                                },
                              ),
                            ],
                          ),
                          Obx(()=> dataController.totalUnits.value == 0 // Show loading indicator if nozzleCount is not fetched yet
                              ? Center(child: CircularProgressIndicator(color: Colors.red,))
                              : StreamBuilder<Map<int, Map<String, dynamic>>>(
                            stream: getLatestSalesStream(dataController.totalUnits.value),
                            builder: (context, salesSnapshot) {
                              if (salesSnapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator(color: Colors.red));
                              }

                              if (salesSnapshot.hasError) {
                                return Center(child: Text('Error fetching sales data: ${salesSnapshot.error}', style: TextStyle(
                                    color: Colors.red
                                )));
                              }

                              Map<int, Map<String, dynamic>> salesData = salesSnapshot.data ?? {};

                              // Sort salesData by unitNumber
                              List<int> sortedUnitNumbers = salesData.keys.toList()
                                ..sort((a, b) => a.compareTo(b)); // Sort keys by unitNumber

                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: isGridView
                                    ? GridView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    mainAxisExtent: 133,
                                    crossAxisCount: 2, // 2 cards per row
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 16,
                                  ),
                                  itemCount: dataController.totalUnits.value,
                                  itemBuilder: (context, index) {
                                    int unitNumber = sortedUnitNumbers[index]; // Get unitNumber from sorted list
                                    var unitData = salesData[unitNumber]!;

                                    return FuelCard(
                                      fuelType: unitData['fuelType'] ?? "Petrol",
                                      price: unitData['amount'].toString(),
                                      sale: unitData['fuelType'] == "N/A" ? "N/A" : unitData['fuelType'] == "Petrol" ? "249.95" : "255.56",
                                      liters: unitData['liters'],
                                      unitNumber: unitData['unitNumber'],
                                    );
                                  },
                                )
                                    : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: salesData.length,
                                  itemBuilder: (context, index) {
                                    int unitNumber = sortedUnitNumbers[index]; // Get unitNumber from sorted list
                                    var unitData = salesData[unitNumber]!;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: FuelCard(
                                        fuelType: unitData['fuelType'],
                                        price: unitData['amount'].toString(),
                                        sale: unitData['fuelType'] == "N/A" ? "N/A" : unitData['fuelType'] == "Petrol" ? "249.95" : "255.56",
                                        liters: unitData['liters'],
                                        unitNumber: unitData['unitNumber'],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ), ),

                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isGridView ? Icons.list : Icons.grid_view,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isGridView =
                                        !isGridView; // Toggle the boolean value
                                  });
                                },
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: isGridView
                                ? GridView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      mainAxisExtent: 133,
                                      crossAxisCount: 2, // 2 cards per row
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 16,
                                      // childAspectRatio: 1.2, // Adjust the aspect ratio
                                    ),
                                    itemCount: fuelData.length,
                                    itemBuilder: (context, index) {
                                      return FuelCard(
                                        fuelType: fuelData[index]['fuelType'],
                                        price: fuelData[index]['price'],
                                        sale: fuelData[index]['sale'],
                                        liters: fuelData[index]['liters'],
                                        unitNumber: "1",
                                      );
                                    },
                                  )
                                : ListView.builder(
                                    // padding: EdgeInsets.symmetric(vertical: ),
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: fuelData.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: FuelCard(
                                          fuelType: fuelData[index]['fuelType'],
                                          price: fuelData[index]['price'],
                                          sale: fuelData[index]['sale'],
                                          liters: fuelData[index]['liters'],
                                          unitNumber: "1",
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isGridView ? Icons.list : Icons.grid_view,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isGridView =
                                        !isGridView; // Toggle the boolean value
                                  });
                                },
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: isGridView
                                ? GridView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      mainAxisExtent: 133,
                                      crossAxisCount: 2, // 2 cards per row
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 16,
                                      // childAspectRatio: 1.2, // Adjust the aspect ratio
                                    ),
                                    itemCount: fuelData.length,
                                    itemBuilder: (context, index) {
                                      return FuelCard(
                                        fuelType: fuelData[index]['fuelType'],
                                        price: fuelData[index]['price'],
                                        sale: fuelData[index]['sale'],
                                        liters: fuelData[index]['liters'],
                                        unitNumber: "1",
                                      );
                                    },
                                  )
                                : ListView.builder(
                                    // padding: EdgeInsets.symmetric(vertical: ),
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: fuelData.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: FuelCard(
                                          fuelType: fuelData[index]['fuelType'],
                                          price: fuelData[index]['price'],
                                          sale: fuelData[index]['sale'],
                                          liters: fuelData[index]['liters'],
                                          unitNumber: "1",
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isGridView ? Icons.list : Icons.grid_view,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isGridView =
                                        !isGridView; // Toggle the boolean value
                                  });
                                },
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: isGridView
                                ? GridView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      mainAxisExtent: 133,
                                      crossAxisCount: 2, // 2 cards per row
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 16,
                                      // childAspectRatio: 1.2, // Adjust the aspect ratio
                                    ),
                                    itemCount: fuelData.length,
                                    itemBuilder: (context, index) {
                                      return FuelCard(
                                        fuelType: fuelData[index]['fuelType'],
                                        price: fuelData[index]['price'],
                                        sale: fuelData[index]['sale'],
                                        liters: fuelData[index]['liters'],
                                        unitNumber: "1",
                                      );
                                    },
                                  )
                                : ListView.builder(
                                    // padding: EdgeInsets.symmetric(vertical: ),
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: fuelData.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        child: FuelCard(
                                          fuelType: fuelData[index]['fuelType'],
                                          price: fuelData[index]['price'],
                                          sale: fuelData[index]['sale'],
                                          liters: fuelData[index]['liters'],
                                          unitNumber: "1",
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          SizedBox(
                            height: 20,
                          )
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

class FuelCard extends StatelessWidget {
  final String fuelType;
  final String price;
  final String sale;
  final String liters;
  final String unitNumber;

  FuelCard({
    required this.fuelType,
    required this.price,
    required this.sale,
    required this.liters,
    required this.unitNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Color(0xff222222),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_gas_station, color: Colors.redAccent),
              SizedBox(width: 5),
              Text(
                unitNumber,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 5),
              Text(
                fuelType,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          _buildInfoRow(
              'Price',
              price,
              true,
              BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          _buildInfoRow(
              'Sale', sale, false, BorderRadius.zero),
          _buildInfoRow(
              'Ltr',
              liters,
              true,
              BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10))),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool showRadius,
      BorderRadiusGeometry? borderRadius) {
    return Container(
      // margin:EdgeInsets.zero,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: showRadius == true
            ? borderRadius
            : null, // Rounded corners for inner blocks
      ),
      margin: EdgeInsets.only(top: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            alignment: Alignment.center,
            width: 48,
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(
            width: 14,
          )
        ],
      ),
    );
  }
}
