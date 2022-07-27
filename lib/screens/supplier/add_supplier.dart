import 'package:flutter/material.dart';
import 'package:flutter_pos/components/inputfield.dart';
import 'package:flutter_pos/controllers/supplier.controller.dart';
import 'package:flutter_pos/models/supplier.dart';
import 'package:get/get.dart';

class AddSupplier extends StatefulWidget {
  const AddSupplier({Key? key}) : super(key: key);

  @override
  State<AddSupplier> createState() => _AddSupplierState();
}

class _AddSupplierState extends State<AddSupplier> {
  int state = 0;
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address = TextEditingController();

  final SupplierController _controller = Get.put(SupplierController());
  late FocusNode myFocusNode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Get.arguments != null) {
      setState(() {
        state = 1;
      });
      Supplier supplier = Get.arguments;
      name.text = supplier.name;
      phone.text = supplier.phone.toString();
      email.text = supplier.email.toString();
      address.text = supplier.address.toString();
    } else {
      setState(() {
        state = 0;
      });
    }
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Add Supplier"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InputField(context,
                label: "Name",
                placeholder: "Supplier Name",
                controller: name,
                inputType: TextInputType.name,
                focusNode: myFocusNode,
                enabled: state!=1),
            InputField(context,
                label: "Phone",
                placeholder: "Phone Number",
                controller: phone,
                inputType: TextInputType.phone,
                enabled: state!=1),
            InputField(context,
                label: "Email",
                placeholder: "Email",
                controller: email,
                inputType: TextInputType.emailAddress,
                enabled: state!=1),
            InputField(
              context,
              label: "Address",
              placeholder: "Address",
              widget: TextField(
                controller: address,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(hintText: "Address.."),
                // minLines: 1,
                maxLines: 5,
                enabled: state!=1,
                autofocus: state!=1,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: MediaQuery.of(context).size.width,
              height: 40,
              child: state == 0
                  ? ElevatedButton(
                      onPressed: () async {
                        Supplier supplier = Supplier(
                            name: name.text,
                            phone: phone.text,
                            email: email.text,
                            address: address.text);

                        _controller.addSupplier(supplier);
                        Get.back();
                        Get.snackbar("Success", "supplier add success");
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.lightBlue,
                      ),
                      child: const Text("Add Supplier"),
                    )
                  : state == 1
                      ? ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              state=2;
                            });
                            
                            // myFocusNode.requestFocus();
                            await Future<void>.delayed(Duration(milliseconds: 1));
                            myFocusNode.requestFocus();
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.lightBlue,
                          ),
                          child: const Text("Edit"),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            Supplier supplier = Supplier(id: Get.arguments.id, name: name.text,phone: phone.text,email: email.text,address: address.text);
                            _controller.updateSupplier(supplier.id??0, supplier);
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.lightBlue,
                          ),
                          child: const Text("Update")),
            )
          ],
        ),
      ),
    );
  }
}
