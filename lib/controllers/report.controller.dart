import 'package:get/get.dart';

class ReportController extends GetxController {
  var startDate = DateTime.now().subtract(Duration(days: 1)).obs;
  var endDate = DateTime.now().obs;


  setDateRange(start, end) {
    startDate.value = start;
    endDate.value = end;
  }
  
}