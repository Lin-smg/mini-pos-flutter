import 'package:flutter/material.dart';
import 'package:flutter_pos/controllers/payment.controller.dart';
import 'package:flutter_pos/screens/setting/payment/add_payment.dart';
import 'package:get/get.dart';

class PaymentMethod extends StatelessWidget {
  const PaymentMethod({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PaymentController _controller = Get.put(PaymentController());
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("All Payment Method"),
      ),
      body: Column(
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
                    child: const TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search...',
                      ),
                    ),
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.search))
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                  itemCount: _controller.paymentList.length,
                  itemBuilder: (context, i) {
                    var payment = _controller.paymentList[i];
                    return GestureDetector(
                      onTap: () => Get.to(AddPayment(), arguments: payment),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.white,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/util/payment.png",
                              height: 50,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Text(
                              payment.name.toString(),
                              style: const TextStyle(fontSize: 18),
                            )),
                            InkWell(
                              onTap: () async {
                                Get.defaultDialog(
                                  title: "Delete",
                                  content: const Center(
                                    child: Text("Are you sure ? "),
                                  ),
                                  onCancel: () => {},
                                  onConfirm: () {
                                    _controller.delete(payment.id ?? 0);
                                    _controller.getPayment();
                                    Get.back();
                                  },
                                );
                              },
                              child: const Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(AddPayment());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
