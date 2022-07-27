import 'package:flutter/material.dart';
import 'package:flutter_pos/components/inputfield.dart';
import 'package:flutter_pos/controllers/expense.controller.dart';
import 'package:flutter_pos/models/expense.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({Key? key}) : super(key: key);

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  TextEditingController name = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController note = TextEditingController();

  ExpenseController _controller = Get.put(ExpenseController());
  int state = 0;
  late FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
    if (Get.arguments != null) {
      setState(() {
        state = 1;
      });
      Expense expense = Get.arguments;
      name.text = expense.name;
      amount.text = expense.amount.toString();
      note.text = expense.note.toString();
      _selectedDate = DateFormat("MM/dd/yyy").parse(expense.date);
      _selectedTime =
          TimeOfDay.fromDateTime(DateFormat.jm().parse(expense.time));
    } else {
      setState(() {
        state = 0;
      });
    }
  }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   myFocusNode.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(state==0?"Add Expense": state==1?"Expense":"Edit Expense"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputField(context,
                label: "Expense Name",
                placeholder: "Name",
                controller: name,
                inputType: TextInputType.name,
                enabled: state != 1,
                focusNode: myFocusNode,
                validate: name.text.isNotEmpty,
                errorText: "required"
                ),
            InputField(context,
                label: "Amount",
                placeholder: "Amount",
                inputType: TextInputType.number,
                controller: amount,
                enabled: state != 1),
            InkWell(
              onTap: () {
                state == 1 ? null : _showDatePicker(context);
              },
              child: InputField(
                context,
                enabled: false,
                label: "Date",
                placeholder: "xxxx-xx-xx",
                leftIcon: const Icon(Icons.calendar_today_outlined),
                controller: TextEditingController(
                  text: DateFormat.yMd().format(_selectedDate),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                state == 1 ? null : _showTimePicker(context);
              },
              child: InputField(
                context,
                enabled: false,
                label: "Time",
                placeholder: "xx:xx",
                leftIcon: const Icon(Icons.watch_later_outlined),
                controller: TextEditingController(
                  text: _selectedTime.format(
                      context), //"${_selectedTime.hour}:${_selectedTime.minute}",
                ),
              ),
            ),
            InputField(
              context,
              label: "Note",
              placeholder: "Note",
              widget: TextField(
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(hintText: "Note.."),
                  // minLines: 1,
                  maxLines: 5,
                  controller: note,
                  enabled: state != 1),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: MediaQuery.of(context).size.width,
              height: 40,
              child: state == 0
                  ? ElevatedButton(
                      onPressed: () async {
                        if(name.text.isEmpty) {
                          return;
                        }
                        Expense expense = Expense(
                            name: name.text,
                            amount: double.parse(amount.text),
                            date: DateFormat.yMd().format(_selectedDate),
                            time: _selectedTime.format(context),
                            note: note.text);

                        await _controller.insert(expense);

                        _controller.getExpense();
                        Get.back();
                        Get.snackbar("Success", "expense add success");
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.lightBlue,
                      ),
                      child: const Text("Add Expense"),
                    )
                  : state == 1
                      ? ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              state = 2;
                            });
                            await Future<void>.delayed(
                                const Duration(milliseconds: 1));
                            myFocusNode.requestFocus();
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.lightBlue,
                          ),
                          child: const Text("Edit"),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            if(name.text.isEmpty) {
                              return;
                            }
                            Expense expense = Expense(
                                id: Get.arguments.id,
                                name: name.text,
                                amount: double.parse(amount.text),
                                date: DateFormat.yMd().format(_selectedDate),
                                time: _selectedTime.format(context),
                                note: note.text);

                            _controller.updateExpense(
                                expense.id ?? 0, expense);

                            _controller.getExpense();
                            Get.back();
                            Get.snackbar("Success", "expense update success");
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.lightBlue,
                          ),
                          child: const Text("Update Expense")),
            )
          ],
        ),
      ),
    );
  }

  _showDatePicker(BuildContext context) {
    showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now())
        .then((value) {
      if (value == null) {
        return;
      }

      setState(() {
        _selectedDate = value;
      });
    });
  }

  _showTimePicker(BuildContext context) {
    showTimePicker(context: context, initialTime: _selectedTime).then((value) {
      if (value == null) {
        return;
      }
      setState(() {
        _selectedTime = value;
      });
    });
  }
}
