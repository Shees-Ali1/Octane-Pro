import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart'; // Make sure to import GetX
import 'package:flutter/material.dart';

class SaleSummaryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable variables to hold total values
  var totalPetrolLiter = 0.0.obs;
  var totalPetrolPrice = 0.0.obs;
  var totalDieselLiter = 0.0.obs;
  var totalDieselPrice = 0.0.obs;
  var totalHOBCLiter = 0.0.obs;
  var totalHOBCPrice = 0.0.obs;

  // Stream to fetch sale summary
  Stream<List<Map<String, dynamic>>> getSaleSummaryStream() {
    return _firestore.collection('Test ID').doc('aGTW69THmeaGotiV3362')
        .snapshots()
        .map((documentSnapshot) {
      if (documentSnapshot.exists) {
        List<dynamic> sales = documentSnapshot.data()?['Sale'] ?? [];
        return sales.map<Map<String, dynamic>>((sale) {
          return {
            "type": sale['Fuel Type'],
            "liter": (sale['Liter'] is int)
                ? sale['Liter'].toDouble()
                : double.tryParse(sale['Liter'].toString()) ?? 0.0,
            "price": (sale['Price'] is int)
                ? sale['Price'].toDouble()
                : double.tryParse(sale['Price'].toString()) ?? 0.0,
          };
        }).toList();
      } else {
        return [];
      }
    });
  }

  // Method to calculate totals from the sale data
  void calculateTotals(List<Map<String, dynamic>> sales) {
    print("Started calculating totals...");

    // Reset totals
    totalPetrolLiter.value = 0;
    totalPetrolPrice.value = 0;
    totalDieselLiter.value = 0;
    totalDieselPrice.value = 0;
    totalHOBCLiter.value = 0;
    totalHOBCPrice.value = 0;

    // Iterate through each sale in the list
    for (var sale in sales) {
      String fuelType = sale['type'];
      double liter = sale['liter'];
      double price = sale['price'];

      // Debugging print for each sale
      print("Processing sale: Fuel Type: $fuelType, Liter: $liter, Price: $price");

      // Group by fuel type
      if (fuelType == 'Petrol') {
        totalPetrolLiter.value += liter;
        totalPetrolPrice.value += price;
      } else if (fuelType == 'Diesel') {
        totalDieselLiter.value += liter;
        totalDieselPrice.value += price;
      } else if (fuelType == 'HOBC') {
        totalHOBCLiter.value += liter;
        totalHOBCPrice.value += price;
      }
    }

    // Print the totals
    print('Total Petrol: ${totalPetrolLiter.value} liters, ${totalPetrolPrice.value} price');
    print('Total Diesel: ${totalDieselLiter.value} liters, ${totalDieselPrice.value} price');
    print('Total HOBC: ${totalHOBCLiter.value} liters, ${totalHOBCPrice.value} price');
  }

  // Call this method to fetch and calculate the total sale data
  void listenForSaleSummary() {
    getSaleSummaryStream().listen((salesData) {
      calculateTotals(salesData);
    });
  }
}


