// To parse this JSON data, do
//
//     final product = productFromJson(jsonString);

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_pos/models/category.dart';
import 'package:flutter_pos/models/supplier.dart';

Product productFromJson(String str) => Product.fromJson(json.decode(str));

String productToJson(Product data) => json.encode(data.toJson());

class Product {
    Product({
        this.id,
        required this.name,
        required this.code,
        this.image,
        required this.qty,
        this.description,
        required this.buyPrice,
        required this.sellPrice,
        this.weight,
        this.weightUnit,
        required this.category,
        this.supplier,
    });

    int? id;
    String name;
    String code;
    Uint8List? image;
    int qty;
    String? description;
    double buyPrice;
    double sellPrice;
    String? weight;
    String? weightUnit;
    Category category;
    Supplier? supplier;

    factory Product.fromJson(Map<String, dynamic> json) { 
      // print('supp ${json["supplier"]=='null'}');
      return Product(
        id: json["id"],
        name: json["name"],
        code: json["code"],
        image: json["image"],
        qty: json["qty"],
        description: json["description"],
        buyPrice: json["buyPrice"].toDouble(),
        sellPrice: json["sellPrice"].toDouble(),
        weight: json["weight"],
        weightUnit: json["weightUnit"],
        category: Category.fromJson(jsonDecode(json["category"])),
        supplier: json["supplier"] == 'null' ? null : Supplier.fromJson(jsonDecode(json["supplier"])),
    );
    }

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "code": code,
        "image": image,
        "qty": qty,
        "description": description,
        "buyPrice": buyPrice,
        "sellPrice": sellPrice,
        "weight": weight,
        "weightUnit": weightUnit,
        "category": jsonEncode(category.toJson()), //category.toJson(),
        "supplier": jsonEncode(supplier?.toJson()) //supplier?.toJson(),
    };
}
