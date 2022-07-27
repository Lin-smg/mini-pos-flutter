import 'package:flutter_pos/db/db_helper.dart';
import 'package:flutter_pos/models/order.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  List<Order> orderList = <Order>[].obs;
  List<OrdinalSales> orderListGroup = <OrdinalSales>[].obs;

  var total = "0".obs;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    getOrder();
  }

  getOrder({String? start, String? end, String? search = ""}) async {
    print("order");
    List<Map<String, dynamic>> list = await query(search: search, start: start, end: end);

    orderList.assignAll(list.map((data) => Order.fromJson(data)).toList());
    print("order group by 11 ${orderList.length}");
    // getOrderGroupBy();
  }

  getOrderGroupBy() async {
    var groupByDate = orderList.map((data) {
      return {
        "date":
            "${data.date.split(" ")[1]} ${data.date.split(" ")[2].substring(0, data.date.split(" ")[2].length - 1)} ${data.date.split(" ")[3]}",
        "value": data.total
      };
    });
    var sumlist = Map();
    groupByDate.forEach((data) {
      if (sumlist.containsKey(data["date"])) {
        sumlist[data["date"]] += data['value'];
      } else {
        sumlist[data["date"]] = data['value'];
      }
    });
    List<OrdinalSales> list = <OrdinalSales>[];
    sumlist.forEach((key, value) {
      list.add(OrdinalSales(key, (value * 1).round()));
    });
    
    return list;
  }

  getTotalOrder({String? start, String? end}) async {
    final db = await DBHelper.initDB();
    var result = await db.rawQuery("""
    SELECT SUM(total) as sum FROM ${Tables.order} WHERE orderDate BETWEEN '$start' AND '$end'
    """);

    var value = result[0]["sum"] ?? 0;
    total.value = value.toString();
  }

  Future<int> insert(Order order) async {
    final db = await DBHelper.initDB();

    return await db.insert(Tables.order, order.toJson());
  }

  static Future<List<Map<String, dynamic>>> query(
      {String? start, String? end, String? search=""}) async {
    final db = await DBHelper.initDB();
    print("ooooo $start");
    if (start == null) {
      return await db.query(Tables.order, orderBy: "createdAt DESC", where: "orderId LIKE ? OR customer LIKE ?", 
      whereArgs: ["%$search%", "%$search%"]);
    } else {
      return await db.query(Tables.order,
          orderBy: "createdAt DESC",
          where: "(orderId LIKE ? OR customer LIKE ?) AND orderDate BETWEEN ? AND ?",
          whereArgs: ["%$search%", "%$search%", start, end]);
    }
  }

  Future<int> updateOrder(int id, Order order) async {
    final db = await DBHelper.initDB();
    // Get.snackbar("Success", "product update success");
    return await db
        .update(Tables.order, order.toJson(), where: "id = ?", whereArgs: [id]);
  }

  Future<void> delete(int id) async {
    final db = await DBHelper.initDB();
    await db.delete(Tables.order, where: "id=?", whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> queryGroupBy() async {
    final db = await DBHelper.initDB();
    return await db.query(Tables.order,
        orderBy: "createdAt DESC", groupBy: "date");
  }
}

class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
