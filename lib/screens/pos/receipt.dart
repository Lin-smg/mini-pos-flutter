import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_pos/components/separator.dart';
import 'package:flutter_pos/controllers/product.controller.dart';
import 'package:flutter_pos/controllers/shop.controller.dart';
import 'package:flutter_pos/models/order.dart';
import 'package:flutter_pos/models/product.dart';
import 'package:flutter_pos/models/shop.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:pdf/widgets.dart' as pw;

import 'package:printing/printing.dart';

class Receipt extends StatefulWidget {
  const Receipt({Key? key}) : super(key: key);

  @override
  State<Receipt> createState() => _ReceiptState();
}

class _ReceiptState extends State<Receipt> {
  final Shop _shop = Get.find<ShopController>().shopInfo;
  final ProductController _productController = Get.put(ProductController());
  final GlobalKey _globalKey = GlobalKey();
  var _img;

  Future<Uint8List> _capturePng() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();
      var bs64 = base64Encode(pngBytes);
      setState(() {
        _img = pngBytes;
      });
      // await Future.delayed(Duration(seconds: 2));
      // Get.to(PDFPreview(), arguments: _img);

      return pngBytes;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  late Order _order;
  late List<Product> _productList;

  getProduct() async {
    await _productController.getProduct();
    _productList = _productController.productList;
    // print(_productList
    //     .where((element) =>
    //         _order.products.indexWhere((e) => e["id"] == element.id) != -1)
    //     .map((d) {
    //       d.qty =
    //           _order.products.firstWhere((data) => data["id"] == d.id)["qty"];
    //       return d;
    //     })
    //     .toList()[1]
    //     .qty);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _order = Get.arguments;
    _productList =
        []; //Get.put(ProductController()).productList.where((element) => _order.products.indexWhere((p) => p==element.id)!=1   ).toList();

    getProduct();
  }

  double get subTotal {
    double sum = 0;
    for (var element in _productController.productList
        .where((element) => _order.products.contains(element.id))
        .toList()) {
      sum += element.qty * element.sellPrice;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Receipt"),
        actions: [
          IconButton(
            onPressed: () async {
              var img = await _capturePng();

              Future.delayed(const Duration(seconds: 2));
              final doc = pw.Document();
              doc.addPage(pw.Page(build: (pw.Context context) {
                return pw.Center(child: pw.Image(pw.MemoryImage(img)));
              }));

              await Printing.layoutPdf(onLayout: (format) async => doc.save());
            },
            icon: const Icon(Icons.print),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(10),
          child: RepaintBoundary(
            key: _globalKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),
                Text(
                  _shop.name.toString(),
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(_shop.address.toString()),
                ),
                Text(_shop.phone),
                const SizedBox(
                  height: 18,
                ),
                Text(
                  _order.orderId.toString(),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(DateFormat.yMMMEd().add_Hm().format(DateTime.now())),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    const Expanded(child: Text("Product")),
                    Container(width: 50, child: const Text("Qty")),
                    Container(
                        width: 100,
                        child: const Text(
                          "Price",
                          textAlign: TextAlign.right,
                        ))
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                const Separator(),
                const SizedBox(
                  height: 10,
                ),
                Container(
                    // height: 200,
                    child: Obx(
                  () => Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children:
                        // [
                        _productController.productList
                            .where((element) =>
                                _order.products
                                    .indexWhere((e) => e["id"] == element.id) !=
                                -1)
                            .map((d) {
                              d.qty = _order.products.firstWhere(
                                  (data) => data["id"] == d.id)["qty"];
                              return d;
                            })
                            .toList()
                            .map(
                              (item) => Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: Text(item.name.toString())),
                                  Container(
                                    width: 50,
                                    child: Text(item.qty.toString()),
                                  ),
                                  Container(
                                    width: 100,
                                    child: Text(
                                      item.sellPrice.toString(),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                  ),
                )),
                const SizedBox(
                  height: 10,
                ),
                const Separator(),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("ITEM COUNT:"),
                    Text(_order.products.length.toString())
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text("SUB TOTAL:"), Text(_order.subTotal.toString())],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text("Tax:"), Text(_order.totalTax.toString())],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text("Discount:"), Text(_order.totalDiscount.toString())],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text("TOTAL:"), Text(_order.total.toString())],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text("CASH:"), Text(_order.payAmount.toString())],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text("CHANGE:"), Text(_order.change.toString())],
                ),
                const SizedBox(
                  height: 10,
                ),
                const Separator(),
                const SizedBox(
                  height: 5,
                ),
                const Center(
                  child: Text(
                    "THANK YOU",
                    style: TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                // _img != null
                //     ? Image.memory(
                //         _img,
                //       )
                //     : const Text("null"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _getProductList(List<int> list) {
    return Row(children: list.map((e) => Text(e.toString())).toList());
  }
}
