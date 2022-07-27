import 'package:flutter/material.dart';
import 'package:flutter_pos/controllers/shop.controller.dart';
import 'package:flutter_pos/db/db_helper.dart';
import 'package:flutter_pos/models/shop.dart';
import 'package:flutter_pos/screens/customer/customer.dart';
import 'package:flutter_pos/screens/expense/expense.dart';
import 'package:flutter_pos/screens/order/order.dart';
import 'package:flutter_pos/screens/pos/pos.dart';
import 'package:flutter_pos/screens/product/product.dart';
import 'package:flutter_pos/screens/report/report.dart';
import 'package:flutter_pos/screens/setting/setting.dart';
import 'package:flutter_pos/screens/supplier/supplier.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  Home({Key? key, required this.shopInfo}) : super(key: key);
  Shop shopInfo;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // print('home home ${widget.shopInfo.name}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                right: 16),
            height: MediaQuery.of(context).padding.top + 160,
            child: Column(
              children: [
                Container(
                  // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Smart POS",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Icon(
                        Icons.translate,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Image.asset(
                      "assets/logo.png",
                      width: 100,
                      height: 70,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.shopInfo.name.toString(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          widget.shopInfo.phone,
                          style: const TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    const SizedBox(
                      width: 10,
                    )
                  ],
                )
              ],
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xffcf815c), Color(0xa32028f3)],
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
          ),
          Expanded(
            child: GridView(
              addRepaintBoundaries: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              children: [
                _menuItem(context, "assets/menu/pos.png", "POS", onTap: () {
                  Get.to(const POS());
                }),
                _menuItem(context, "assets/menu/products.png", "Products",
                    onTap: () {
                  Get.to(Product());
                }),
                _menuItem(context, "assets/menu/customer.png", "Customers",
                    onTap: () {
                  Get.to(Customer());
                }),
                _menuItem(context, "assets/menu/supplier.png", "Suppliers",
                    onTap: () {
                  Get.to(const Supplier());
                }),
                _menuItem(context, "assets/menu/order.png", "Orders",
                    onTap: () {
                  Get.to(const Order());
                }),
                _menuItem(context, "assets/menu/expense.png", "Expense",
                    onTap: () {
                  Get.to(const Expense());
                }),
                _menuItem(context, "assets/menu/report.png", "Report",
                    onTap: () {
                  Get.snackbar("Sorry ! ", "This feature is unavailable now");
                  // Get.to(const Report());
                }),
                _menuItem(context, "assets/menu/setting.png", "Setting",
                    onTap: () {
                  Get.to(const Setting());
                })
              ],
            ),
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [Text("Version 0.1.0")],
          // )
        ],
      ),
    );
  }

  _menuItem(BuildContext context, String avator, String title,
      {Null Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(avator),
            const SizedBox(
              height: 15,
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
          ],
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
    );
  }
}
