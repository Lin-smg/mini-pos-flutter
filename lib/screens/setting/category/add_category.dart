import 'package:flutter/material.dart';
import 'package:flutter_pos/components/inputfield.dart';
import 'package:flutter_pos/controllers/category.controller.dart';
import 'package:flutter_pos/models/category.dart';
import 'package:get/get.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({Key? key}) : super(key: key);

  @override
  State<AddCategory> createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final CategoryController _controller = Get.put(CategoryController());
  TextEditingController name = TextEditingController();
  int state = 0;

  late FocusNode myFocusNode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    myFocusNode = FocusNode();
    if (Get.arguments != null) {
      Category category = Get.arguments;
      name.text = category.name.toString();
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
        title: Text(state == 0
            ? "Add Category"
            : state == 1
                ? "Category Info"
                : "Update Category"),
      ),
      body: Column(
        children: [
          InputField(context,
              label: "Category Name",
              placeholder: "Name",
              controller: name,
              enabled: state != 1,
              focusNode: myFocusNode),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: MediaQuery.of(context).size.width,
            child: state == 0
                ? ElevatedButton(
                    onPressed: () async {
                      Category category = Category(name: name.text);

                      await _controller.insert(category);
                      _controller.getCategory();
                      Get.back();

                      Get.snackbar("Success", "category add success");
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
                              const Duration(microseconds: 1));
                          myFocusNode.requestFocus();
                        },
                        child: const Text("Edit"),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          Category category =
                              Category(id: Get.arguments.id, name: name.text);

                          await _controller.updateCategory(
                              category.id ?? 0, category);
                          _controller.getCategory();
                          Get.back();

                          Get.snackbar("Success", "category update success");
                        },
                        child: const Text("Update"),
                      ),
          )
        ],
      ),
    );
  }
}
