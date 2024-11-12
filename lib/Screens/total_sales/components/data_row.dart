import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TableDataRow extends StatefulWidget {
  const TableDataRow({super.key, required this.data, required this.date});

  final List<Map<String, dynamic>> data;
  final Timestamp date;

  @override
  State<TableDataRow> createState() => _TableDataRowState();
}

class _TableDataRowState extends State<TableDataRow> {
  // Format Timestamp to desired date format
  String _formatDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMM yyyy\nhh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.21,
              child: Text(
                _formatDate(widget.date).toString(),
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.17,
              child: Text(
                widget.data[0]['unitNumber'].toString(),
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.12,
              child: Text(
                widget.data[0]['fuelType'].toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.19,
              child: Text(
                formatNumber(double.tryParse(widget.data[0]['liters'].toString() ?? "0") ?? 0),
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              child: Text(
                formatNumber(double.tryParse(widget.data[0]['amount'].toString() ?? "0") ?? 0),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatNumber(double number) {
  final formatter = NumberFormat('#,##0.00', 'en_US'); // Adjust format as needed
  return formatter.format(number);
}