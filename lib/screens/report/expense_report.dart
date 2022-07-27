import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_pos/controllers/expense.controller.dart';
import 'package:flutter_pos/controllers/report.controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ExpenseReport extends StatefulWidget {
  const ExpenseReport({Key? key}) : super(key: key);

  @override
  State<ExpenseReport> createState() => _ExpenseReportState();
}

class _ExpenseReportState extends State<ExpenseReport> {
  List<OrdinalExpense> reportList = [];
  final ExpenseController _expenseController = Get.find<ExpenseController>();
  final ReportController _reportController = Get.find<ReportController>();

  List<TimeSeriesExpense> seriesList = [];

  getExpenseReport() async {
    await _expenseController.getExpense(start: DateFormat.yMd().format(_reportController.startDate.value), end: DateFormat.yMd().format(_reportController.endDate.value));
  }

  getOrderGroupBy() async {
    await Future.delayed(const Duration(seconds: 1));

    var groupByDate = _expenseController.expenseList.map((data) {
      return {"date": data.date, "value": data.amount};
    });
    var sumlist = {};
    for (var data in groupByDate) {
      if (sumlist.containsKey(data["date"])) {
        sumlist[data["date"]] += data['value'];
      } else {
        sumlist[data["date"]] = data['value'];
      }
    }
    List<OrdinalExpense> list = <OrdinalExpense>[];
    List<TimeSeriesExpense> expenseList = <TimeSeriesExpense>[];

    
    sumlist.forEach((key, value) {
      list.add(OrdinalExpense(key, (value * 1).round()));
      var date = key.toString().split("/");
      expenseList.add(TimeSeriesExpense(DateTime(int.parse(date[2]), int.parse(date[0]), int.parse(date[1])), (value * 1).round()));
    });
    list.sort((a, b) => b.day.compareTo(a.day));
    expenseList.sort((a, b) => a.time.compareTo(b.time));

    setState(() {
      reportList = list;
      seriesList = expenseList;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getExpenseReport();
    getOrderGroupBy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          foregroundColor: Colors.white,
          title: const Text("Expense Daily Report"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(()=>Text(
                        "${DateFormat.yMd().format(_reportController.startDate.value)} - ${DateFormat.yMd().format(_reportController.endDate.value)}"))
                  
                ],
              ),
              // ConstrainedBox(
              //   constraints: BoxConstraints.expand(height: 500),
              //   child: charts.BarChart(
              //     _createSampleData(),
              //     animate: false,
              //     defaultRenderer: charts.BarRendererConfig(
              //         stackedBarPaddingPx: 50,
              //         minBarLengthPx: 50,
              //         maxBarWidthPx: 100,
              //         groupingType: charts.BarGroupingType.grouped,
              //         strokeWidthPx: 2.0),
              //     behaviors: [
              //       charts.SlidingViewport(),
              //       charts.PanAndZoomBehavior(),
              //     ],
              //     domainAxis: charts.OrdinalAxisSpec(
              //         viewport: charts.OrdinalViewport('2019', 4)),
              //   ),
              // ),
              ConstrainedBox(
                constraints: const BoxConstraints.expand(height: 500),
                child: charts.TimeSeriesChart(
                
                  _createTimeSeries(),
                  animate: false,
                  defaultRenderer: charts.BarRendererConfig<DateTime>(),
                  defaultInteractions: false,
                  behaviors: [charts.DomainHighlighter(), charts.SelectNearest()],
                  
                ),
              )
            ],
          ),
        ),
        );
  }

  List<charts.Series<OrdinalExpense, String>> _createSampleData() {
    // print("helllo >>> ${reportList.toString()}");
    final expenseData = [
      ...reportList,
      // OrdinalExpense("Mar 10 2022", 1000),
      // OrdinalExpense("Mar 11 2022", 100),
      // OrdinalExpense("Mar 12 2022", 100),
      // OrdinalExpense("Mar 13 2022", 1000),
      // OrdinalExpense("Mar 14 2022", 100),
      // OrdinalExpense("Mar 15 2022", 1000),
      // OrdinalExpense("Mar 16 2022", 100),
      // OrdinalExpense("Mar 17 2022", 1000),
      // OrdinalExpense("Mar 18 2022", 1000),
    ];

    return [
      // Blue bars with a lighter center color.
      charts.Series<OrdinalExpense, String>(
        id: 'Desktop',
        domainFn: (OrdinalExpense expense, _) => expense
            .day, //"${sales.day.split(" ")[0]} ${sales.day.split(" ")[1]}",
        measureFn: (OrdinalExpense expense, _) => expense.expense,
        data: expenseData,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        fillColorFn: (_, __) =>
            charts.MaterialPalette.blue.shadeDefault.lighter,
      ),
    ];
  }

  List<charts.Series<TimeSeriesExpense, DateTime>> _createTimeSeries() {
    // print("helllo >>> ${reportList.toString()}");
    final expenseData = [
      ...seriesList.reversed.toList(),
      // TimeSeriesExpense(DateTime(2022, 4, 2), 20),
      // TimeSeriesExpense(DateTime(2022, 4, 3), 20),
      // TimeSeriesExpense(DateTime(2022, 4, 4), 20),
    ];

    return [
      // Blue bars with a lighter center color.
      charts.Series<TimeSeriesExpense, DateTime>(
        id: 'expense',
        domainFn: (TimeSeriesExpense expense, _) => expense
            .time, //"${sales.day.split(" ")[0]} ${sales.day.split(" ")[1]}",
        measureFn: (TimeSeriesExpense expense, _) => expense.value,
        data: expenseData,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        fillColorFn: (_, __) =>
            charts.MaterialPalette.blue.shadeDefault.lighter,
      ),
    ];
  }
}

class OrdinalExpense {
  final String day;
  final int expense;

  OrdinalExpense(this.day, this.expense);
}

class TimeSeriesExpense {
  final DateTime time;
  final int value;

  TimeSeriesExpense(this.time, this.value);
}
