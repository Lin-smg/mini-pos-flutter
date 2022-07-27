// To parse this JSON data, do
//
//     final shop = shopFromJson(jsonString);

import 'dart:convert';

Shop shopFromJson(String str) => Shop.fromJson(json.decode(str));

String shopToJson(Shop data) => json.encode(data.toJson());

class Shop {
    Shop({
         this.id,
        required this.name,
        required this.phone,
        required this.email,
        required this.address,
        required this.currencySymbol,
        required this.tax,
    });

    int? id;
    String name;
    String phone;
    String email;
    String address;
    String currencySymbol;
    double tax;

    factory Shop.fromJson(Map<String, dynamic> json) => Shop(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        address: json["address"],
        currencySymbol: json["currencySymbol"],
        tax: json["tax"].toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "email": email,
        "address": address,
        "currencySymbol": currencySymbol,
        "tax": tax,
    };
}
