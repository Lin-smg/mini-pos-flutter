import 'package:flutter/material.dart';
import 'package:flutter_pos/controllers/cart.controller.dart';
import 'package:flutter_pos/controllers/customer.controller.dart';
import 'package:flutter_pos/controllers/order.controller.dart';
import 'package:flutter_pos/controllers/payment.controller.dart';
import 'package:flutter_pos/controllers/product.controller.dart';
import 'package:flutter_pos/controllers/shop.controller.dart';
import 'package:flutter_pos/models/customer.dart';
import 'package:flutter_pos/models/order.dart';
import 'package:flutter_pos/models/payment.dart';
import 'package:flutter_pos/models/shop.dart';
import 'package:flutter_pos/screens/order/order.dart' as wOrder;
import 'package:flutter_pos/screens/order/orderDetail.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  TextEditingController searchKey = TextEditingController();
  final CartController _controller = Get.find<CartController>();
  final PaymentController _paymentController = Get.put(PaymentController());
  String currencySymbol = "\$";
  late double tax;

  final CustomerController _customerController = Get.put(CustomerController());

  final OrderController _orderController = Get.put(OrderController());
  final ProductController _productController = Get.put(ProductController());

  late List<Customer> _customerList;
  late List<Customer> _customerFilter;

  var _selectedCustomer = null;

  late final List<String> _orderTypeList = ["PICKUP", "HOME DELIVERY"];
  late List<String> _orderTypeFilter;

  var _selectedOrderType = null;

  late List<Payment> _payTypeList;
  late List<Payment> _payTypeFilter;

  var _selectedPayType;

  TextEditingController discount = TextEditingController();

  getCustomer() async {
    await _customerController.getCustomer();
    _customerList = _customerController.customerList.reversed.toList();
    // _customerList.insert(
    //     0,
    //     Customer(
    //       name: "Walk In Customer",
    //     ));
    _customerFilter = _customerList;
    _selectedCustomer = _customerList[0];
    print('customer ${_customerList.length}');
  }

  getPayType() async {
    await _paymentController.getPayment();
    _payTypeList = _paymentController.paymentList;
    _payTypeFilter = _payTypeList;
    _selectedPayType = _payTypeList[0];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _orderTypeFilter = [];
    Shop shop = Get.find<ShopController>().shopInfo;

    currencySymbol = shop.currencySymbol;
    tax = shop.tax;

    getCustomer();
    getPayType();
    _selectedOrderType = _orderTypeList[0];
    // discount.selection = TextSelection.fromPosition(TextPosition(offset: discount.text.length));
    discount.text = '0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Product Cart"),
        actions: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _controller.cartList.isNotEmpty
                  ? InkWell(
                      onTap: () {
                        Get.defaultDialog(
                          title: "Clear",
                          content: const Center(
                            child: Text("Are you sure ? "),
                          ),
                          onCancel: () => {},
                          onConfirm: () {
                            _controller.clearCart();
                            Get.back();
                          },
                        );
                      },
                      child: const Text("Clear"),
                    )
                  : Container(),
              const SizedBox(width: 10)
            ],
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (_controller.cartList.isEmpty) {
                return const Center(child: Text("No Product"));
              }
              return ListView.builder(
                  itemCount: _controller.cartList.length,
                  itemBuilder: (context, i) {
                    var _product = _controller.cartList[i];
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
                                  width: 80,
                                )
                              : Image.memory(
                                  _product.image!,
                                  width: 80,
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
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    _controller
                                        .removeFromCart(_product.id ?? 0);
                                  },
                                  child: const Icon(
                                    Icons.delete_forever,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.cyan),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                          onTap: () {
                                            _controller.updateQty(_product,
                                                increase: false);
                                          },
                                          child: const Icon(Icons.remove)),
                                      SizedBox(
                                        width: 20,
                                        child: Center(
                                            child:
                                                Text(_product.qty.toString())),
                                      ),
                                      InkWell(
                                          onTap: () {
                                            _controller.updateQty(_product,
                                                increase: true);
                                          },
                                          child: const Icon(Icons.add))
                                    ],
                                  ),
                                )
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
                    Obx(
                      () => Text("$currencySymbol ${_controller.subTotal}"),
                    ),
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
                    Text("$currencySymbol 0"),
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
                    Text("$currencySymbol 0"),
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
                    Obx(
                      () => Text(
                      "$currencySymbol ${_controller.total}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),),
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () {
                      _showPaymentDialog(context);
                    },
                    child: const Text(
                      "Order",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
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
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Payment", style: TextStyle(fontWeight: FontWeight.bold),),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: const Icon(Icons.close, color: Colors.red,))
                ],
              ),
              content: Container(
                width: MediaQuery.of(context).size.width,
                height: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Divider(),
                      InkWell(
                        onTap: () {
                          Get.back();
                          _showCustomerDialog(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(_selectedCustomer.name),
                              const Icon(Icons.arrow_drop_down)
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                      InkWell(
                        onTap: () {
                          Get.back();
                          _showOrderTypeDialog(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(_selectedOrderType.toString()),
                              const Icon(Icons.arrow_drop_down)
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                      InkWell(
                        onTap: () {
                          Get.back();
                          _showPayTypeDialog(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(_selectedPayType.name.toString()),
                              const Icon(Icons.arrow_drop_down)
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Sub Total "),
                            Text(
                                '$currencySymbol ${_controller.subTotal.toString()}')
                          ],
                        ),
                      ),
                      const Divider(),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Total Tax ($tax%) "),
                            Text(
                                '$currencySymbol ${_controller.subTotal * (tax / 100)}')
                          ],
                        ),
                      ),
                      const Divider(),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Discount "),
                            Expanded(
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    discount.text = value;
                                  });
                                },
                                style: const TextStyle(height: 1),
                                decoration: const InputDecoration(
                                    // hintText: "0"
                                    ),
                                textAlign: TextAlign.end,
                                keyboardType: TextInputType.number,
                              ),
                            )
                          ],
                        ),
                      ),
                      const Divider(),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("Total "),
                              Text(
                                  "$currencySymbol ${_controller.total + (_controller.subTotal * (tax / 100)) - double.parse(discount.text.isEmpty ? '0' : discount.text)}")
                            ]),
                      ),
                      const Divider(),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          onPressed: () async{
                            List<Map<String,dynamic>> productList = _controller.cartList.map((element) => {"id": element.id, "qty": element.qty}).toList();
                            Order order = Order(
                                orderId: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                                date:
                                DateFormat.yMMMEd()
                                    .add_Hm()
                                    .format(DateTime.now())
                                    .toString(),
                                subTotal: _controller.subTotal,
                                total: _controller.total + (_controller.subTotal * (tax / 100)) - double.parse(discount.text.isEmpty ? '0' : discount.text),//_controller.total,
                                totalTax: _controller.subTotal * (tax / 100),
                                totalDiscount: double.parse(
                                    discount.text.isEmpty
                                        ? '0'
                                        : discount.text),
                                orderType: _selectedOrderType,
                                payType: _selectedPayType.name,
                                customer: _selectedCustomer,
                                products: productList,
                                payAmount: 0,
                                change: 0,
                                status: "Pending",
                                orderDate: DateFormat('yyyy-MM-dd').format(DateTime.now()).toString());//DateFormat.yMd().format(DateTime.now()));

                                // print(DateFormat.yMd().format(DateTime.now()));

                            int id  = await _orderController.insert(order);
                            
                            await _productController.updateProductList(productList);
                            // Get.back();
                            // Get.to(const wOrder.Order());
                            Get.to(const OrderDetail(), arguments: order);
                            // Get.back();
                            // Get.back();
                            Get.snackbar("Success", "order create success");
                          },
                          child: const Text('Order'),
                        ),
                      ),

                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.grey
                          ),
                          onPressed: () {
                            Get.back();

                          },
                          child: const Text("Close"),),),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  _showCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _filter() {
              setState(() {
                _customerFilter = _customerList
                    .where((element) => element.name
                        .toString()
                        .toLowerCase()
                        .contains(searchKey.text.toLowerCase()))
                    .toList();
              });
            }

            return AlertDialog(
              title: const Text("Order Type List"),
              content: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 10),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blueAccent, //const Color(0xffd8d8d8),
                          width: 2,
                        ),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 10),
                              child: TextField(
                                controller: searchKey,
                                onChanged: (value) {
                                  _filter();
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search...',
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                _filter();
                              },
                              icon: const Icon(Icons.search)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: ListTile.divideTiles(
                          color: Colors.lightBlue,
                          tiles: _customerFilter.map(
                            (e) => ListTile(
                              title: Text(e.name),
                              trailing: e.name == _selectedCustomer.name
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.lightBlue,
                                    )
                                  : const Text(""),
                              onTap: () {
                                setState(() {
                                  _selectedCustomer = e;
                                });

                                Navigator.of(context).pop();
                                _showPaymentDialog(context);
                              },
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _showPaymentDialog(context);
                      },
                      child: const Text("Close"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  _showOrderTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _filter() {
              setState(() {
                _orderTypeFilter = _orderTypeList
                    .where((element) => element
                        .toString()
                        .toLowerCase()
                        .contains(searchKey.text.toLowerCase()))
                    .toList();
              });
            }

            return AlertDialog(
              title: const Text("Customer List"),
              content: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 10),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blueAccent, //const Color(0xffd8d8d8),
                          width: 2,
                        ),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 10),
                              child: TextField(
                                controller: searchKey,
                                onChanged: (value) {
                                  _filter();
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search...',
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                _filter();
                              },
                              icon: const Icon(Icons.search)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: ListTile.divideTiles(
                          color: Colors.lightBlue,
                          tiles: _orderTypeList.map(
                            (e) => ListTile(
                              title: Text(e),
                              trailing: e == _selectedOrderType
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.lightBlue,
                                    )
                                  : const Text(""),
                              onTap: () {
                                setState(() {
                                  _selectedOrderType = e;
                                });
                                // supplier.text = e.name;
                                Navigator.of(context).pop();
                                _showPaymentDialog(context);
                              },
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _showPaymentDialog(context);
                      },
                      child: const Text("Close"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  _showPayTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _filter() {
              setState(() {
                _payTypeFilter = _payTypeList
                    .where((element) => element.name
                        .toString()
                        .toLowerCase()
                        .contains(searchKey.text.toLowerCase()))
                    .toList();
              });
            }

            return AlertDialog(
              title: const Text("Pay Type List"),
              content: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 10),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blueAccent, //const Color(0xffd8d8d8),
                          width: 2,
                        ),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 10),
                              child: TextField(
                                controller: searchKey,
                                onChanged: (value) {
                                  _filter();
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search...',
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                _filter();
                              },
                              icon: const Icon(Icons.search)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: ListTile.divideTiles(
                          color: Colors.lightBlue,
                          tiles: _payTypeFilter.map(
                            (e) => ListTile(
                              title: Text(e.name),
                              trailing: e.name == _selectedPayType.name
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.lightBlue,
                                    )
                                  : const Text(""),
                              onTap: () {
                                setState(() {
                                  _selectedPayType = e;
                                });
                                // supplier.text = e.name;
                                Navigator.of(context).pop();
                                _showPaymentDialog(context);
                              },
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _showPaymentDialog(context);
                      },
                      child: const Text("Close"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
