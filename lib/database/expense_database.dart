import 'package:flutter/cupertino.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseDatabase extends ChangeNotifier{
  static late Isar isar;
  List<Expense> _allExpenses = [];

  /* SETUP */
  // initialize db
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }
  /* GETTERS */
  List<Expense> get allExpense => _allExpenses;

  /* OPERATIONS */
  // create - add a new exp
  Future<void> createNewExpense(Expense newExpense) async{
    await isar.writeTxn(() => isar.expenses.put(newExpense));
  }
  // Read - exp from db
  Future<void> readExpense() async{
    List<Expense> fetchedExpense = await isar.expenses.where().findAll();
    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpense);
    notifyListeners();
  }
  // update - edit an exp in db
  Future<void> updateExpense(int id, Expense updatedExpense) async{
    updatedExpense.id = id;
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));
    await readExpense();
  }
  // delete - del an exp
  Future<void> deleteExpense(int id) async{
    await isar.writeTxn(() => isar.expenses.delete(id));
  }
/* HELPERS */

  // calculate total expenses for each month
  Future<Map<String, double>> calculateMonthlyTotals() async{
    // ensure the exp are read
    await readExpense();
    // create a map to keep track of total expenses
    Map<String, double> monthlyTotals={};
    // iterate over all expenses
    for (var expense in _allExpenses){

      String yearMonth = "${expense.date.year}-${expense.date.month}";
      if (!monthlyTotals.containsKey(yearMonth)){
        monthlyTotals[yearMonth] = 0;
      }
      monthlyTotals[yearMonth] = monthlyTotals[yearMonth]! + expense.amount;
    }
    return monthlyTotals;
  }

  // calculate current month total
  Future<double> calculateCurrentMonthTotal() async{
    await readExpense();
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;
    List<Expense> currentMonthExpenses = _allExpenses.where((expense) {
      return expense.date.year == currentYear;
    }).toList();
    
    double total = currentMonthExpenses.fold(0, (sum, expense) => sum + expense.amount);
    return total;
  }

  // get start month
  int getStarMonth() {
    if(_allExpenses.isEmpty){
      return DateTime.now().month;
    }
    _allExpenses.sort(
        (a, b) => a.date.compareTo(b.date)
    );

    return _allExpenses.first.date.month;
  }
  // get start year
  int getStarYear() {
    if(_allExpenses.isEmpty){
      return DateTime.now().year;
    }
    _allExpenses.sort(
            (a, b) => a.date.compareTo(b.date)
    );

    return _allExpenses.first.date.year;
  }
}