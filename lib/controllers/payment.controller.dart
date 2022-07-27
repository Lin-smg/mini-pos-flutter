import 'package:flutter_pos/db/db_helper.dart';
import 'package:flutter_pos/models/payment.dart';
import 'package:get/get.dart';

class PaymentController extends GetxController {
  List<Payment> paymentList = <Payment>[].obs;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    getPayment();
  }

  getPayment() async {
    List<Map<String, dynamic>> list = await query();

    paymentList.assignAll(list.map((data) => Payment.fromJson(data)).toList());
  }

  Future<int> insert(Payment payment) async {
    print("insert");
    final db = await DBHelper.initDB();
    // Get.snackbar("Success", "payment add success");
    return await db.insert(Tables.payment, payment.toJson());
  }

  static Future<List<Map<String, dynamic>>> query() async {
    // ignore: avoid_print
    print("query");
    final db = await DBHelper.initDB();
    return await db.query(Tables.payment, orderBy: "createdAt DESC");
  }

  Future<int> updatePayment(int id, Payment payment) async {
    final db = await DBHelper.initDB();
    print("update");
    // Get.snackbar("Success", "payment update success");
    return await db
        .update(Tables.payment, payment.toJson(), where: "id = ?", whereArgs: [id]);
  }

  Future<void> delete(int id) async {
    final db = await DBHelper.initDB();
    await db.delete(Tables.payment, where: "id=?", whereArgs: [id]);
  }
}