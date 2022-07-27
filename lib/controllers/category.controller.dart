import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_pos/db/db_helper.dart';
import 'package:flutter_pos/models/category.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  List<Category> categoryList = <Category>[].obs;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    getCategory();
  }

  getCategory({String? search = ""}) async {
    List<Map<String, dynamic>> list = await query(search: search);

    categoryList.assignAll(list.map((data) => Category.fromJson(data)).toList());
  }

  Future<int> insert(Category category) async {
    debugPrint("insert");
    final db = await DBHelper.initDB();
    // Get.snackbar("Success", "category add success");
    return await db.insert(Tables.category, category.toJson());
  }

  static Future<List<Map<String, dynamic>>> query({String? search=""}) async {
    
    final db = await DBHelper.initDB();
    return await db.query(Tables.category, orderBy: "createdAt DESC", where: "name LIKE ?", whereArgs: ["%$search%"]);
  }

  Future<int> updateCategory(int id, Category category) async {
    final db = await DBHelper.initDB();
    
    // Get.snackbar("Success", "category update success");
    return await db
        .update(Tables.category, category.toJson(), where: "id = ?", whereArgs: [id]);
  }

  Future<void> delete(int id) async {
    final db = await DBHelper.initDB();
    await db.delete(Tables.category, where: "id=?", whereArgs: [id]);
  }
}