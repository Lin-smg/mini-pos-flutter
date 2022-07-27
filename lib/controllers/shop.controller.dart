import 'package:flutter_pos/db/db_helper.dart';
import 'package:flutter_pos/models/shop.dart';
import 'package:get/get.dart';

class ShopController extends GetxController {
  final shop = Shop(
          name: "",
          phone: "",
          email: "",
          address: "",
          currencySymbol: "",
          tax: 0)
      .obs;
  var ss = "hello".obs;

  Shop get shopInfo => shop.value;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getShop();
  }

  Future<Shop?> getShop() async {
    List<Map<String, dynamic>> _shop = await query();
    if (!_shop.isEmpty) {
      shop.value = Shop.fromJson(_shop[0]);
      print("get Shop ${_shop.isEmpty}");

      return Shop.fromJson(_shop[0]);
    } else {
      return null;
    }
  }

  void insertShop(Shop shop) async {
    int id = await insert(shop);
  }

  static Future<int> insert(Shop shop) async {
    print("insert");
    final db = await DBHelper.initDB();
    Get.snackbar("Success", "shop add success");
    return await db.insert(Tables.shop, shop.toJson());
  }

  static Future<List<Map<String, dynamic>>> query() async {
    print("query store");
    final db = await DBHelper.initDB();
    return await db.query(Tables.shop);
  }

  Future<int> updateShop(int id, Shop shop) async {
    final db = await DBHelper.initDB();
    print("update");
    Get.snackbar("Success", "shop update success");
    return await db
        .update(Tables.shop, shop.toJson(), where: "id = ?", whereArgs: [id]);
  }
}
