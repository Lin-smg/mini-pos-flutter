import 'package:flutter_pos/db/db_helper.dart';
import 'package:flutter_pos/models/shop.dart';

class ShopTB {
  static Future<int> insert(Shop shop) async{
    print("insert");
    final db = await DBHelper.initDB();
    return await db.insert(Tables.shop, shop.toJson());
  }

  static Future<List<Map<String, dynamic>>> query() async {
    print("query store");
    final db = await DBHelper.initDB();
    return await db.query(Tables.shop);
  }
}