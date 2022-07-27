// To parse this JSON data, do
//
//     final expense = expenseFromJson(jsonString);

import 'dart:convert';

Expense expenseFromJson(String str) => Expense.fromJson(json.decode(str));

String expenseToJson(Expense data) => json.encode(data.toJson());

class Expense {
    Expense({
        this.id,
        required this.name,
        required this.amount,
        required this.date,
        required this.time,
        this.note,
    });

    int? id;
    String name;
    double amount;
    String date;
    String time;
    String? note;

    factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json["id"],
        name: json["name"],
        amount: json["amount"].toDouble(),
        date: json["date"],
        time: json["time"],
        note: json["note"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "amount": amount,
        "date": date,
        "time": time,
        "note": note,
    };
}
