// To parse this JSON data, do
//
//     final order = orderFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_pos/models/customer.dart';
import 'package:flutter_pos/models/product.dart';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());


class Order {
    Order({
        this.id,
        required this.orderId,
        required this.date,
        required this.subTotal,
        required this.total,
        required this.totalTax,
        required this.totalDiscount,
        required this.orderType,
        required this.payType,
        this.payAmount,
        this.change,
        required this.customer,
        required this.products,
        this.status,
        this.orderDate
    });

    int? id;
    String orderId;
    String date;
    double subTotal;
    double total;
    double totalTax;
    double totalDiscount;
    String orderType;
    String payType;
    double? payAmount = 0.0;
    double? change = 0.0;
    Customer customer;
    List<Map<String, dynamic>> products;
    String? status;
    String? orderDate;

    factory Order.fromJson(Map<String, dynamic> json) { 
      return Order(
        id: json["id"],
        orderId: json["orderId"],
        date: json["date"],
        subTotal: json["subTotal"].toDouble(),
        total: json["total"].toDouble(),
        totalTax: json["totalTax"].toDouble(),
        totalDiscount: json["totalDiscount"].toDouble(),
        orderType: json["orderType"],
        payType: json["payType"],
        payAmount: json["payAmount"],
        change: json["change"],
        status: json["status"],
        customer: Customer.fromJson(jsonDecode(json["customer"])),
        products: List<Map<String, dynamic>>.from(jsonDecode(json["products"]).map((x)=>x)),
        orderDate: json["orderDate"]
    );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "orderId": orderId,
        "date": date,
        "subTotal": subTotal,
        "total": total,
        "totalTax": totalTax,
        "totalDiscount": totalDiscount,
        "orderType": orderType,
        "payType": payType,
        "payAmount": payAmount,
        "change": change,
        "status": status,
        "customer": jsonEncode(customer.toJson()),
        "products": jsonEncode(products),//List<Product>.from(products.map((x) => x)),
        "orderDate": orderDate
    };
}


