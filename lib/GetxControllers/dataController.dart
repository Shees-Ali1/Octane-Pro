import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class DataController extends GetxController {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  var latestData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
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
}
