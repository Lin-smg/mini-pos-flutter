import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget InputField(BuildContext context,
    {String? label,
    String? placeholder,
    TextEditingController? controller,
    bool enabled = true,
    Icon? leftIcon,
    TextInputType? inputType,
    Widget? widget,
    FocusNode? focusNode,
    bool autoFocus = false, bool? validate=true, String? errorText,}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    width: MediaQuery.of(context).size.width,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            label.toString(),
            style: const TextStyle(
              // color: Color(0xff51515b),
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.lightBlue,
              width: 2,
            ),
            color: Get.isDarkMode ? Colors.grey : Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 10),
                  child: widget ??
                      TextField(
                        style: const TextStyle(height: 1),
                        keyboardType: inputType,
                        enabled: enabled,
                        controller: controller,
                        focusNode: focusNode,
                        autofocus: autoFocus,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: placeholder.toString(),
                        ),
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: leftIcon,
              ),
            ],
          ),
        ),
        validate!? Container(): Text(errorText.toString(), style: const TextStyle(color: Colors.red),)
      ],
    ),
  );
}
