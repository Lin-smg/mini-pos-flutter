import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos/controllers/cart.controller.dart';
import 'package:flutter_pos/controllers/category.controller.dart';
import 'package:flutter_pos/controllers/product.controller.dart';
import 'package:flutter_pos/controllers/shop.controller.dart';
import 'package:flutter_pos/models/category.dart';
import 'package:flutter_pos/screens/pos/cart.dart';
import 'package:flutter_pos/screens/product/add_product.dart';
import 'package:flutter_pos/screens/qr_scanner.dart';
import 'package:get/get.dart';

class POS extends StatefulWidget {
  const POS({Key? key}) : super(key: key);

  @override
  State<POS> createState() => _POSState();
}

class _POSState extends State<POS> {
  TextEditingController searchKey = TextEditingController();
  String qrKey = "";

  final CategoryController _categoryController = Get.put(CategoryController());
  final ProductController _productController = Get.put(ProductController());
  final CartController _cartController = Get.put(CartController());

  var _selectedCategory;
  late final List<Category> _categoryList = [];
  late List<Category> _categoryFilter;
  String currencySymbol = Get.find<ShopController>().shopInfo.currencySymbol;

  getCategory() async {
    // await _categoryController.getCategory();
    // await Future<void>.delayed(Duration(seconds: 1));
    _selectedCategory = null;
    // _categoryList = _categoryController.categoryList;
    // _categoryFilter = _categoryList;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCategory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          "POS",
        ),
        actions: [
          Obx(
            () => _cartController.cartList.isEmpty
                ? const Icon(Icons.shopping_cart)
                : InkWell(
                    onTap: () {
                      Get.to(const Cart());
                    },
                    child: Badge(
                      position: const BadgePosition(top: 5, end: -5),
                      badgeColor: Colors.red,
                      badgeContent: Text(
                        _cartController.cartList.length.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      child: const Icon(Icons.shopping_cart),
                    ),
                  ),
          ),
          const SizedBox(
            width: 10,
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search...',
                      ),
                      onChanged: (value) {
                        _productController.getProduct(
                            search: value,
                            category: _selectedCategory == null
                                ? ""
                                : _selectedCategory.name);
                      },
                    ),
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
                IconButton(
                    onPressed: () async {
                      String result = await Get.to(const QRScanner());

                      searchKey.text = result;

                      _productController.getProduct(
                          search: searchKey.text,
                          category: _selectedCategory == null
                              ? ""
                              : _selectedCategory.name);
                    },
                    icon: const Icon(Icons.qr_code)),
                IconButton(
                  onPressed: () {
                    searchKey.text = "";
                    _productController.getProduct();
                    setState(() {
                      _selectedCategory = null;
                    });
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10),
            child: const Text("Category"),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            width: MediaQuery.of(context).size.width,
            height: 80,
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categoryController.categoryList.length,
                        itemBuilder: (context, i) {
                          var cat = _categoryController.categoryList.reversed
                              .toList()[i];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCategory = cat;
                              });
                              _productController.getProduct(
                                  category: cat.name, search: searchKey.text);
                            },
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              height: MediaQuery.of(context).size.height,
                              decoration: BoxDecoration(
                                color: _selectedCategory != null &&
                                        _selectedCategory.id == cat.id
                                    ? Colors.lightBlueAccent
                                    : Colors.white,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/menu/category.png",
                                    width: 35,
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(cat.name.toString())
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: const Text("Products"),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              margin: const EdgeInsets.only(bottom: 10),
              child: Obx(() {
                if (_productController.productList.isEmpty) {
                  return const Center(
                    child: Text("No Product"),
                  );
                }
                return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          _getScreenSize(context).width > 600 ? 3 : 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      mainAxisExtent: 280,
                    ),
                    itemCount: _productController.productList.length,
                    itemBuilder: (context, i) {
                      var _product = _productController.productList[i];
                      return GestureDetector(
                        onTap: () {
                          Get.to(const AddProduct(), arguments: _product);
                        },
                        child: Container(
                          // height: 400,
                          padding: const EdgeInsets.only(top: 10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _product.image == null
                                  ? Image.asset(
                                      "assets/menu/productImg.png",
                                      height: 130,
                                    )
                                  : Image.memory(
                                      _product.image!,
                                      height: 130,
                                    ),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Column(
                                  children: [
                                    Container(
                                      child: Text(
                                        _product.name.toString(),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                        '${_product.weight} ${_product.weightUnit}'),
                                    Text(
                                        "$currencySymbol ${_product.sellPrice.toString()}"),
                                    Text('Stock : ${_product.qty}',
                                        style: _product.qty <= 0
                                            ? const TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold)
                                            : const TextStyle(
                                                color: Colors.black,
                                              )),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    _cartController.addToCart(_product);
                                  },
                                  child: const Text(
                                    "Add To Cart",
                                    style: TextStyle(color: Colors.white),
                                  ))
                            ],
                          ),
                        ),
                      );
                    });
              }),
            ),
          ),
        ],
      ),
    );
  }

  Size _getScreenSize(context) {
    return MediaQuery.of(context).size;
  }
}
