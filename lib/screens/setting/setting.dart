import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos/screens/setting/category/category.dart';
import 'package:flutter_pos/screens/setting/payment/payment.dart';
import 'package:flutter_pos/screens/setting/shop_info.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class Setting extends StatelessWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text("Settings"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _settingMenu(context,
                icon: "assets/util/store.png",
                label: "Shop Information", onTap: () {
              Get.to(ShopInfo());
            }),
            _settingMenu(context,
                icon: "assets/menu/category.png", label: "Category", onTap: () {
              Get.to(Category());
            }),
            _settingMenu(context,
                icon: "assets/util/payment.png",
                label: "Payment Method", onTap: () {
              Get.to(PaymentMethod());
            }),
            _settingMenu(context,
                icon: "assets/util/storage.png",
                label: "Data Backup", onTap: () {
              _backupDB();
              // _openFile();
            }),
            _settingMenu(context,
                icon: "assets/util/database_restore.png",
                label: "Restore Data", onTap: () {
              _restoreDB();
            }),
          ],
        ),
      ),
    );
  }

  _settingMenu(BuildContext context,
      {required String icon, required String label, Null Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 130,
        padding: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 2,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(icon),
            Text(
              label,
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
      ),
    );
  }

  _backupDB() async {
    final dbFolder = await getDatabasesPath();
    File file = File("$dbFolder/pos.db");

    Directory copyTo = Directory("storage/emulated/0/POS_Backup");

    if (await _requestPermission(Permission.storage) &&
        await _requestPermission(Permission.accessMediaLocation) &&
        await _requestPermission(Permission.manageExternalStorage)) {
      if (await copyTo.exists()) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
      } else {
        print("not exist path");
        if (await Permission.storage.request().isGranted) {
          await copyTo.create();
        } else {
          print("please give permission");
          await Permission.storage.request();
        }
      }
    }

    String newPath =
        "${copyTo.path}/${DateTime.now().millisecondsSinceEpoch}pos.db";

    print("copy >> $file >>>> $newPath");
    await file.copySync(newPath);

    print("back successs");
    Get.snackbar("Success", "Database backup success");

    await FilePicker.platform.pickFiles(initialDirectory: copyTo.path);
  }

  _restoreDB() async {
    var databasePath = await getDatabasesPath();
    var dbPath = "$databasePath/pos.db";

    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) {
      return;
    }
    File source = File(result.files.single.path!);

    await source.copy(dbPath);
    print("reatore success");

    Get.snackbar("Success", "Database Restore success");
  }

  // _openFile() async {
  //   var filePath  = "";
  //   final _result = await FilePicker.platform.pickFiles(allowMultiple: false);
  //   if (_result != null) {
  //     filePath = _result.files.single.path!;
  //   }
  //   final dbFolder= await getDatabasesPath() + "/pos.db";
  //   final result = OpenFile.open(dbFolder);

  //   print("path >>>>> $dbFolder");
  // }

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
}
