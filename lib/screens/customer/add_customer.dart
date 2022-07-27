import 'package:flutter/material.dart';
import 'package:flutter_pos/components/inputfield.dart';
import 'package:flutter_pos/controllers/customer.controller.dart';
import 'package:flutter_pos/models/customer.dart';
import 'package:get/get.dart';

class AddCustomer extends StatefulWidget {
  const AddCustomer({Key? key}) : super(key: key);

  @override
  State<AddCustomer> createState() => _AddCustomerState();
}

class _AddCustomerState extends State<AddCustomer> {
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController address = TextEditingController();

  late FocusNode myFocusNode;

  CustomerController _customerController = Get.put(CustomerController());

  int state = 0;

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();

    print(Get.arguments);
    if (Get.arguments == null) {
      setState(() {
        state = 0;
      });
    } else {
      Customer customer = Get.arguments;
      name.text = customer.name;
      phone.text = customer.phone.toString();
      email.text = customer.email.toString();
      address.text = customer.address.toString();
      setState(() {
        state = 1;
      });
    }
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
        title: const Text("Add Customer"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InputField(context,
                label: "Name",
                placeholder: "Customer Name",
                controller: name,
                inputType: TextInputType.name,
                focusNode: myFocusNode,
                autoFocus: true,
                enabled: state != 1),
            InputField(context,
                label: "Phone",
                placeholder: "Phone Number",
                controller: phone,
                inputType: TextInputType.phone,
                enabled: state != 1),
            InputField(context,
                label: "Email",
                placeholder: "Email",
                controller: email,
                inputType: TextInputType.emailAddress,
                enabled: state != 1),
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
                  enabled: state != 1),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: MediaQuery.of(context).size.width,
              height: 40,
              child: state == 0
                  ? ElevatedButton(
                      onPressed: () async {
                        Customer customer = Customer(
                            name: name.text,
                            phone: phone.text,
                            email: email.text,
                            address: address.text);

                        int id = await _customerController.insert(customer);

                        _customerController.getCustomer();

                        Get.back();
                        Get.snackbar("Success", "customer add success");
                        print(id.toString());
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.lightBlue,
                      ),
                      child: const Text("Add Customer"),
                    )
                  : state == 1
                      ? ElevatedButton(
                          onPressed: () async{
                            setState(() {
                              state = 2;
                            });
                            
                            myFocusNode.requestFocus();
                            await Future<void>.delayed(Duration(milliseconds: 1));
                            FocusScope.of(context).requestFocus(myFocusNode);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.lightBlue,
                          ),
                          child: const Text("Edit"),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            Customer customer = Customer(
                                id: Get.arguments.id,
                                name: name.text,
                                phone: phone.text,
                                email: email.text,
                                address: address.text);

                            _customerController
                                .updateCustomer(Get.arguments.id, customer)
                                .then((value) {
                              Get.back();
                            });
                            Get.back();
                            // print(id.toString());
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.lightBlue,
                          ),
                          child: const Text("Update"),
                        ),
            )
          ],
        ),
      ),
    );
  }
}
