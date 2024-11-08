import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

class GraphDataController extends GetxController {
  // Observables for data by fuel type
  var petrolData = <FlSpot>[].obs;
  var dieselData = <FlSpot>[].obs;
  var hobcData = <FlSpot>[].obs;

  // Observable for fuels list
  var fuels = <List<String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchFuelData();
  }

  Future<void> fetchFuelData() async {
    try {
      // Fetch and group data by date and fuel type
      Map<String, Map<String, double>> data = await _fetchDailyFuelData();

      // Convert data to FlSpot for each fuel type
      petrolData.value = _mapToFlSpots(data, 'Petrol');
      dieselData.value = _mapToFlSpots(data, 'Diesel');
      hobcData.value = _mapToFlSpots(data, 'HOB');

      // Fetch and update fuels list for displaying dynamic data
      fuels.value = await _fetchFuelsData();
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<Map<String, Map<String, double>>> _fetchDailyFuelData() async {
    Map<String, Map<String, double>> fuelDataByDate = {};
    var snapshots = await FirebaseFirestore.instance
        .collection('sales/m4DrsbFKPzevANIrBmF54B0lzqY2/station1')
        .get();

    for (var doc in snapshots.docs) {
      var date = (doc['timestamp'] as Timestamp).toDate();
      String day = "${date.year}-${date.month}-${date.day}";

      for (var expense in doc['expenses']) {
        String fuelType = expense['fuelType'];
        double liters = double.parse(expense['liters']);

        if (!fuelDataByDate.containsKey(day)) {
          fuelDataByDate[day] = {};
        }

        fuelDataByDate[day]![fuelType] =
            (fuelDataByDate[day]![fuelType] ?? 0) + (liters > 2000 ? 2000 : liters);
      }
    }
    return fuelDataByDate;
  }

  List<FlSpot> _mapToFlSpots(Map<String, Map<String, double>> data, String fuelType) {
    List<FlSpot> spots = [];
    int xIndex = 0;

    data.forEach((date, values) {
      if (values.containsKey(fuelType)) {
        double quantity = values[fuelType]!;
        spots.add(FlSpot(xIndex.toDouble(), quantity));
        xIndex++;
      }
    });
    return spots;
  }

  Future<List<List<String>>> _fetchFuelsData() async {
    Map<String, Map<String, double>> fuelAmounts = {};
    var snapshots = await FirebaseFirestore.instance
        .collection('sales/m4DrsbFKPzevANIrBmF54B0lzqY2/station1')
        .get();

    for (var doc in snapshots.docs) {
      for (var expense in doc['expenses']) {
        String fuelType = expense['fuelType'];
        double amount = double.parse(expense['amount']);
        double liters = double.parse(expense['liters']);

        // Add or accumulate the data for each fuel type
        if (!fuelAmounts.containsKey(fuelType)) {
          fuelAmounts[fuelType] = {"amount": 0, "liters": 0};
        }
        fuelAmounts[fuelType]!['amount'] = fuelAmounts[fuelType]!['amount']! + amount;
        fuelAmounts[fuelType]!['liters'] = fuelAmounts[fuelType]!['liters']! + liters;
      }
    }

    // Convert map data to list format for UI rendering
    List<List<String>> fuelsList = [];
    fuelAmounts.forEach((fuelType, values) {
      fuelsList.add([
        fuelType,
        values['amount']!.toStringAsFixed(2),
        values['liters']!.toStringAsFixed(2)
      ]);
    });
    return fuelsList;
  }
}
