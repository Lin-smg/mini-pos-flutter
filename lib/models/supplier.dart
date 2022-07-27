// To parse this JSON data, do
//
//     final supplier = supplierFromJson(jsonString);

import 'dart:convert';

Supplier supplierFromJson(String str) => Supplier.fromJson(json.decode(str));

String supplierToJson(Supplier data) => json.encode(data.toJson());

class Supplier {
    Supplier({
        this.id,
        required this.name,
        this.phone,
        this.email,
        this.address,
    });

    int? id;
    String name;
    String? phone;
    String? email;
    String? address;

    factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
        id: json["id"],
        name: json["name"],
        phone: json["phone"],
        email: json["email"],
        address: json["address"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "email": email,
        "address": address,
    };
}
