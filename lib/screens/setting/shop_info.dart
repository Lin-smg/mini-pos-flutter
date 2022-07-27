import 'package:flutter/material.dart';
import 'package:flutter_pos/components/inputfield.dart';
import 'package:flutter_pos/controllers/shop.controller.dart';
import 'package:flutter_pos/db/db_helper.dart';
import 'package:flutter_pos/models/shop.dart';
import 'package:flutter_pos/screens/home.dart';
import 'package:get/get.dart';

class ShopInfo extends StatefulWidget {
  const ShopInfo({Key? key}) : super(key: key);

  @override
  State<ShopInfo> createState() => _ShopInfoState();
}

class _ShopInfoState extends State<ShopInfo> {
  ShopController _shopController = Get.put(ShopController());
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController currencySymbol = TextEditingController();
  TextEditingController tax = TextEditingController();
  late Shop _shopInfo;
  bool isNew = true;

  queryShopInfo() async {
    final data = await _shopController.getShop();
    print("q s i ");

    print(data == null);
    if (data != null) {
      setState(() {
        isNew = false;
      });
      _shopInfo = data;
      name.text = _shopInfo.name;
      phone.text = _shopInfo.phone;
      email.text = _shopInfo.email;
      address.text = _shopInfo.address;
      currencySymbol.text = _shopInfo.currencySymbol;
      tax.text = _shopInfo.tax.toString();
    } else {
      setState(() {
        isNew=true;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    queryShopInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text("Shop Information"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InputField(context,
                label: "Shop Name", placeholder: "Shop Name", controller: name),
            InputField(context,
                label: "Shop Contact Number",
                placeholder: "Phone Number",
                inputType: TextInputType.phone,
                controller: phone),
            InputField(context,
                label: "Shop Email",
                placeholder: "Email",
                inputType: TextInputType.emailAddress,
                controller: email),
            InputField(
              context,
              label: "Shop Address",
              placeholder: "address",
              widget: TextField(
                controller: address,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(hintText: "Address.."),
                maxLines: 5,
              ),
            ),
            InputField(context,
                label: "Currency Symbol",
                placeholder: "Symbol (eg: \$)",
                controller: currencySymbol),
            InputField(context,
                label: "Tax (%)",
                placeholder: "Number (eg: 5)",
                inputType: TextInputType.number,
                controller: tax),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: MediaQuery.of(context).size.width,
              child: isNew? ElevatedButton(
                onPressed: () {
                  if(name.text.isEmpty || phone.text.isEmpty || address.text.isEmpty || currencySymbol.text.isEmpty || tax.text.isEmpty) {
                    return;
                  }
                  Shop shop = Shop(
                      name: name.text,
                      phone: phone.text,
                      email: email.text,
                      address: address.text,
                      currencySymbol: currencySymbol.text,
                      tax: double.parse(tax.text));
                  _shopController.insertShop(shop);
                  Get.off(Home(shopInfo: shop,));
                },
                child: const Text("Save"),

              ):  ElevatedButton(
                onPressed: () {
                  if(name.text.isEmpty || phone.text.isEmpty || address.text.isEmpty || currencySymbol.text.isEmpty || tax.text.isEmpty) {
                    return;
                  }
                  Shop shop = Shop(
                      id: _shopInfo.id,
                      name: name.text,
                      phone: phone.text,
                      email: email.text,
                      address: address.text,
                      currencySymbol: currencySymbol.text,
                      tax: double.parse(tax.text));
                      print(_shopInfo.id);
                  _shopController.updateShop(_shopInfo.id??0, shop);
                  // Get.back();
                  // Get.off(Home(shopInfo: shop,));
                  Get.offUntil(GetPageRoute(page: () => Home(shopInfo: shop,)) , (route) => false);
                },
                child: const Text("Edit"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
