import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TotalContainer extends StatefulWidget {
  const TotalContainer({super.key, required this.data, this.nozzleID});

  final Map<String, dynamic> data;
  final String? nozzleID;

  @override
  State<TotalContainer> createState() => _TotalContainerState();
}

class _TotalContainerState extends State<TotalContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.nozzleID != null ? 150 : 130,
      width: MediaQuery.of(context).size.width * .9,
      padding: EdgeInsets.symmetric(horizontal: 8),
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
        border: Border.all(
          color: Colors.red,
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text("Fuel: ${widget.data['fuelType']}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: "Jost",
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Time: ${widget.data['time']}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontFamily: "Jost",
              ),
            ),
          ),
          if(widget.nozzleID != null)
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Nozzle: ${widget.data['unitNumber']}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontFamily: "Jost",
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Litres: ${formatNumber(widget.data['totalLiters'])}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontFamily: "Jost",
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Amount: ${formatNumber(widget.data['totalAmount'])}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontFamily: "Jost",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
String formatNumber(double number) {
  final formatter = NumberFormat('#,##0.00', 'en_US'); // Adjust format as needed
  return formatter.format(number);
}