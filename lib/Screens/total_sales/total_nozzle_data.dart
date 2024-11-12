import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:octane_pro/GetxControllers/Sale-Controller/table_data_controller.dart';
import 'package:octane_pro/Screens/total_sales/components/total_container.dart';

class TotalNozzleData extends StatefulWidget {
  const TotalNozzleData({super.key});

  @override
  State<TotalNozzleData> createState() => _TotalNozzleDataState();
}

class _TotalNozzleDataState extends State<TotalNozzleData> {

  final TableDataController tableVM = Get.find<TableDataController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.red,
        backgroundColor: Colors.black,
        leadingWidth: 0,
        leading: SizedBox.shrink(),
        title: Text("Sales Record", style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(child: Column(
        children: [
          Obx(()=> tableVM.totalFilterData.length == 0 ? Expanded(child: SizedBox(child: Center(child: CircularProgressIndicator(color: Colors.red,),))) :  SizedBox(
                  height: 132,
                  child: ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  itemCount: tableVM.totalFilterData.length,
                  itemBuilder: (context, index){
                    return TotalContainer(
                      nozzleID: null,
                        data: tableVM.totalFilterData[index]);
                  }),
                ),
          ),
          SizedBox(height: 20,),
          Align(
            alignment: Alignment.centerLeft,
              child: Text("Total Nozzle Sales", style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.w600))),
          SizedBox(height: 5,),
          Obx(()=> tableVM.allNozzlesData.length == 0 ? Expanded(child: SizedBox(child: Center(child: CircularProgressIndicator(color: Colors.red,),))) :   Expanded(
                  child: SizedBox(
                    child: Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 10.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: tableVM.allNozzlesData.length,
                            itemBuilder: (context, index){
                              return Padding(
                                padding: EdgeInsets.only(top: index != 0 ? 8 : 0),
                                child: TotalContainer(
                                    nozzleID: tableVM.allNozzlesData[index]['unitNumber'],
                                    data: tableVM.allNozzlesData[index]),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          ),
        ],
      )),
    );
  }
}
