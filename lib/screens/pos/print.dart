import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_pos/screens/pos/pdfpreview.dart';
import 'dart:ui' as ui;

import 'package:get/get.dart';

class PrintImg extends StatefulWidget {
  const PrintImg({Key? key}) : super(key: key);

  @override
  State<PrintImg> createState() => _PrintImgState();
}

class _PrintImgState extends State<PrintImg> {
  GlobalKey _globalKey = GlobalKey();

  var img;

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
        img = pngBytes;
      });
      Get.to(PDFPreview(),arguments: img);
      return pngBytes;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Widget To Image demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RepaintBoundary(
              key: _globalKey,
              child: const Text(
                'မင်္၈လာပါ',
              ),
            ),
            RaisedButton(
              child: const Text('capture Image'),
              onPressed: _capturePng,
            ),
            img != null ? Image.memory(img) : const Text("null data"),

            RaisedButton(onPressed: () {
              Get.to(PDFPreview(),arguments: img);
            
            },
            child: const Text("KKK"),)
          ],
        ),
      ),
    );
  }
}
