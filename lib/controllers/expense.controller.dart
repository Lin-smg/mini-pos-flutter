import 'package:flutter/material.dart';
import 'package:flutter_pos/db/db_helper.dart';
import 'package:flutter_pos/models/expense.dart';
import 'package:get/get.dart';

class ExpenseController extends GetxController {
  List<Expense> expenseList = <Expense>[].obs;
  var total = "0".obs;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    getExpense();
    // getTotalExpense();
  }

  getExpense({String? start, String? end, String? search = ""}) async {
    List<Map<String, dynamic>> list = await query(start: start, end: end, search: search);

    expenseList.assignAll(list.map((data) => Expense.fromJson(data)).toList());
  }

  getTotalExpense({String? start, String? end}) async {
    final db = await DBHelper.initDB();
    var result = await db.rawQuery("""
    SELECT SUM(amount) as sum FROM ${Tables.expense} WHERE date BETWEEN '$start' AND '$end'
    """);

    var value = result[0]["sum"]??0;
    total.value = value.toString();

    debugPrint("Sum of Amount >>> $value");
  }

  Future<int> insert(Expense expense) async {
    debugPrint("insert");
    final db = await DBHelper.initDB();
    // Get.snackbar("Success", "expense add success");
    return await db.insert(Tables.expense, expense.toJson());
  }

  static Future<List<Map<String, dynamic>>> query(
      {String? start = null, String? end = null, String? search=""}) async {
    debugPrint("query $start -  $end");
    final db = await DBHelper.initDB();
    if (start == null) {
      return await db.query(Tables.expense, orderBy: "createdAt DESC", where: "name LIKE ?", whereArgs: ["%$search%"]);
    } else {
      return await db.query(Tables.expense,
          orderBy: "createdAt DESC",
          where: "name LIKE ? and date>= ? AND date<=?",
          whereArgs: ["%$search%", start, end]);
    }
  }

  Future<int> updateExpense(int id, Expense expense) async {
    final db = await DBHelper.initDB();
    debugPrint("update");
    // Get.snackbar("Success", "expense update success");
    return await db.update(Tables.expense, expense.toJson(),
        where: "id = ?", whereArgs: [id]);
  }

  Future<void> delete(int id) async {
    final db = await DBHelper.initDB();
    await db.delete(Tables.expense, where: "id=?", whereArgs: [id]);
  }
}
