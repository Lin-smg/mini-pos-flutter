import 'package:flutter/material.dart';
import 'package:flutter_pos/components/inputfield.dart';
import 'package:flutter_pos/controllers/order.controller.dart';
import 'package:flutter_pos/controllers/product.controller.dart';
import 'package:flutter_pos/controllers/shop.controller.dart';
import 'package:flutter_pos/models/order.dart';
import 'package:flutter_pos/models/product.dart';
import 'package:flutter_pos/models/shop.dart';
import 'package:flutter_pos/screens/pos/receipt.dart';
import 'package:get/get.dart';

import 'package:flutter_pos/screens/order/order.dart' as wOrder;

class OrderDetail extends StatefulWidget {
  const OrderDetail({Key? key}) : super(key: key);

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  String currencySymbol = "\$";
  final ProductController _productController = Get.put(ProductController());
  late Order _order;
  late List<Product> _productList;

  final OrderController _orderController = Get.put(OrderController());
  TextEditingController payAmount = TextEditingController();
  double userPayAmount = 0;

  getProduct() async {
    await _productController.getProduct();
    _productList = _productController.productList;

    _productList = _productController.productList
        .where((element) =>
            _order.products.indexWhere((e) => e["id"] == element.id) != -1)
        .map((d) {
      d.qty = _order.products.firstWhere((data) => data["id"] == d.id)["qty"];
      return d;
    }).toList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Shop shop = Get.find<ShopController>().shopInfo;

    currencySymbol = shop.currencySymbol;

    _order = Get.arguments;
    payAmount.text = "0";
    getProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Get.offUntil(
                GetPageRoute(page: () => wOrder.Order()), (route) => false);
          },
          child: const Icon(Icons.arrow_back),
        ),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Product OrderDetail"),
        actions: [],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              List<Product> _list = _productController.productList
                  .where((element) =>
                      _order.products
                          .indexWhere((e) => e["id"] == element.id) !=
                      -1)
                  .map((d) {
                d.qty = _order.products
                    .firstWhere((data) => data["id"] == d.id)["qty"];
                return d;
              }).toList();

              return ListView.builder(
                  itemCount: _list.length,
                  itemBuilder: (context, i) {
                    var _product = _list[i];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      padding: const EdgeInsets.all(5),
                      // height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(const Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            // spreadRadius: 2,
                            blurRadius: 2,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _product.image == null
                              ? Image.asset(
                                  "assets/menu/productImg.png",
                                  width: 100,
                                )
                              : Image.memory(
                                  _product.image!,
                                  width: 100,
                                  height: 100,
                                ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _product.name.toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                    "Price: $currencySymbol ${_product.sellPrice}"),
                                Text("X ${_product.qty}")
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          )
                        ],
                      ),
                    );
                  });
            }),
          ),
          Container(
            // margin: const EdgeInsets.symmetric(horizontal: 10),
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Sub Total",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.normal),
                    ),
                    Text("$currencySymbol ${_order.subTotal}"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Tax",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.normal),
                    ),
                    Text("$currencySymbol ${_order.totalTax}"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Discount",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.normal),
                    ),
                    Text("$currencySymbol ${_order.totalDiscount}"),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "$currencySymbol ${_order.subTotal + _order.totalTax - _order.totalDiscount}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _order.status != "Completed"
                        ? Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                _showPaymentDialog(context);
                              },
                              child: const Text(
                                "Payment",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        : Container(),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          var back =
                              await Get.to(const Receipt(), arguments: _order);
                          print('back $back');
                        },
                        child: const Text(
                          "Receipt",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _showPaymentDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Payment"),
                  InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.red,
                      ))
                ],
              ),
              content: Container(
                height: 300,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: InputField(
                            context,
                            label: "Pay Amount",
                            placeholder: "amount",
                            widget: TextField(
                              style: const TextStyle(height: 1),
                              keyboardType: TextInputType.number,
                              controller: payAmount,
                              onChanged: (value) {
                                setState(() {
                                  userPayAmount =
                                      double.parse(value.isEmpty ? '0' : value);
                                });
                              },
                            ),
                          ),
                        ),
                        Container(
                          height: 80,
                          child: Center(
                            child: TextButton(
                                onPressed: () {
                                  payAmount.text = _order.total.toString();
                                  setState(() {
                                    userPayAmount = _order.total;
                                  });
                                },
                                child: const Text("ALL")),
                          ),
                        )
                      ],
                    ),
                    InputField(context,
                        label: "Change Amount",
                        placeholder: "amount",
                        inputType: TextInputType.number,
                        enabled: false,
                        controller: TextEditingController(
                            text: (_order.change! < 0
                                    ? _order.change
                                    : userPayAmount - (_order.total))
                                .toString())),
                    Container(
                      margin: const EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          _order.payAmount = userPayAmount;
                          _order.change = userPayAmount - _order.total;
                          _order.status =
                              _order.change! >= 0 ? "Completed" : "Left";
                          int id = await _orderController.updateOrder(
                              _order.id ?? 0, _order);

                          Get.snackbar("Success", "payment success");
                          Get.back();
                          _productController.getProduct();
                          // Get.to(wOrder.Order());
                          var back =
                              await Get.to(const Receipt(), arguments: _order);
                          print('back1 $back');

                          // setState(() {
                          //   _order.status =
                          //       _order.change! >= 0 ? "Completed" : "Left";
                          //   _order = _order;
                          // });
                          // getProduct();
                        },
                        child: const Text("OK"),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        });
  }
}
