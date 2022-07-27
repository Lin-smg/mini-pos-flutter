import 'package:flutter_pos/db/db_helper.dart';
import 'package:flutter_pos/models/supplier.dart';
import 'package:get/get.dart';

class SupplierController extends GetxController {
  List<Supplier> supplierList = <Supplier>[].obs;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    getSupplier();
  }

  getSupplier({String? search = ""}) async{
    List<Map<String,dynamic>> list = await query(search: search);

    supplierList.assignAll(list.map((data) => Supplier.fromJson(data)).toList());
  }

  addSupplier(supplier) async {
    insert(supplier).then((value){
      getSupplier();
      Get.back();
    });
    // getSupplier();
    // Get.back();
  }

  Future<int> insert(Supplier supplier) async {
    print("insert");
    final db = await DBHelper.initDB();
    Get.snackbar("Success", "supplier add success");
    return await db.insert(Tables.supplier, supplier.toJson());
  }

  static Future<List<Map<String, dynamic>>> query({String? search = ""}) async {
    final db = await DBHelper.initDB();
    return await db.query(Tables.supplier, orderBy: "createdAt DESC", where: "name LIKE ? OR phone LIKE ?", whereArgs: ["%$search%", "%$search%"]);
  }

  Future<int> updateSupplier(int id, Supplier supplier) async {
    final db = await DBHelper.initDB();
    print("update");
    Get.snackbar("Success", "supplier update success");
    return await db
        .update(Tables.supplier, supplier.toJson(), where: "id = ?", whereArgs: [id]);
  }

  Future<void> delete(int id) async {
    final db = await DBHelper.initDB();
    await db.delete(Tables.supplier, where: "id=?", whereArgs: [id]);
  }
}