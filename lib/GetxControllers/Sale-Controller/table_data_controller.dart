import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TableDataController extends GetxController {
  RxString shift = "".obs;
  RxString time = "".obs;
  var startTime = "".obs;  // Initially null
  var endTime = "".obs;    // Initially null
  RxList<QueryDocumentSnapshot> salesData = <QueryDocumentSnapshot>[].obs;
  RxList<Map<String, dynamic>> totalFilterData = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> allNozzlesData = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasMore = true.obs;
  QueryDocumentSnapshot? lastDocument;
  final int pageSize = 10;

  var totalsByFuelType = <String, double>{}.obs;


  var petrolData = <FlSpot>[].obs;
  var dieselData = <FlSpot>[].obs;
  var hobcData = <FlSpot>[].obs;

  var fuels = <List<String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSalesDataWithFilters();
  }

  void applyFilter() {
    resetData();  // Clear data and pagination state
    Get.back();
    fetchSalesDataWithFilters();  // Fetch new data with the filter applied
  }

  void resetData() {
    salesData.clear();
    totalFilterData.clear();
    allNozzlesData.clear();
    lastDocument = null;
    hasMore.value = true;
  }

// Updated _parseTime function to handle AM/PM time format
  DateTime _parseTime(String timeString, DateTime currentTime) {
    DateTime parsedTime;

    try {
      // Check if the timeString is in "AM/PM" format or "24-hour" format
      if (timeString.contains("AM") || timeString.contains("PM")) {
        // Convert the time from "AM/PM" format to "24-hour" format
        timeString = _convertTimeTo24Hour(timeString);
      }

      // Define the format of the time string (24-hour format)
      final timeFormat = DateFormat('HH:mm');

      // Parse the time string into a DateTime object, with today's date and the given time
      parsedTime = timeFormat.parse(timeString);

      // Return a new DateTime object with the same date as currentTime and the parsed time
      return DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        parsedTime.hour,
        parsedTime.minute,
      );
    } catch (e) {
      throw FormatException("Invalid time format: $timeString");
    }
  }

// Helper function to convert "08:00 AM" or "05:30 PM" to 24-hour format "08:00" or "17:30"
  String _convertTimeTo24Hour(String time) {
    try {
      // Parse the time in AM/PM format
      final format = DateFormat("hh:mm a");
      final dateTime = format.parse(time);

      // Convert it to 24-hour format
      return DateFormat("HH:mm").format(dateTime);
    } catch (e) {
      throw FormatException("Invalid AM/PM time format: $time");
    }
  }

// Updated fetchSalesDataWithFilters function
  Future<void> fetchSalesDataWithFilters() async {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;

    DateTime currentTime = DateTime.now();
    DateTime? startTimeFilter;
    DateTime? endTimeFilter;

    String timeFilterValue = time.value;
    print("Time Filter Value: $timeFilterValue");

    if (startTime.value.isNotEmpty && endTime.value.isNotEmpty) {
      startTimeFilter = _parseTime(startTime.value, currentTime);
      endTimeFilter = _parseTime(endTime.value, currentTime);
      print("Parsed Start Time: $startTimeFilter");
      print("Parsed End Time: $endTimeFilter");

      // Handling time span over two days (e.g., 6 PM to 8 AM)
      if (startTimeFilter.isAfter(endTimeFilter)) {
        // If start time is after end time, adjust the end time to the next day
        endTimeFilter = endTimeFilter.add(Duration(days: 1));
      }

      // If the current time is outside the defined range, show data from the previous day
      if (currentTime.isBefore(startTimeFilter) || currentTime.isAfter(endTimeFilter)) {
        startTimeFilter = startTimeFilter.subtract(Duration(days: 1));
        endTimeFilter = endTimeFilter.subtract(Duration(days: 1));
      }
    } else if (timeFilterValue.isNotEmpty) {
      switch (timeFilterValue) {
        case "12 hours":
          startTimeFilter = currentTime.subtract(Duration(hours: 12));
          break;
        case "24 hours":
          startTimeFilter = currentTime.subtract(Duration(hours: 24));
          break;
        case "Week":
          startTimeFilter = currentTime.subtract(Duration(days: 7));
          break;
        case "Month":
          startTimeFilter = currentTime.subtract(Duration(days: 30));
          break;
        default:
          startTimeFilter = currentTime.subtract(Duration(days: 1));
          break;
      }
      endTimeFilter = currentTime;
      print("Applied Time Filter: Start Time = $startTimeFilter, End Time = $endTimeFilter");
    }

    // Query for fetching data from Firestore
    Query query = FirebaseFirestore.instance
        .collection("sales")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("station1")
        .orderBy('timestamp', descending: true);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      lastDocument = snapshot.docs.last;

      print("Fetched ${snapshot.docs.length} documents from Firestore.");

      final filteredData = snapshot.docs.where((doc) {
        final timestamp = (doc['timestamp'] as Timestamp).toDate();

        bool isValidTime = true;

        // If startTime and endTime filters are applied, check if the timestamp falls within the range
        if (startTimeFilter != null && endTimeFilter != null) {
          isValidTime = timestamp.isAfter(startTimeFilter!) && timestamp.isBefore(endTimeFilter!);
        }

        return isValidTime;
      }).toList();

      print("Filtered ${filteredData.length} documents based on the time range.");

      salesData.addAll(filteredData);
      salesData.refresh();

      totalsByFuelType.value = calculateTotalByFuelType();
      calculateTotalAmountForFuelType(filteredData, timeFilterValue, startTimeFilter, endTimeFilter);
      calculateTotalAmountAndLitersForNozzles(filteredData, timeFilterValue, startTimeFilter, endTimeFilter);

      print("Fuel Data List: $totalFilterData");

      if (snapshot.docs.length < pageSize) {
        hasMore.value = false;
      }
    } else {
      hasMore.value = false;
    }

    isLoading.value = false;
  }


  void calculateTotalAmountForFuelType(List<QueryDocumentSnapshot> filteredData, String timeFilterValue, DateTime? startTimeFilter, DateTime? endTimeFilter) {
    DateTime currentTime = DateTime.now();

    totalsByFuelType.forEach((fuelType, totalLiters) {
      double totalAmount = 0.0;

      // Calculate total amount for this fuel type
      for (var document in filteredData) {
        if (document['expenses'][0]['fuelType'] == fuelType) {
          totalAmount += double.tryParse(document['expenses'][0]['amount']) ?? 0.0;
        }
      }

      String timePeriod = timeFilterValue.isEmpty ? "Overall" : timeFilterValue;

      if (startTimeFilter != null && endTimeFilter != null) {
        timePeriod = "${startTimeFilter!.hour}:${startTimeFilter.minute} to ${endTimeFilter!.hour}:${endTimeFilter.minute}";
      } else if (startTimeFilter != null) {
        timePeriod = "${startTimeFilter!.hour}:${startTimeFilter.minute} to ${currentTime.hour}:${currentTime.minute}";
      }

      // Find the index of the entry for this fuelType in the list, if exists
      int index = totalFilterData.indexWhere((entry) => entry['fuelType'] == fuelType);

      String time_period = '';

      if(startTime != "" && endTime != ""){
        time_period = "${startTime.value} to ${endTime.value}";
      } else if(startTime == "" && endTime == "" && time != '') {
        time_period = time.value;
      } else {
        time_period = 'Overall';
      }

      // Create new entry for the current fuel type
      Map<String, dynamic> newData = {
        'fuelType': fuelType,
        'totalLiters': totalLiters,
        'totalAmount': totalAmount,
        'time': time_period,
      };

      // If the fuelType is already in the list, replace the existing entry
      if (index != -1) {
        totalFilterData[index] = newData;  // Replace the existing entry
      } else {
        // If the fuelType is not in the list, add it
        totalFilterData.add(newData);
      }
    });

    // Optionally, you can print or use the totalFilterData list as needed
    print("Total Amount by Fuel Type: $totalFilterData");
  }

  void calculateTotalAmountAndLitersForNozzles(List<QueryDocumentSnapshot> filteredData, String timeFilterValue, DateTime? startTimeFilter, DateTime? endTimeFilter) {
    DateTime currentTime = DateTime.now();

    // Clear the previous data in allNozzlesData
    allNozzlesData.clear();

    // Map to store the aggregated data for each nozzle
    Map<String, Map<String, dynamic>> nozzleDataMap = {};

    // Iterate over each document to calculate total liters and total amount per nozzle
    filteredData.forEach((document) {
      var expenses = document['expenses'];

      expenses.forEach((expense) {
        String nozzleId = expense['unitNumber']; // Assuming unitNumber is the nozzle identifier
        String fuelType = expense['fuelType']; // Assuming unitNumber is the nozzle identifier
        double liters = double.tryParse(expense['liters'].toString()) ?? 0.0;
        double amount = double.tryParse(expense['amount'].toString()) ?? 0.0;

        String timePeriod = timeFilterValue.isEmpty ? "Overall" : timeFilterValue;

        if (startTimeFilter != null && endTimeFilter != null) {
          timePeriod = "${startTimeFilter!.hour}:${startTimeFilter.minute} to ${endTimeFilter!.hour}:${endTimeFilter.minute}";
        } else if (startTimeFilter != null) {
          timePeriod = "${startTimeFilter!.hour}:${startTimeFilter.minute} to ${currentTime.hour}:${currentTime.minute}";
        }

        String time_period = '';


        if(startTime != "" && endTime != ""){
          time_period = "${startTime.value} to ${endTime.value}";
        } else if(startTime == "" && endTime == "" && time != '') {
          time_period = time.value;
        } else {
          time_period = 'Overall';
        }


        // Check if nozzle data already exists in the map
        if (nozzleDataMap.containsKey(nozzleId)) {

          nozzleDataMap[nozzleId]!['totalLiters'] += liters;
          nozzleDataMap[nozzleId]!['totalAmount'] += amount;

        } else {

          nozzleDataMap[nozzleId] = {
            'unitNumber': nozzleId,
            'totalLiters': liters,
            'totalAmount': amount,
            'fuelType': fuelType,
            'time': time_period,
          };

        }
      });
    });

    // Convert the nozzleDataMap into a list and store it in allNozzlesData
    allNozzlesData.value = nozzleDataMap.values.toList();

    // Optionally, you can print or use the allNozzlesData list as needed
    print("Total Amount and Liters by Nozzle: ${allNozzlesData.value}");
  }

  String formatTimePeriod(DateTime? startTime, DateTime? endTime) {
    String formatTime(DateTime time) {
      int hour = time.hour;
      String period = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12; // Convert 0 to 12 for 12-hour format
      return "${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period";
    }

    if (startTime != null && endTime != null) {
      return "${formatTime(startTime)} to ${formatTime(endTime)}";
    } else if (startTime != null) {
      return "${formatTime(startTime)} to ${formatTime(DateTime.now())}";
    }
    return "Overall";
  }


  double calculateTotalAmount() {
    double totalAmount = 0.0;

    for (var document in salesData) {
      totalAmount += double.tryParse(document['expenses'][0]['amount']) ?? 0.0;
    }

    return totalAmount;
  }

  double calculateTotalLiters() {
    double totalLiters = 0.0;

    for (var document in salesData) {
      totalLiters += double.tryParse(document['expenses'][0]['liters']) ?? 0.0;
    }

    return totalLiters;
  }

  Map<String, double> calculateTotalByFuelType() {
    Map<String, double> totalsByFuelType = {};

    for (var document in salesData) {
      String fuelType = document['expenses'][0]['fuelType'];
      double liters = double.tryParse(document['expenses'][0]['liters']) ?? 0.0;


      if (totalsByFuelType.containsKey(fuelType)) {
        totalsByFuelType[fuelType] = (totalsByFuelType[fuelType] ?? 0.0) + liters;
      } else {
        totalsByFuelType[fuelType] = liters;
      }

    }

    return totalsByFuelType;
  }

  Map<String, double> calculateTotalNozzleFuel() {
    Map<String, double> totalsByFuelType = {};

    for (var document in salesData) {
      String fuelType = document['expenses'][0]['fuelType'];
      String nozzleID = document['expenses'][0]['unitNumber'];
      double liters = double.tryParse(document['expenses'][0]['liters']) ?? 0.0;


      if (totalsByFuelType.containsKey(fuelType)) {
        totalsByFuelType[fuelType] = (totalsByFuelType[fuelType] ?? 0.0) + liters;
      } else {
        totalsByFuelType[fuelType] = liters;
      }

    }

    return totalsByFuelType;
  }





  Future<TimeOfDay?> showTimeOnlyPicker({
    required BuildContext context,
    TimeOfDay? initialTime,
    ThemeData? theme, // Optional theme parameter
  }) async {
    initialTime ??= TimeOfDay.now();

    // Show time picker with the specified theme
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.dialOnly,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: theme ?? ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.red,
            canvasColor: Colors.black,
            dialogTheme: DialogTheme(
              backgroundColor: Colors.black,
              barrierColor: Colors.black,
            ),
            bannerTheme: MaterialBannerThemeData(backgroundColor: Colors.red),
            timePickerTheme: TimePickerThemeData(
              dialBackgroundColor: Colors.black,
              dialTextColor: Colors.white,
            ),
            primaryColor: Colors.red, // Background color
            colorScheme: ColorScheme.dark(
              outline: Colors.grey.shade600,
              primary: Colors.red,
              onPrimary: Colors.white, // Time color
              secondary: Colors.red, // AM/PM color
              onSecondary: Colors.white, // Button text color
            ),
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary, // Button text color
            ),
          ),
          child: child ?? SizedBox(),
        );
      },
    );

    return selectedTime; // Return the selected time or null if canceled
  }

  // Method to select the start time
  // Future<void> selectStartTime(BuildContext context) async {
  //   final TimeOfDay? selectedStartTime = await showTimeOnlyPicker(context: context, initialTime: TimeOfDay.now());
  //
  //   if (selectedStartTime != null) {
  //     // Update the startTime Rx variable when the user selects a start time
  //     startTime.value = selectedStartTime;
  //     // Optionally show snackbar confirmation
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Start time selected: ${selectedStartTime.format(context)}")),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Start time selection canceled")),
  //     );
  //   }
  // }
  //
  // // Method to select the end time with validation
  // Future<void> selectEndTime(BuildContext context) async {
  //   if (startTime.value == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Please select the start time first.")),
  //     );
  //     return;
  //   }
  //
  //   TimeOfDay? selectedEndTime;
  //   bool isValid = false;
  //
  //   // Loop until the user selects a valid end time
  //   while (!isValid) {
  //     selectedEndTime = await showTimeOnlyPicker(context: context, initialTime: startTime.value!);
  //
  //     if (selectedEndTime == null) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("End time selection canceled")),
  //       );
  //       return;
  //     }
  //
  //     if (selectedEndTime.hour < startTime.value!.hour ||
  //         (selectedEndTime.hour == startTime.value!.hour && selectedEndTime.minute <= startTime.value!.minute)) {
  //       // Show error if end time is before start time
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("End time cannot be before start time. Please select a valid end time.")),
  //       );
  //     } else {
  //       // If the end time is valid, update the endTime Rx variable
  //       endTime.value = selectedEndTime;
  //       isValid = true;
  //
  //       // Optionally show snackbar confirmation
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("End time selected: ${selectedEndTime.format(context)}")),
  //       );
  //     }
  //   }
  // }
}
