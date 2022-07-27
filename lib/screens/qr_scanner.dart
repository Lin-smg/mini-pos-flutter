import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({Key? key}) : super(key: key);

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: buildQrView(context),
          ),
          Expanded(
            
            flex: 1,
            child: (result != null)
                ? Container(
                  color: Colors.black,
                  child: Column(
                      children: [
                        Text(result!.code.toString()),
                        ElevatedButton(
                            onPressed: () {
                              Get.back(result: result!.code.toString());
                            },
                            child: const Text("OK"))
                      ],
                    ),
                )
                : Container(color: Colors.black,
                child: Column(
                  children: [
                    const Center(child: Text("Scanning...", style: TextStyle(color: Colors.white,),),),
                    ElevatedButton(onPressed: () {
                      Get.back(result: "");
                    }, child: const Text("back"))
                  ],
                ),),
          )
        ],
      ),
    );
  }

  Widget buildQrView(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderRadius: 10,
          borderLength: 20,
          borderWidth: 10,
          cutOutSize: MediaQuery.of(context).size.width* 0.8
        ),
      );

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      
      this.controller?.pauseCamera();
      Get.back(result: result!.code.toString());
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
