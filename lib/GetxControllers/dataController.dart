import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class DataController extends GetxController {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  var shift1 = <Map<String, String>>[].obs;
  var shift2 = <Map<String, String>>[].obs;

  var latestData = <String, dynamic>{}.obs;
  RxInt totalUnits = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getShifts();
    listenToDataStream();
  }

  void listenToDataStream() {
    // Listen for new entries
    _databaseReference.child('Station').onChildAdded.listen((event) {
      if (event.snapshot.exists) {
        _updateLatestData(event.snapshot);
      }
    });

    // Listen for updates to existing entries
    _databaseReference.child('Station').onChildChanged.listen((event) {
      if (event.snapshot.exists) {
        _updateLatestData(event.snapshot);
      }
    });
  }

  void _updateLatestData(DataSnapshot snapshot) {
    final dataString = snapshot.value as String;
    final values = dataString.split(',');

    latestData.value = {
      'id': snapshot.key,
      'funnel': values[0] == '0' ? 'funnel in' : 'funnel out',
      'fuelType': values[1] == '0' ? 'Diesel' : 'Petrol',
      'price': int.parse(values[2]),
      'liters': values[3],
      'NetReading': values[4],
    };

    print('Updated latest data: $latestData'); // Debugging log
  }

  Future<void> sendDataAsString(List<int> data) async {
    try {
      await Firebase.initializeApp();
      String dataString = data.join(',');
      String key = _databaseReference.child('Station').push().key!;
      await _databaseReference.child('Station/$key').set(dataString);
      print('Data sent: $dataString');
    } catch (error) {
      print('Error sending data: $error');
    }
  }


  void getShifts() async {
    // Fetch the document from Firestore
    DocumentSnapshot document = await FirebaseFirestore.instance
        .collection("shifts")
        .doc("m4DrsbFKPzevANIrBmF54B0lzqY2")
        .get();

    // Check if the document exists and has the 'station1_shift' array
    if (document.exists && document.data() != null) {
      List<dynamic> shifts = document['station1_shift'];

      // Replace shift data in shift1 and shift2 based on index
      if (shifts.isNotEmpty && shifts.length > 0) {
        shift1.value = [
          {'start': shifts[0]['start'] ?? '', 'end': shifts[0]['end'] ?? ''}
        ];
      } else {
        shift1.clear();
      }

      if (shifts.length > 1) {
        shift2.value = [
          {'start': shifts[1]['start'] ?? '', 'end': shifts[1]['end'] ?? ''}
        ];
      } else {
        shift2.clear();
      }
    }

    // Optionally, print shift data to check the values
    print("Shift 1 Data: $shift1");
    print("Shift 2 Data: $shift2");
  }
}
