/// Bar chart example
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_pos/controllers/order.controller.dart';
import 'package:flutter_pos/controllers/report.controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SaleReport extends StatefulWidget {
  const SaleReport({Key? key}) : super(key: key);

  @override
  State<SaleReport> createState() => _SaleReportState();
}

class _SaleReportState extends State<SaleReport> {
  final OrderController _orderController = Get.find<OrderController>();
  final ReportController _reportController = Get.find<ReportController>();
  List<OrdinalSales> reportList = [];

  getSaleReport() async {
    await _orderController.getOrder(start: DateFormat.yMd().format(_reportController.startDate.value), end: DateFormat.yMd().format(_reportController.endDate.value));
    // list = await _orderController.getOrderGroupBy();
  }

  getOrderGroupBy() async {
    await Future.delayed(const Duration(seconds: 1));

    var groupByDate = _orderController.orderList.map((data) {
      return {
        "date":
            "${data.date.split(" ")[1]} ${data.date.split(" ")[2].substring(0, data.date.split(" ")[2].length - 1)} ${data.date.split(" ")[3]}",
        "value": data.total
      };
    });
    var sumlist = Map();
    for (var data in groupByDate) {
      if (sumlist.containsKey(data["date"])) {
        sumlist[data["date"]] += data['value'];
      } else {
        sumlist[data["date"]] = data['value'];
      }
    }
    List<OrdinalSales> list = <OrdinalSales>[];
    sumlist.forEach((key, value) {
      list.add(OrdinalSales(key, (value * 1).round()));
    });
    setState(() {
      reportList = list;
    });
    
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getSaleReport();

    getOrderGroupBy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Daily Sale Report"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(()=>Text(
                        "${DateFormat.yMd().format(_reportController.startDate.value)} - ${DateFormat.yMd().format(_reportController.endDate.value)}"))
                  
                ],
              ),
          ConstrainedBox(
            constraints: const BoxConstraints.expand(height: 500),
            // height: MediaQuery.of(context).size.height*0.5,
            child: charts.BarChart(
              _createSampleData(),
              animate: false,
              // Configure a stroke width to enable borders on the bars.
              defaultRenderer: charts.BarRendererConfig(
                stackedBarPaddingPx: 50,
                minBarLengthPx: 50,
                maxBarWidthPx: 100,          
                  groupingType: charts.BarGroupingType.grouped, 
                  strokeWidthPx: 2.0),
              behaviors: [
                charts.SlidingViewport(),
                charts.PanAndZoomBehavior(),
              ],

              domainAxis:
                  charts.OrdinalAxisSpec(viewport: charts.OrdinalViewport('2019', 4)),
            ),
          ),
        ],
      ),
    );
  }

  /// Create series list with multiple series
  List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final desktopSalesData = [
      ...reportList,
      // OrdinalSales('Mar 29 2022', 100),
      // OrdinalSales('Mar 25 2022', 7),
      // OrdinalSales('Mar 24 2022', 75),
      // OrdinalSales('Mar 23 2022', 75),
      // OrdinalSales('Mar 22 2022', 100),
      // OrdinalSales('Mar 21 2022', 25),
      // OrdinalSales('Mar 20 2022', 5),
      // OrdinalSales('Mar 19 2022', 25),
      // OrdinalSales('Mar 17 2022', 5),
      // OrdinalSales('Mar 16 2022', 5),
      // OrdinalSales('Mar 15 2022', 5),
      // OrdinalSales('Mar 14 2022', 5),
      // OrdinalSales('Mar 13 2022', 5),
      // OrdinalSales('Mar 12 2022', 5),
      // OrdinalSales('Mar 11 2022', 5),

    ];


    return [
      // Blue bars with a lighter center color.
      charts.Series<OrdinalSales, String>(
        id: 'Desktop',
        domainFn: (OrdinalSales sales, _) => "${sales.year.split(" ")[0]} ${sales.year.split(" ")[1]}",
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: desktopSalesData,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        fillColorFn: (_, __) =>
            charts.MaterialPalette.blue.shadeDefault.lighter,
      ),
      // Solid red bars. Fill color will default to the series color if no
      // fillColorFn is configured.
      // charts.Series<OrdinalSales, String>(
      //   id: 'Tablet',
      //   measureFn: (OrdinalSales sales, _) => sales.sales,
      //   data: tableSalesData,
      //   colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
      //   domainFn: (OrdinalSales sales, _) => sales.year,
      // ),
      // Hollow green bars.
      // charts.Series<OrdinalSales, String>(
      //   id: 'Mobile',
      //   domainFn: (OrdinalSales sales, _) => sales.year,
      //   measureFn: (OrdinalSales sales, _) => sales.sales,
      //   data: mobileSalesData,
      //   colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      //   fillColorFn: (_, __) => charts.MaterialPalette.transparent,
      // ),
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
