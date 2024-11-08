import 'package:cloud_firestore/cloud_firestore.dart';

class FuelDataController {
  double totalAmountPetrol = 0.0;
  double totalLitersPetrol = 0.0;

  double totalAmountDiesel = 0.0;
  double totalLitersDiesel = 0.0;

  double totalAmountHOBC = 0.0;
  double totalLitersHOBC = 0.0;

  // Constructor to initialize the listeners
  FuelDataController() {
    _initializeListener();
  }

  // Initialize the Firestore listener
  void _initializeListener() {
    FirebaseFirestore.instance
        .collection('/sales/m4DrsbFKPzevANIrBmF54B0lzqY2/station1')
        .snapshots()
        .listen((snapshot) {
      // Reset totals before aggregating new data
      totalAmountPetrol = 0.0;
      totalLitersPetrol = 0.0;

      totalAmountDiesel = 0.0;
      totalLitersDiesel = 0.0;

      totalAmountHOBC = 0.0;
      totalLitersHOBC = 0.0;

      for (var doc in snapshot.docs) {
        final data = doc.data();

        // Check if 'expenses' field is a list of maps
        if (data['expenses'] is List) {
          List expenses = data['expenses'];

          for (var expense in expenses) {
            String fuelType = expense['fuelType'] ?? '';

            // Parse amount and liters safely, defaulting to 0.0 if parsing fails
            double amount = double.tryParse(expense['amount'] ?? '') ?? 0.0;
            double liters = double.tryParse(expense['liters'] ?? '') ?? 0.0;

            // Aggregate amounts and liters by fuel type
            switch (fuelType) {
              case 'Petrol':
                totalAmountPetrol += amount;
                totalLitersPetrol += liters;
                break;

              case 'Diesel':
                totalAmountDiesel += amount;
                totalLitersDiesel += liters;
                break;

              case 'HOBC':
                totalAmountHOBC += amount;
                totalLitersHOBC += liters;
                break;
            }
          }
        }
      }

      // Optionally, print values for debugging
      print('Petrol - Total Amount: $totalAmountPetrol, Total Liters: $totalLitersPetrol');
      print('Diesel - Total Amount: $totalAmountDiesel, Total Liters: $totalLitersDiesel');
      print('HOBC - Total Amount: $totalAmountHOBC, Total Liters: $totalLitersHOBC');
    });
  }
  // Dispose controllers
  void dispose() {

  }
}
