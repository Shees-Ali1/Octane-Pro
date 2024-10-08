import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../GetxControllers/dataController.dart';

class RealTimeDataPage extends StatelessWidget {
  final DataController dataController = Get.put(DataController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-Time Data'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Timer.periodic(Duration(milliseconds: 100), (timer) {
                List<int> data = [
                  0,
                  1,
                  21,
                  DateTime.now().second % 100,
                  DateTime.now().millisecond % 1000
                ];

                dataController.sendDataAsString(data);

                if (timer.tick >= 10) {
                  timer.cancel();
                }
              });
            },
            child: Text('Send Data'),
          ),
          Expanded(
            child: Obx(() {
              if (dataController.latestData.isEmpty) {
                return Center(child: Text('No data available.'));
              } else {
                return ListView(
                  children: [
                    ListTile(
                      title: Text('Fuel Type: ${dataController.latestData['fuelType']}, Funnel: ${dataController.latestData['funnel']}'),
                      subtitle: Text('Price: ${dataController.latestData['price']}, Liters: ${dataController.latestData['liters']}, Net Reading: ${dataController.latestData['NetReading']}'),
                    ),
                  ],
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
