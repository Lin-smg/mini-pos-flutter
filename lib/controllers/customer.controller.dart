import 'package:flutter/cupertino.dart';
import 'package:flutter_pos/db/db_helper.dart';
import 'package:flutter_pos/models/customer.dart';
import 'package:get/get.dart';

class CustomerController extends GetxController {
  List<Customer> customerList = <Customer>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    debugPrint("init");
    getCustomer();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    debugPrint("onready");
  }
  

  getCustomer({String? search = ""}) async{
    List<Map<String, dynamic>> list = await query(search: search);

    customerList.assignAll(list.map((data) => Customer.fromJson(data)).toList());
  }

  Future<int> insert(Customer customer) async {
    debugPrint("insert");
    final db = await DBHelper.initDB();
    // Get.snackbar("Success", "customer add success");
    return await db.insert(Tables.customer, customer.toJson());
  }

  static Future<List<Map<String, dynamic>>> query({String? search = ""}) async {
    debugPrint("query store");
    final db = await DBHelper.initDB();
    return await db.query(Tables.customer, orderBy: "createdAt DESC", where: "name LIKE ? OR phone LIKE ?", whereArgs: ["%$search%", "%$search%"]);
  }

  Future<int> updateCustomer(int id, Customer customer) async {
    final db = await DBHelper.initDB();
    debugPrint("update");
    Get.snackbar("Success", "customer update success");
    return await db
        .update(Tables.customer, customer.toJson(), where: "id = ?", whereArgs: [id]);
  }

  Future<void> delete(int id) async {
    final db = await DBHelper.initDB();
    await db.delete(Tables.customer, where: "id=?", whereArgs: [id]);
  }

}