import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos/controllers/supplier.controller.dart';
import 'package:flutter_pos/screens/supplier/add_supplier.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class Supplier extends StatelessWidget {
  const Supplier({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SupplierController _controller = Get.put(SupplierController());
    TextEditingController _searchKey = TextEditingController();

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
      var supplierList = _controller.supplierList.toList();
      final excel = Excel.createExcel();
      final sheet = excel[excel.getDefaultSheet()!];

      List<String> dataList = [
        "Name",
        "Phone",
        "Email",
        "Address",
      ];
      sheet.insertRowIterables(dataList, 0);

      for (var i = 0; i < supplierList.length; i++) {
        var data = supplierList[i];

        List<String> list = [
          data.name,
          data.phone.toString(),
          data.email.toString(),
          data.address.toString(),
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
            newPath = newPath + "/miniPOS/supplier";
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
              "Success", "Supplier export succss, view in ${directory.path}");
        }
      } catch (e) {}
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('All Suppliers'),
        actions: [
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
                        _controller.getSupplier(search: value);
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search...',
                      ),
                    ),
                  ),
                ),
                IconButton(onPressed: () {
                  _controller.getSupplier(search: _searchKey.text);
                }, icon: const Icon(Icons.search))
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: _controller.supplierList.length,
                itemBuilder: (context, i) {
                  var _supplier = _controller.supplierList[i];
                  return GestureDetector(
                    onTap: () async {
                      await Get.to(AddSupplier(), arguments: _supplier);
                      _controller.getSupplier();
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
                          Image.asset("assets/menu/supplier.png"),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _supplier.name.toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(_supplier.phone.toString()),
                                Text(_supplier.email.toString()),
                                Text(_supplier.address.toString()),
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    Get.defaultDialog(
                                      title: "Delete",
                                      content: const Center(
                                        child: Text("Are you sure ? "),
                                      ),
                                      onCancel: () => {},
                                      onConfirm: () {
                                        _controller.delete(_supplier.id ?? 0);
                                        _controller.getSupplier();
                                        Get.back();
                                      },
                                    );
                                  },
                                  child: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                InkWell(
                                  onTap: () {
                                    launch("tel://${_supplier.phone}");
                                  },
                                  child: const Icon(Icons.phone, color: Colors.blueGrey)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(const AddSupplier());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
