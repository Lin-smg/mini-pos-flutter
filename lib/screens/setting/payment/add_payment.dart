import 'package:flutter/material.dart';
import 'package:flutter_pos/components/inputfield.dart';
import 'package:flutter_pos/controllers/payment.controller.dart';
import 'package:flutter_pos/models/payment.dart';
import 'package:get/get.dart';

class AddPayment extends StatefulWidget {
  const AddPayment({ Key? key }) : super(key: key);

  @override
  State<AddPayment> createState() => _AddPaymentState();
}

class _AddPaymentState extends State<AddPayment> {
  PaymentController _controller = Get.find<PaymentController>();

  TextEditingController name = TextEditingController();
  late FocusNode myFocusNode;
  int state = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myFocusNode = FocusNode();

    if(Get.arguments != null) {
      Payment payment = Get.arguments;
      name.text = payment.name.toString();
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
        title: Text(state==0?"Add Pay Method": state==1?"Pay Method Info": "Update Pay Method"),
      ),
      body: Column(
        children: [
          InputField(context,
              label: "Payment Method Name", placeholder: "Name", controller: name, validate: name.text.isNotEmpty, errorText: "Require!", focusNode: myFocusNode),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: MediaQuery.of(context).size.width,
            child: state==0? ElevatedButton(
              onPressed: () async{
                Payment payment = Payment(name: name.text);

                await _controller.insert(payment);
                _controller.getPayment();
                Get.back();
                Get.snackbar("Success", "payment add success");
              },
              child: const Text("Save"),
            ): state==1? ElevatedButton(
              onPressed: () async{
                setState(() {
                  state = 2;
                });
                await Future<void>.delayed(Duration(microseconds: 1));
                myFocusNode.requestFocus();
              },
              child: const Text("Edit"),
            ): ElevatedButton(
              onPressed: () async{
                Payment payment = Payment(name: name.text, id: Get.arguments.id);

                await _controller.updatePayment(payment.id??0, payment);

                _controller.getPayment();
                Get.back();
                Get.snackbar("Success", "payment update success");
              },
              child: const Text("Update"),
            ),
          )
        ],
      ),
    );
  }
}
