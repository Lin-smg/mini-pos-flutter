import 'package:flutter_pos/db/db_helper.dart';
import 'package:flutter_pos/models/product.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  List<Product> productList = <Product>[].obs;
  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    getProduct();
  }

  getProduct({String? search = "", String? category = ""}) async {
    List<Map<String, dynamic>> list =
        await query(query: search, category: category);
    // print("length ${list[1]['supplier']}");
    productList.assignAll(list.map((data) => Product.fromJson(data)).toList());
  }

  updateProductList(List<Map<String, dynamic>> productList) async {
    final db = await DBHelper.initDB();
    for (var product in productList) {
      await await db.rawUpdate(
        "UPDATE ${Tables.product} SET qty=qty-${product["qty"]} WHERE id=${product['id']}",
      );
      // .update(Tables.product, {"qty": }, where: "id = ?", whereArgs: [product["id"]]);
    }
  }

  Future<int> insert(Product product) async {
    // print("insert >> ${product.image}");
    final db = await DBHelper.initDB();
    // Get.snackbar("Success", "product add success");
    return await db.insert(Tables.product, product.toJson());
  }

  static Future<List<Map<String, dynamic>>> query(
      {String? query = "", String? category = ""}) async {
    print("query prod");
    final db = await DBHelper.initDB();
    return await db.query(Tables.product,
        orderBy: "createdAt DESC",
        where: "(name LIKE ? OR code LIKE ?) AND category LIKE ?",
        whereArgs: ["%$query%", "%$query%", "%$category%"]);
  }

  Future<int> updateProduct(int id, Product product) async {
    final db = await DBHelper.initDB();
    print("update");
    // Get.snackbar("Success", "product update success");
    return await db.update(Tables.product, product.toJson(),
        where: "id = ?", whereArgs: [id]);
  }

  Future<void> delete(int id) async {
    final db = await DBHelper.initDB();
    await db.delete(Tables.product, where: "id=?", whereArgs: [id]);
  }
}
