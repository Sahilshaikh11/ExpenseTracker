import 'package:intl/intl.dart';

// convert str to double
double convertStringToDouble(String string){
  double? amount = double.tryParse(string);
  return amount ?? 0;
}

// format double amount into rupees and paise
String formatAmount(double amount){
  final format = NumberFormat.currency(locale: "en_IN", symbol: "\₹", decimalDigits: 2);
  return format.format(amount);
}

// cal the no of months since the first start month
int calculateMonthCount(int startYear, startMonth, currentYear, currentMonth){
  int monthCount = (currentYear - startYear) * 12 + currentMonth - startMonth+1;
  return monthCount;
}

// Get Current Month Name
String getCurrentMonthName() {
  DateTime now = DateTime.now();
  List<String> months = [
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JUL",
    "AUG",
    "SEP",
    "OCT",
    "NOV",
    "DEC"
  ];
  return months[now.month - 1];
}