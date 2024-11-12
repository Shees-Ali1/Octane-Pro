import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:octane_pro/GetxControllers/Sale-Controller/table_data_controller.dart';
import 'package:octane_pro/Screens/total_sales/components/data_row.dart';

class TotalSalesScreen extends StatefulWidget {
  TotalSalesScreen({super.key});

  @override
  State<TotalSalesScreen> createState() => _TotalSalesScreenState();
}

class _TotalSalesScreenState extends State<TotalSalesScreen> {
  final TableDataController tableVM = Get.find<TableDataController>();

  void showFilterDialog(BuildContext context) {
    showDialog(context: context, builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.black,
        contentPadding: EdgeInsets.zero,
        content: Obx(
            ()=> Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border.all(width: 1.5, color: Colors.red),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Show by last:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontFamily: "Jost",
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildTimeButton("12 hours", "12 hours"),
                    _buildTimeButton("24 hours", "24 hours"),

                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildTimeButton("Week", "Week"),
                    _buildTimeButton("Month", "Month"),
                  ],
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Select shift:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      fontFamily: "Jost",
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if(tableVM.startTime.value == null)
                GestureDetector(
                  onTap: () async{
                    tableVM.selectStartTime(context);
                    // var startTime = await showTimeOnlyPicker(context: context);
                    // print("Start time: $startTime");
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color:  Colors.black,
                      border: Border.all(width: 1, color: Colors.red),
                    ),
                    alignment: Alignment.center,
                    child: Text("Select Start Time",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                        fontFamily: "Jost",
                      ),
                    ),
                  ),
                ),
                if(tableVM.startTime.value != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Start time:  ${tableVM.startTime.value!.format(context)}",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                          fontFamily: "Jost",
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          tableVM.startTime.value = null;
                        },
                          child: Icon(Icons.close, size: 20, color: Colors.white,))
                    ],
                  ),
                SizedBox(height: 15,),
                if(tableVM.endTime.value == null)
                GestureDetector(
                  onTap: () async{
                    tableVM.selectEndTime(context);
                    // var endTime = await showTimeOnlyPicker(context: context);
                    // print("end time: $endTime");
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 12),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color:  Colors.black,
                      border: Border.all(width: 1, color: Colors.red),
                    ),
                    alignment: Alignment.center,
                    child: Text("Select Start Time",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                        fontFamily: "Jost",
                      ),
                    ),
                  ),
                ),
                if(tableVM.endTime.value != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("End time:  ${tableVM.endTime.value!.format(context)}",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                          fontFamily: "Jost",
                        ),
                      ),
                      InkWell(
                          onTap: (){
                            tableVM.endTime.value = null;
                          },
                          child: Icon(Icons.close, size: 20, color: Colors.white,))
                    ],
                  ),
                SizedBox(height: 40),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogButton(context, "Apply", () async {

                        tableVM.applyFilter();

                    }),
                    _buildDialogButton(context, "Cancel", () {
                      tableVM.shift.value = "";
                      tableVM.startTime.value = null;
                      tableVM.endTime.value = null;
                      tableVM.time.value = "";
                      Get.back();
                      tableVM.applyFilter();
                    }),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildShiftButton(String shiftValue, String label) {
    return GestureDetector(
      onTap: () {
        tableVM.time.value = "";
        tableVM.shift.value = shiftValue;
      },
      child: Obx(() => Container(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(horizontal: 12),
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: tableVM.shift.value == shiftValue ? Colors.red : Colors.black,
          border: Border.all(width: 1, color: Colors.red),
        ),
        alignment: Alignment.center,
        child: Text(label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: tableVM.shift.value == shiftValue ? Colors.white : Colors.red,
            fontFamily: "Jost",
          ),
        ),
      )),
    );
  }
  Widget _buildTimeButton(String shiftValue, String label) {
    return GestureDetector(
      onTap: () {
        tableVM.shift.value = '';
        tableVM.time.value = shiftValue;
      },
      child: Obx(() => Container(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(horizontal: 12),
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: tableVM.time.value == shiftValue ? Colors.red : Colors.black,
          border: Border.all(width: 1, color: Colors.red),
        ),
        alignment: Alignment.center,
        child: Text(label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: tableVM.time.value == shiftValue ? Colors.white : Colors.red,
            fontFamily: "Jost",
          ),
        ),
      )),
    );
  }


  Widget _buildDialogButton(BuildContext context, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(horizontal: 12),
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black,
          border: Border.all(width: 1, color: Colors.red),
        ),
        alignment: Alignment.center,
        child: Text(label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.red,
            fontFamily: "Jost",
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.red,
        backgroundColor: Colors.black,
        title: Text("Total Sales", style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: Icon(Icons.tune, size: 30, color: Colors.red),
            onPressed: () => showFilterDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Obx(() {
                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (!tableVM.isLoading.value && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                      tableVM.fetchSalesDataWithFilters();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: tableVM.salesData.length + 1,
                    itemBuilder: (context, index) {
                      if (index == tableVM.salesData.length) {
                        return tableVM.isLoading.value
                            ? Center(child: CircularProgressIndicator(color: Colors.red))
                            : SizedBox.shrink();
                      }
                      final data = tableVM.salesData[index];
                      List<Map<String, dynamic>> sales = List<Map<String, dynamic>>.from(data['expenses'].map((item) => Map<String, dynamic>.from(item)));
                      return TableDataRow(data: sales, date: data['timestamp']);
                    },
                  ),
                );
              }),
            ),
            SizedBox(height: 20,),
            Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          _buildHeaderText("Date", MediaQuery.of(context).size.width * 0.21),
          _buildHeaderText("Nozzle", MediaQuery.of(context).size.width * 0.17),
          _buildHeaderText("Fuel", MediaQuery.of(context).size.width * 0.12),
          _buildHeaderText("Liters", MediaQuery.of(context).size.width * 0.19),
          _buildHeaderText("Total", MediaQuery.of(context).size.width * 0.25),
        ],
      ),
    );
  }

  Widget _buildHeaderText(String text, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontFamily: "Jost",
        ),
      ),
    );
  }
}
