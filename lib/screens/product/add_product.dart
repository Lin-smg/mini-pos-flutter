import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pos/components/inputfield.dart';
import 'package:flutter_pos/controllers/category.controller.dart';
import 'package:flutter_pos/controllers/product.controller.dart';
import 'package:flutter_pos/controllers/supplier.controller.dart';
import 'package:flutter_pos/models/category.dart';
import 'package:flutter_pos/models/product.dart';
import 'package:flutter_pos/models/supplier.dart';
import 'package:flutter_pos/screens/qr_scanner.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final CategoryController _categoryController = Get.put(CategoryController());
  final SupplierController _supplierController = Get.put(SupplierController());
  final ProductController _productController = Get.put(ProductController());

  TextEditingController searchKey = TextEditingController();
  TextEditingController category = TextEditingController();
  TextEditingController productCode = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController qty = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController sellPrice = TextEditingController();
  TextEditingController buyPrice = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController weightUnit = TextEditingController();
  TextEditingController supplier = TextEditingController();
  var _image;

  late Category _selectedCategory;
  var _selectedSupplier;

  late List<Category> _categoryList;
  late List<Category> _categoryFilter;
  List<Map<String, dynamic>> filterList = [];

  late List<Supplier> _supplierList;
  late List<Supplier> _supplierFilter;

  int state = 0;
  late FocusNode myFocusNode;

  getSupplier() async {
    await _supplierController.getSupplier();
    _supplierList = _supplierController.supplierList;
    _supplierFilter = _supplierList;
  }

  getCategory() async {
    // await _categoryController.getCategory();
    // await Future<void>.delayed(Duration(seconds: 1));
    _categoryList = _categoryController.categoryList;
    _categoryFilter = _categoryList;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myFocusNode = FocusNode();
    _categoryList = [];
    getCategory();
    getSupplier();
    _selectedSupplier = null;

    if (Get.arguments != null) {
      Product product = Get.arguments;
      name.text = product.name.toString();
      productCode.text = product.code.toString();
      category.text = product.category.name;
      qty.text = product.qty.toString();
      description.text = product.description.toString();
      buyPrice.text = product.buyPrice.toString();
      sellPrice.text = product.sellPrice.toString();
      weight.text = product.weight.toString();
      weightUnit.text = product.weightUnit.toString();
      supplier.text =
          product.supplier == null ? "" : product.supplier!.name.toString();

      _selectedCategory = product.category;
      _selectedSupplier = product.supplier;
      _image = product.image;

      setState(() {
        state = 1;
      });
    } else {
      setState(() {
        state = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(state == 0
            ? "Add Product"
            : state == 1
                ? "Product Info"
                : "Update Product"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputField(context,
                label: "Product Name",
                placeholder: "Product Name",
                controller: name,
                enabled: state != 1,
                focusNode: myFocusNode),
            InputField(
              context,
              label: "Product Code",
              widget: Row(
                mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: productCode,
                      enabled: state != 1,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Product Code',
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (state == 1) {
                        null;
                      } else {
                        String result = await Get.to(const QRScanner());
                        productCode.text = result;
                      }
                    },
                    child: const Icon(Icons.qr_code),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                state == 1 ? null : _showCategoryDialog(context);
              },
              child: InputField(
                context,
                label: "Category",
                placeholder: "Choose Category",
                enabled: false,
                controller: category,
              ),
            ),
            InputField(context,
                label: "Product Qty",
                placeholder: "qty",
                inputType: TextInputType.number,
                controller: qty,
                enabled: state != 1),
            InputField(
              context,
              label: "Product Description",
              placeholder: "Description",
              widget: TextField(
                  controller: description,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(hintText: "Description.."),
                  maxLines: 5,
                  enabled: state != 1),
            ),
            InputField(context,
                label: "Buy Price",
                placeholder: "Buy Price",
                inputType: TextInputType.number,
                controller: buyPrice,
                enabled: state != 1),
            InputField(context,
                label: "Sell Price",
                placeholder: "Sell Price",
                inputType: TextInputType.number,
                controller: sellPrice,
                enabled: state != 1),
            InputField(context,
                label: "Product Weight",
                placeholder: "Weight",
                inputType: TextInputType.number,
                controller: weight,
                enabled: state != 1),
            InkWell(
              onTap: () {
                state == 1 ? null : _showWeightUnitDialog(context);
              },
              child: InputField(context,
                  label: "Weight Unit",
                  placeholder: "Choose Unit",
                  enabled: false,
                  controller: weightUnit),
            ),
            InkWell(
              onTap: () {
                state == 1 ? null : _showSupplierDialog(context);
              },
              child: InputField(context,
                  label: "Supplier",
                  placeholder: "Choose Supplier",
                  enabled: false,
                  controller: supplier),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.lightBlueAccent),
                        onPressed: () {
                          state == 1
                              ? null
                              : _getImgFromGallery(ImageSource.gallery);
                        },
                        child: const Text("Pick Image"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.lightBlueAccent),
                        onPressed: () {
                          state == 1
                              ? null
                              : _getImgFromGallery(ImageSource.camera);
                        },
                        child: const Text("Capture Image"),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  _image != null
                      ? Image.memory(
                          _image,
                          height: 200,
                          width: 200,
                        )
                      : Image.asset("assets/menu/productImg.png")
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: MediaQuery.of(context).size.width,
              child: state == 0
                  ? ElevatedButton(
                      onPressed: () {
                        Product product = Product(
                            name: name.text,
                            code: productCode.text,
                            image: _image,
                            qty: int.parse(qty.text),
                            buyPrice: double.parse(buyPrice.text.toString()),
                            sellPrice: double.parse(sellPrice.text.toString()),
                            category: _selectedCategory,
                            supplier: _selectedSupplier,
                            weight: weight.text,
                            weightUnit: weightUnit.text,
                            description: description.text);

                        _productController.insert(product);

                        _productController.getProduct();

                        Get.back();
                        Get.snackbar("Success", "product add success");

                      },
                      child: const Text("Save"),
                    )
                  : state == 1
                      ? ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              state = 2;
                            });
                            await Future<void>.delayed(
                                const Duration(milliseconds: 1));
                            myFocusNode.requestFocus();
                          },
                          child: const Text("Edit"),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            Product product = Product(
                                id: Get.arguments.id,
                                name: name.text,
                                code: productCode.text,
                                image: _image,
                                qty: int.parse(qty.text),
                                buyPrice:
                                    double.parse(buyPrice.text.toString()),
                                sellPrice:
                                    double.parse(sellPrice.text.toString()),
                                category: _selectedCategory,
                                supplier: _selectedSupplier,
                                weight: weight.text,
                                weightUnit: weightUnit.text,
                                description: description.text);

                            _productController.updateProduct(
                                product.id ?? 0, product);

                            _productController.getProduct();

                            Get.back();
                            Get.snackbar("Success", "product update success");
                          },
                          child: const Text("Update"),
                        ),
            )
          ],
        ),
      ),
    );
  }

  _getImgFromGallery(ImageSource gallery) async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? image =
        await _picker.pickImage(source: gallery, imageQuality: 50);

    // ImagePicker().pickImage(source: gallery).then((img){
    //   print("image >>>> ${base64Encode(File(img!.path).readAsBytesSync())}");
    // });

    setState(() {
      // _image = File(image!.path);
      _image = File(image!.path).readAsBytesSync();
    });
  }

  _showCategoryDialog(BuildContext context) {
    // _categoryFilter.addAll(_categoryList);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            _filter() {
              setState(() {
                _categoryFilter = _categoryList
                    .where((element) => element.name
                        .toString()
                        .toLowerCase()
                        .contains(searchKey.text.toLowerCase()))
                    .toList();
              });
            }

            return AlertDialog(
              title: const Text("Category List"),
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
                      child: ListView.separated(
                        itemBuilder: (context, i) {
                          var _cat = _categoryFilter[i];
                          return ListTile(
                            title: Text(_cat.name),
                            trailing: _cat.name == category.text
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.lightBlue,
                                  )
                                : const Text(""),
                            onTap: () {
                              setState(() {
                                _selectedCategory = _cat;
                              });
                              category.text = _selectedCategory.name;
                              Navigator.of(context).pop();
                            },
                          );
                        },
                        separatorBuilder: (context, i) {
                          return const Divider();
                        },
                        itemCount: _categoryFilter.length,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text("Close"),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

  _showWeightUnitDialog(BuildContext context) {
    List<Map<String, dynamic>> _weightUnitList = [
      {"id": 1, "title": "kg"},
      {"id": 2, "title": "g"},
      {"id": 3, "title": "L"},
      {"id": 4, "title": "Pics"},
      {"id": 5, "title": "dag"},
      {"id": 6, "title": "mm"},
      {"id": 7, "title": "cm"},
      {"id": 8, "title": "dm"},
      {"id": 9, "title": "m"},
      {"id": 10, "title": "ft"},
      {"id": 11, "title": "in"},
      {"id": 12, "title": "mm2"},
      {"id": 13, "title": "cm2"},
      {"id": 14, "title": "dm2"},
      {"id": 15, "title": "m2"},
      {"id": 16, "title": "in2"},
      {"id": 17, "title": "cm3"},
      {"id": 18, "title": "m3"},
      {"id": 19, "title": "ft3"},
      {"id": 20, "title": "in3"},
      {"id": 21, "title": "oz"},
      {"id": 22, "title": "gal"},
      {"id": 23, "title": "T"},
      {"id": 24, "title": "lb"},
      {"id": 25, "title": "ml"},
      {"id": 26, "title": "other"},
    ];
    // List.generate(20, (index) => {"id": index, "title": "weight $index"});
    List<Map<String, dynamic>> filterList = [];
    filterList.addAll(_weightUnitList);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _filter() {
              setState(() {
                filterList = _weightUnitList
                    .where((element) => element["title"]
                        .toString()
                        .toLowerCase()
                        .contains(searchKey.text.toLowerCase()))
                    .toList();
              });
            }

            return AlertDialog(
              title: const Text("Weight Unit List"),
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
                          tiles: filterList.map(
                            (e) => ListTile(
                              title: Text(e["title"]),
                              trailing: e["title"] == weightUnit.text
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.lightBlue,
                                    )
                                  : const Text(""),
                              onTap: () {
                                weightUnit.text = e["title"];
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
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

  _showSupplierDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            _filter() {
              setState(() {
                _supplierFilter = _supplierList
                    .where((element) => element.name
                        .toString()
                        .toLowerCase()
                        .contains(searchKey.text.toLowerCase()))
                    .toList();
              });
            }

            return AlertDialog(
              title: const Text("Supplier List"),
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
                          tiles: _supplierFilter.map(
                            (e) => ListTile(
                              title: Text(e.name),
                              subtitle: Text(e.address.toString()),
                              trailing: e.name == supplier.text
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.lightBlue,
                                    )
                                  : const Text(""),
                              onTap: () {
                                setState(() {
                                  _selectedSupplier = e;
                                });
                                supplier.text = e.name;
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ).toList(),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
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
