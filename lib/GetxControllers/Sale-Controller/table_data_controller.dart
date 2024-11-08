import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TableDataController extends GetxController {
  RxString shift = "".obs;
  RxString time = "".obs;
  RxList<QueryDocumentSnapshot> salesData = <QueryDocumentSnapshot>[].obs;
  RxBool isLoading = false.obs;
  RxBool hasMore = true.obs;
  QueryDocumentSnapshot? lastDocument;
  final int pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    fetchSalesData();
  }

  void applyFilter() {
    resetData();  // Clear data and pagination state
    fetchSalesData();  // Fetch new data with the filter applied
  }

  void resetData() {
    salesData.clear();
    lastDocument = null;
    hasMore.value = true;
  }

  Future<void> fetchSalesData() async {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;

    // Define time range based on shift
    TimeOfDay? shiftStart, shiftEnd;
    if (shift.value == "A") {
      shiftStart = const TimeOfDay(hour: 0, minute: 0);   // 12 AM
      shiftEnd = const TimeOfDay(hour: 11, minute: 59);   // 11:59 AM
    } else if (shift.value == "B") {
      shiftStart = const TimeOfDay(hour: 12, minute: 0);  // 12 PM
      shiftEnd = const TimeOfDay(hour: 23, minute: 59);   // 11:59 PM
    }

    // Build the base query
    Query query = FirebaseFirestore.instance
        .collection("sales")
        .doc('m4DrsbFKPzevANIrBmF54B0lzqY2')
        .collection("station1")
        .orderBy('timestamp', descending: true)
        .limit(pageSize);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    final snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      lastDocument = snapshot.docs.last;

      // Filter results based on shift time range if shift is selected
      final filteredData = snapshot.docs.where((doc) {
        if (shiftStart == null || shiftEnd == null) return true;

        final timestamp = (doc['timestamp'] as Timestamp).toDate();
        final documentTime = TimeOfDay(hour: timestamp.hour, minute: timestamp.minute);

        final isAfterShiftStart = (documentTime.hour > shiftStart.hour) ||
            (documentTime.hour == shiftStart.hour && documentTime.minute >= shiftStart.minute);
        final isBeforeShiftEnd = (documentTime.hour < shiftEnd.hour) ||
            (documentTime.hour == shiftEnd.hour && documentTime.minute <= shiftEnd.minute);

        return isAfterShiftStart && isBeforeShiftEnd;
      }).toList();

      salesData.addAll(filteredData);

      if (snapshot.docs.length < pageSize) {
        hasMore.value = false;
      }
    } else {
      hasMore.value = false;
    }

    isLoading.value = false;
    Get.back();
  }

  Future<void> fetchSalesDataWithTimeFilter(String timeFilter) async {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;

    // Calculate the start time based on the selected time filter
    DateTime startTime;
    DateTime currentTime = DateTime.now();

    switch (timeFilter) {
      case "12 hours":
        startTime = currentTime.subtract(Duration(hours: 12));
        break;
      case "24 hours":
        startTime = currentTime.subtract(Duration(hours: 24));
        break;
      case "Week":
        startTime = currentTime.subtract(Duration(days: 7));
        break;
      case "Month":
        startTime = currentTime.subtract(Duration(days: 30));  // Approximate month (30 days)
        break;
      default:
      // Default to 1 day if an invalid filter is provided
        startTime = currentTime.subtract(Duration(days: 1));
        break;
    }

    // Build the base query
    Query query = FirebaseFirestore.instance
        .collection("sales")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("station1")
        .orderBy('timestamp', descending: true)
        .limit(pageSize);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      lastDocument = snapshot.docs.last;

      // Filter results based on the selected time filter
      final filteredData = snapshot.docs.where((doc) {
        final timestamp = (doc['timestamp'] as Timestamp).toDate();

        // Only keep data within the selected time range
        return timestamp.isAfter(startTime);
      }).toList();

      salesData.addAll(filteredData);

      if (snapshot.docs.length < pageSize) {
        hasMore.value = false;
      }
    } else {
      hasMore.value = false;
    }

    isLoading.value = false;
    Get.back();
  }


}
