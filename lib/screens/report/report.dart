import 'package:flutter/material.dart';
import 'package:flutter_pos/controllers/expense.controller.dart';
import 'package:flutter_pos/controllers/order.controller.dart';
import 'package:flutter_pos/controllers/report.controller.dart';
import 'package:flutter_pos/screens/report/expense_report.dart';
import 'package:flutter_pos/screens/report/sale_report.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Report extends StatefulWidget {
  const Report({Key? key}) : super(key: key);

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  DateTimeRange _dateTimeRange =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());

  final ExpenseController _expenseController = Get.put(ExpenseController());
  final OrderController _orderController = Get.put(OrderController());
  final ReportController _reportController = Get.put(ReportController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _expenseController.getTotalExpense(
        start: DateFormat.yMd().format(_dateTimeRange.start),
        end: DateFormat.yMd().format(_dateTimeRange.end));
    _orderController.getTotalOrder(
        start: DateFormat.yMd().format(_dateTimeRange.start),
        end: DateFormat.yMd().format(_dateTimeRange.end));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Reports"),
        actions: [
          IconButton(
              onPressed: () {
                dateRangePicker(context);
              },
              icon: const Icon(Icons.calendar_today)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            Container(
              // height: 130,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    blurRadius: 2,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Obx(()=>Text(
                        "${DateFormat.yMd().format(_reportController.startDate.value)} - ${DateFormat.yMd().format(_reportController.endDate.value)}"))
                  ]),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      const Text(
                        "Profit",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Obx(() {
                        double value =
                            (double.parse(_orderController.total.value) -
                                double.parse(_expenseController.total.value));
                        return Text(
                          value.toString(),
                          style: TextStyle(
                            fontSize: 23,
                              color: value < 0 ? Colors.red : Colors.green),
                        );
                      }),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        "Total Income",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Obx(
                        () => Text(_orderController.total.value, style: const TextStyle(color: Colors.green),),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        "Total Expense",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Obx(() =>
                          Text(_expenseController.total.value.toString(), style: const TextStyle(color: Colors.red),)),
                    ],
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(const SaleReport());
              },
              child: Container(
                height: 130,
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 2,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/util/report.png"),
                    const Text(
                      "All Sale Reports",
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(const ExpenseReport());
              },
              child: Container(
                height: 130,
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 2,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/util/expenses.png"),
                    const Text(
                      "Expense Reports",
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.snackbar("Sorry", "This feature is unavailable now");
              },
              child: Container(
                height: 130,
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 2,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/util/order.png"),
                    const Text(
                      "Monthly Reports",
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future dateRangePicker(BuildContext context) async {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: _dateTimeRange,
      firstDate: DateTime(2010),
      lastDate: DateTime(2100),
    );

    if (newDateRange == null) return;

    setState(() {
      _dateTimeRange = newDateRange;
    });

    _reportController.setDateRange(_dateTimeRange.start, _dateTimeRange.end);

    _orderController.getTotalOrder(
        start: DateFormat.yMd().format(_dateTimeRange.start),
        end: DateFormat.yMd().format(_dateTimeRange.end));

    _expenseController.getTotalExpense(
        start: DateFormat.yMd().format(_dateTimeRange.start),
        end: DateFormat.yMd().format(_dateTimeRange.end));
  }
}
