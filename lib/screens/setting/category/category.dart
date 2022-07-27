import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos/controllers/category.controller.dart';
import 'package:flutter_pos/screens/setting/category/add_category.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class Category extends StatelessWidget {
  const Category({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CategoryController _controller = Get.put(CategoryController());
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
      var categoryList = _controller.categoryList.toList();
      final excel = Excel.createExcel();
      final sheet = excel[excel.getDefaultSheet()!];

      List<String> dataList = [
        "Id",
        "Name",
      ];
      sheet.insertRowIterables(dataList, 0);

      for (var i = 0; i < categoryList.length; i++) {
        var data = categoryList[i];

        List<String> list = [
          data.id.toString(),
          data.name,
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
            newPath = newPath + "/miniPOS/category";
            directory = Directory(newPath);
          }
        }
        if (!await directory!.exists()) {
          await directory.create(recursive: true);
        }
        if (await directory.exists()) {
          String fileName = DateTime.now().toString().split(" ")[0] +
              "-" +
              DateTime.now().millisecondsSinceEpoch.toString();
          File(directory.path + "/$fileName.xlsx")
            ..createSync(recursive: true)
            ..writeAsBytesSync(excel.encode()!);

          Get.snackbar(
              "Success", "Category export succss, view in ${directory.path}");
        }
      } catch (e) {}
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("All Category"),
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
                        _controller.getCategory(search: value);
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search...',
                      ),
                    ),
                  ),
                ),
                IconButton(onPressed: () {
                  _controller.getCategory(search: _searchKey.text);
                }, icon: const Icon(Icons.search))
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_controller.categoryList.isEmpty) {
                return const Center(
                  child: Text("No Data"),
                );
              }
              return ListView.builder(
                  itemCount: _controller.categoryList.length,
                  itemBuilder: (context, i) {
                    var _category = _controller.categoryList[i];
                    return GestureDetector(
                      onTap: () =>
                          Get.to(const AddCategory(), arguments: _category),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.white,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/menu/category.png",
                              height: 50,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Text(
                              _category.name.toString(),
                              style: const TextStyle(fontSize: 18),
                            )),
                            InkWell(
                              onTap: () {
                                Get.defaultDialog(
                                  title: "Delete",
                                  content: const Center(
                                    child: Text("Are you sure ? "),
                                  ),
                                  onCancel: () => {},
                                  onConfirm: () {
                                    _controller.delete(_category.id ?? 0);
                                    _controller.getCategory();
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
                      ),
                    );
                  });
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(const AddCategory());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
