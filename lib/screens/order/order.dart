import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos/controllers/order.controller.dart';
import 'package:flutter_pos/controllers/shop.controller.dart';
import 'package:flutter_pos/screens/order/orderDetail.dart';
import 'package:flutter_pos/screens/pos/receipt.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

import '../home.dart';

class Order extends StatefulWidget {
  const Order({Key? key}) : super(key: key);

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  DateTimeRange _dateTimeRange =
      DateTimeRange(start: DateTime.now(), end: DateTime.now());
  OrderController _controller = Get.put(OrderController());
  TextEditingController _searchKey = TextEditingController();

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

    _controller.getOrder(
        search: _searchKey.text,
        start: DateFormat('yyyy-MM-dd').format(_dateTimeRange.start).toString(),//DateFormat.yMd().format(_dateTimeRange.start),
        end: DateFormat('yyyy-MM-dd').format(_dateTimeRange.end).toString());//DateFormat.yMd().format(_dateTimeRange.end));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.getOrder(
        search: _searchKey.text,
        start: DateFormat('yyyy-MM-dd').format(_dateTimeRange.start).toString(),
        end: DateFormat('yyyy-MM-dd').format(_dateTimeRange.end).toString());
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
      var orderList = _controller.orderList.toList();

      final excel = Excel.createExcel();
      final sheet = excel[excel.getDefaultSheet()!];

      List<String> dataList = [
        "Order No",
        "Customer Name",
        "Date",
        "Order Type",
        "Payment Type",
        "Item Count",
        "Sub Total",
        "Total Tax",
        "Total Discount",
        "Total",
        "Status"
      ];
      sheet.insertRowIterables(dataList, 0);

      for (var i = 0; i < orderList.length; i++) {
        var data = orderList[i];
        int count = 0;
        for (var element in data.products) {
          count += int.parse(element["qty"].toString());
        }

        List<String> list = [
          data.orderId,
          data.customer.name,
          data.date,
          data.orderType,
          data.payType,
          count.toString(), //data.products.length.toString(),
          data.subTotal.toString(),
          data.totalTax.toString(),
          data.totalDiscount.toString(),
          data.total.toString(),
          data.status.toString()
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
            newPath = newPath + "/miniPOS/order";
            directory = Directory(newPath);
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
              "Success", "Order export succss, view in ${directory.path}");
        }
      } catch (e) {}
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Orders"),
        leading: InkWell(
            onTap: () {
              Get.offUntil(
                  GetPageRoute(
                      page: () => Home(
                            shopInfo: Get.put(ShopController()).shopInfo,
                          )),
                  (route) => false);
            },
            child: const Icon(Icons.arrow_back)),
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
                        _controller.getOrder(
                            search: value,
                            start:
                                DateFormat.yMd().format(_dateTimeRange.start),
                            end: DateFormat.yMd().format(_dateTimeRange.end));
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search...',
                      ),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      _controller.getOrder(
                          search: _searchKey.text,
                          start: DateFormat.yMd().format(_dateTimeRange.start),
                          end: DateFormat.yMd().format(_dateTimeRange.end));
                    },
                    icon: const Icon(Icons.search)),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_controller.orderList.isEmpty) {
                return const Center(
                  child: Text("No Order"),
                );
              }
              return ListView.builder(
                itemCount: _controller.orderList.length,
                itemBuilder: (context, i) {
                  var _order = _controller.orderList[i];
                  return GestureDetector(
                    onTap: () {
                      Get.to(const OrderDetail(), arguments: _order);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      padding: const EdgeInsets.all(5),
                      // height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
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
                          Column(
                            children: [
                              Image.asset("assets/menu/orderImg.png"),
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(3)),
                                ),
                                child: Center(
                                  child: Text(
                                      _order.status ?? "Pending".toString()),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _order.customer.name.toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text("Order ID: ${_order.orderId}"),
                                Text("Payment Type: ${_order.payType}"),
                                Text("Order Type: ${_order.orderType}"),
                                Text("${_order.orderDate}"),
                                // Text(DateFormat('yyyy-MM-dd').format(DateTime.now()).toString())
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
                                        _controller.delete(_order.id ?? 0);
                                        _controller.getOrder();
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
            }),
          )
        ],
      ),
    );
  }
}
