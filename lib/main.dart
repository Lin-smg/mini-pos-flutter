import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_pos/controllers/shop.controller.dart';
import 'package:flutter_pos/db/db_helper.dart';
import 'package:flutter_pos/models/shop.dart';
import 'package:flutter_pos/screens/home.dart';
import 'package:flutter_pos/screens/setting/shop_info.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDB();
  await GetStorage.init();
  FlutterNativeSplash.removeAfter(initialization);
  runApp(const MyApp());
}

Future initialization(BuildContext? context) async {
  await Future.delayed(const Duration(seconds: 1));
}

class MyApp extends StatefulWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ShopController _shopController = Get.put(ShopController());
  late Shop _shopInfo;

  bool isNew = true;

  queryShopInfo() async {
    final data = await _shopController.getShop();
    
    if (data != null) {
      _shopInfo = data;
      setState(() {
        isNew=false;
      });
    } else {
      setState(() {
        isNew=true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    queryShopInfo();
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
       
      ),
      home: isNew ? const ShopInfo(): Home(shopInfo: _shopInfo),
    );
  }
}
