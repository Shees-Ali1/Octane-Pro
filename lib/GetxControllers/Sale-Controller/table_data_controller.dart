import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TableDataController extends GetxController {
  RxString shift = "".obs;
  RxString time = "".obs;
  var startTime = Rx<TimeOfDay?>(null);  // Initially null
  var endTime = Rx<TimeOfDay?>(null);    // Initially null
  RxList<QueryDocumentSnapshot> salesData = <QueryDocumentSnapshot>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasMore = true.obs;
  QueryDocumentSnapshot? lastDocument;
  final int pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    fetchSalesDataWithFilters();
  }

  void applyFilter() {
    resetData();  // Clear data and pagination state
    fetchSalesDataWithFilters();  // Fetch new data with the filter applied
  }

  void resetData() {
    salesData.clear();
    lastDocument = null;
    hasMore.value = true;
  }

  Future<void> fetchSalesDataWithFilters() async {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;
    DateTime? startTimeFilter;
    DateTime? endTimeFilter;
    DateTime currentTime = DateTime.now();

    // Get the time filter value directly from the controller
    String timeFilterValue = time.value;  // Access the value of RxString

    // Debug: Print the current time and the time filter value
    print("Current Time: $currentTime");
    print("Time Filter Value: $timeFilterValue");

    // If startTime and endTime are selected, convert them to DateTime for comparison (ignoring the date)
    if (startTime.value != null && endTime.value != null) {
      startTimeFilter = DateTime(currentTime.year, currentTime.month, currentTime.day, startTime.value!.hour, startTime.value!.minute);
      endTimeFilter = DateTime(currentTime.year, currentTime.month, currentTime.day, endTime.value!.hour, endTime.value!.minute);
      // Debug: Print the selected startTime and endTime
      print("Selected Start Time: $startTimeFilter");
      print("Selected End Time: $endTimeFilter");
    }

    // If no startTime or endTime filters are provided, apply the time filter logic (timeFilterValue)
    if (startTimeFilter == null || endTimeFilter == null) {
      if (timeFilterValue.isNotEmpty) {
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
            startTimeFilter = currentTime.subtract(Duration(days: 30));  // Approximate month (30 days)
            break;
          default:
            startTimeFilter = currentTime.subtract(Duration(days: 1));  // Default to 1 day if filter is unknown
            break;
        }
        endTimeFilter = currentTime;  // If no end time is selected, assume it's the current time
        // Debug: Print the applied time filter values
        print("Applied Time Filter: Start Time = $startTimeFilter, End Time = $endTimeFilter");
      } else {
        // If timeFilterValue is empty, don't apply any time filtering
        startTimeFilter = null;
        endTimeFilter = null;
      }
    }

    // Build the base query to fetch data from Firestore
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

      // Debug: Print the number of documents fetched
      print("Fetched ${snapshot.docs.length} documents from Firestore.");

      // Filter data based on the selected startTime and endTime (only apply if not null)
      final filteredData = snapshot.docs.where((doc) {
        final timestamp = (doc['timestamp'] as Timestamp).toDate();

        // Debug: Print the timestamp for each document
        print("Document Timestamp: $timestamp");

        bool isValidTime = true;

        // If no startTime or endTime filter is applied, show all data
        if (startTimeFilter == null && endTimeFilter == null) {
          isValidTime = true;
        } else if (startTimeFilter != null && endTimeFilter != null) {
          // Apply time-based filtering if startTime and endTime are provided
          DateTime strippedTimestamp = DateTime(currentTime.year, currentTime.month, currentTime.day, timestamp.hour, timestamp.minute);
          DateTime strippedStartTimeFilter = DateTime(currentTime.year, currentTime.month, currentTime.day, startTimeFilter!.hour, startTimeFilter.minute);
          DateTime strippedEndTimeFilter = DateTime(currentTime.year, currentTime.month, currentTime.day, endTimeFilter!.hour, endTimeFilter.minute);

          isValidTime = strippedTimestamp.isAfter(strippedStartTimeFilter) && strippedTimestamp.isBefore(strippedEndTimeFilter);
        }

        // Apply time-based filtering (based on day and time) if timeFilterValue is set
        if (startTimeFilter != null && endTimeFilter == null) {
          // Filter based on the `timeFilterValue` (12 hours, 24 hours, etc.)
          DateTime timeFilterStart = startTimeFilter;

          if (timeFilterValue == "12 hours") {
            timeFilterStart = currentTime.subtract(Duration(hours: 12));
          } else if (timeFilterValue == "24 hours") {
            timeFilterStart = currentTime.subtract(Duration(hours: 24));
          } else if (timeFilterValue == "Week") {
            timeFilterStart = currentTime.subtract(Duration(days: 7));
          } else if (timeFilterValue == "Month") {
            timeFilterStart = currentTime.subtract(Duration(days: 30));
          }

          // Check if the document's timestamp is within the valid range
          if (timestamp.isAfter(timeFilterStart)) {
            isValidTime = true;
          } else {
            isValidTime = false;
          }
        }

        return isValidTime;
      }).toList();

      // Debug: Print the number of filtered documents
      print("Filtered ${filteredData.length} documents based on the time range.");

      // Add the filtered data to the salesData list
      salesData.addAll(filteredData);
      salesData.refresh();

      // Update hasMore based on the size of the fetched documents
      if (snapshot.docs.length < pageSize) {
        hasMore.value = false;
      }
    } else {
      hasMore.value = false;
    }

    isLoading.value = false;
    Get.back();
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
  Future<void> selectStartTime(BuildContext context) async {
    final TimeOfDay? selectedStartTime = await showTimeOnlyPicker(context: context, initialTime: TimeOfDay.now());

    if (selectedStartTime != null) {
      // Update the startTime Rx variable when the user selects a start time
      startTime.value = selectedStartTime;
      // Optionally show snackbar confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Start time selected: ${selectedStartTime.format(context)}")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Start time selection canceled")),
      );
    }
  }

  // Method to select the end time with validation
  Future<void> selectEndTime(BuildContext context) async {
    if (startTime.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select the start time first.")),
      );
      return;
    }

    TimeOfDay? selectedEndTime;
    bool isValid = false;

    // Loop until the user selects a valid end time
    while (!isValid) {
      selectedEndTime = await showTimeOnlyPicker(context: context, initialTime: startTime.value!);

      if (selectedEndTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("End time selection canceled")),
        );
        return;
      }

      if (selectedEndTime.hour < startTime.value!.hour ||
          (selectedEndTime.hour == startTime.value!.hour && selectedEndTime.minute <= startTime.value!.minute)) {
        // Show error if end time is before start time
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("End time cannot be before start time. Please select a valid end time.")),
        );
      } else {
        // If the end time is valid, update the endTime Rx variable
        endTime.value = selectedEndTime;
        isValid = true;

        // Optionally show snackbar confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("End time selected: ${selectedEndTime.format(context)}")),
        );
      }
    }
  }
}
