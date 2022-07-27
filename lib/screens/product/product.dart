import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos/controllers/product.controller.dart';
import 'package:flutter_pos/controllers/shop.controller.dart';
import 'package:flutter_pos/screens/product/add_product.dart';
import 'package:flutter_pos/screens/qr_scanner.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Product extends StatelessWidget {
  Product({Key? key}) : super(key: key);
  TextEditingController searchKey = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ProductController _controller = Get.put(ProductController());
    String currencySymbol = Get.find<ShopController>().shopInfo.currencySymbol;

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
      var productList = _controller.productList.toList();
      final excel = Excel.createExcel();
      final sheet = excel[excel.getDefaultSheet()!];

      List<String> dataList = [
        "Product Code",
        "Product Name",
        "Category",
        "qty",
        "Description",
        "Buy Price",
        "Sell Price",
        "Weight",
        "Weight Unit",
        "Supplier",
        "Image"
      ];
      sheet.insertRowIterables(dataList, 0);

      for (var i = 0; i < productList.length; i++) {
        var data = productList[i];

        List<String> list = [
          data.code,
          data.name,
          data.category.name,
          data.qty.toString(),
          data.description.toString(),
          data.buyPrice.toString(), //data.products.length.toString(),
          data.sellPrice.toString(),
          data.weight.toString(),
          data.weightUnit.toString(),
          data.supplier == null ? "" : data.supplier!.name.toString(),
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
            newPath = newPath + "/miniPOS/product";
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
              "Success", "Product export succss, view in ${directory.path}");
        }
      } catch (e) {}
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('All Products'),
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
                      controller: searchKey,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search...',
                      ),
                      onChanged: (value) {
                        _controller.getProduct(search: value);
                      },
                    ),
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                IconButton(
                  onPressed: () async {
                    String result = await Get.to(const QRScanner());
                    searchKey.text = result;
                    _controller.getProduct(search: result);
                  },
                  icon: const Icon(Icons.qr_code),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_controller.productList.isEmpty) {
                return const Center(
                  child: Text("No Data"),
                );
              }
              return ListView.builder(
                itemCount: _controller.productList.length,
                itemBuilder: (context, i) {
                  var _product = _controller.productList[i];
                  return GestureDetector(
                    onTap: () {
                      Get.to(const AddProduct(), arguments: _product);
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
                          _product.image == null
                              ? Image.asset(
                                  "assets/menu/productImg.png",
                                  width: 80,
                                )
                              : Image.memory(
                                  _product.image!,
                                  width: 80,
                                ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _product.name.toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(_product.supplier == null
                                    ? "Unknown"
                                    : "Supplier: ${_product.supplier?.name.toString()}"),
                                Text(
                                    "Buy Price: $currencySymbol ${_product.buyPrice}"),
                                Text(
                                    "Sell Price: $currencySymbol ${_product.sellPrice}"),
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
                                        _controller.delete(_product.id ?? 0);
                                        _controller.getProduct();
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(const AddProduct());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
