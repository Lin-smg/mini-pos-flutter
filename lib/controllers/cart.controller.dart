import 'dart:convert';

import 'package:flutter_pos/controllers/product.controller.dart';
import 'package:flutter_pos/models/product.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CartController extends GetxController {
  final box = GetStorage();
  final ProductController _productController = Get.find<ProductController>();
  RxList<Product> cartList = <Product>[].obs;

  double get subTotal {
    double sum = 0;
    for (var element in cartList) {
      sum += element.qty * element.sellPrice;
    }
    return sum;
  }

  double get total => subTotal;

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
    // cartList.clear();
    _productController.getProduct();
    // cartList.assignAll(Get.find<ProductController>().productList.where((e) {
    //   // jsonDecode(box.read("cart"))
    //   int index = jsonDecode(box.read("cart")).indexWhere((element) => element['id']==e.id);
    //   print('inininini>>> $index');
    //   return index != -1;
    // }).toList());
    
    cartList.assignAll(Get.find<ProductController>().productList);
  }

  saveToStorage() async {
    // List list = [];
    // list.addAll(cartList
    //     .map((element) => {"id": element.id, "qty": element.qty})
    //     .toList());

    // print("share ${jsonEncode(list).runtimeType}");
    box.write("cart", jsonEncode(cartList));
    
    
  }

  addToCart(Product product) {
    if(product.qty < 1) {
      Get.snackbar("No Stock", "There is no more stock");
      return;
    }
    
    int index = cartList.indexWhere((element) => element.id == product.id);
    if (index == -1) {
      product.qty= 1;
      cartList.add(product);
    } else {
      cartList[index].qty += 1;
    }

    
    saveToStorage();
  }


  removeFromCart(int id) {
    cartList.removeWhere((element) => element.id == id);
    saveToStorage();
  }

  clearCart() {
    cartList.clear();
    box.remove("cart");
  }

  updateQty(Product product, {required bool increase}) {
    int index = cartList.indexWhere((element) => element.id == product.id);
    if (!increase && cartList[index].qty == 1) {
      return;
    }
    cartList[index].qty += increase ? 1 : -1;

    cartList.refresh();

    saveToStorage();
  }
}
