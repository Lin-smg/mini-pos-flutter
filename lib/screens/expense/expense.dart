import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos/controllers/expense.controller.dart';
import 'package:flutter_pos/controllers/shop.controller.dart';
import 'package:flutter_pos/models/shop.dart';
import 'package:flutter_pos/screens/expense/add_expense.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Expense extends StatefulWidget {
  const Expense({Key? key}) : super(key: key);

  @override
  State<Expense> createState() => _ExpenseState();
}

class _ExpenseState extends State<Expense> {
  ExpenseController _controller = Get.put(ExpenseController());
  DateTimeRange _dateTimeRange =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());

  TextEditingController _searchKey = TextEditingController();
  
  String currencySymbol = "\$";

  @override
  void initState() {
    super.initState();
    
    Shop shop = Get.find<ShopController>().shopInfo;

    currencySymbol = shop.currencySymbol;
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

    // _controller.setDateRange(_dateTimeRange.start, _dateTimeRange.end);

    _controller.getExpense(
        search: _searchKey.text,
        start: DateFormat.yMd().format(_dateTimeRange.start),
        end: DateFormat.yMd().format(_dateTimeRange.end));
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _requestPermission(Permission permission) async {
      if (await permission.isGranted) {
        return true;
      } else {
        var result = await permission.request();
        if (result == PermissionStatus.granted) {
          return true;
        } else {
          return false;
        }
      }
    }

    exportExcel() async {
      var expenseList = _controller.expenseList.toList();
      final excel = Excel.createExcel();
      final sheet = excel[excel.getDefaultSheet()!];

      List<String> dataList = [
        "Name",
        "Amount",
        "Date",
        "Time",
        "Note",
      ];
      sheet.insertRowIterables(dataList, 0);

      for (var i = 0; i < expenseList.length; i++) {
        var data = expenseList[i];

        List<String> list = [
          data.name,
          data.amount.toString(),
          data.date.toString(),
          data.time.toString(),
          data.note.toString(),
          // data.image
        ];
        sheet.appendRow(list);
      }

      Directory? directory;

      try {
        if (Platform.isAndroid) {
          if (await _requestPermission(Permission.storage) &&
              await _requestPermission(Permission.accessMediaLocation) &&
              await _requestPermission(Permission.manageExternalStorage)) {
            directory = await getExternalStorageDirectory();
            List<String> folders = directory!.path.split("/");
            String newPath = "";
            for (int i = 1; i < folders.length; i++) {
              String folder = folders[i];
              if (folder != "Android") {
                newPath += "/" + folder;
              } else {
                break;
              }
            }
            newPath = newPath + "/miniPOS/expense";
            directory = Directory(newPath);
            print('success ${await directory.exists()}}');
          }
        }
        if (!await directory!.exists()) {
          await directory.create(recursive: true);
        }
        if (await directory.exists()) {
          // File savefile = File(directory.path + "/test.txt");
          String fileName = DateTime.now().toString().split(" ")[0] +
              "-" +
              DateTime.now().millisecondsSinceEpoch.toString();
          File(directory.path + "/$fileName.xlsx")
            ..createSync(recursive: true)
            ..writeAsBytesSync(excel.encode()!);

          Get.snackbar(
              "Success", "Expense export succss, view in ${directory.path}");
        }
      } catch (e) {}
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Expense"),
        actions: [
          IconButton(
              onPressed: () {
                dateRangePicker(context);
              },
              icon: const Icon(Icons.calendar_today)),
          PopupMenuButton(
              onSelected: (value) {
                if (value == 1) {
                  exportExcel();
                }
              },
              icon: const Icon(Icons.more_horiz),
              itemBuilder: (context) => [
                    const PopupMenuItem(
                      child: Text("Export Excel"),
                      value: 1,
                    )
                  ])
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blueAccent, //const Color(0xffd8d8d8),
                width: 2,
              ),
              color: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: TextField(
                      controller: _searchKey,
                      onChanged: (value) {
                        _controller.getExpense(
                            search: value,
                            start:
                                DateFormat.yMd().format(_dateTimeRange.start),
                            end: DateFormat.yMd().format(_dateTimeRange.end));
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search...',
                      ),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      _controller.getExpense(
                          search: _searchKey.text,
                          start: DateFormat.yMd().format(_dateTimeRange.start),
                          end: DateFormat.yMd().format(_dateTimeRange.end));
                    },
                    icon: const Icon(Icons.search)),
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () { 
                if(_controller.expenseList.isEmpty) {
                  return const Center(child: Text("No Data"),);
                }
                return ListView.builder(
                itemCount: _controller.expenseList.length,
                itemBuilder: (context, i) {
                  var _expense = _controller.expenseList[i];
                  return GestureDetector(
                    onTap: () {
                      Get.to(const AddExpense(), arguments: _expense);
                      _controller.getExpense();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      padding: const EdgeInsets.all(5),
                      // height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(const Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            // spreadRadius: 2,
                            blurRadius: 2,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Image.asset("assets/menu/expenseImg.png"),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _expense.name.toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text("$currencySymbol ${_expense.amount}"),
                                Text("${_expense.date} ${_expense.time}"),
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Get.defaultDialog(
                                      title: "Delete",
                                      content: const Center(
                                        child: Text("Are you sure ? "),
                                      ),
                                      onCancel: () => {},
                                      onConfirm: () {
                                        _controller.delete(_expense.id ?? 0);
                                        _controller.getExpense();
                                        Get.back();
                                      },
                                    );
                                  },
                                  child: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
              }
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(const AddExpense());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
