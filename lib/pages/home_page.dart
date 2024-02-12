import 'dart:math';

import 'package:expense/bar_graph/bar_graph.dart';
import 'package:expense/components/my_list_tile.dart';
import 'package:expense/database/expense_database.dart';
import 'package:expense/helper/helper_functions.dart';
import 'package:expense/models/expense.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // text controller
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  // futures to load graph data & monthly data
  Future<Map<String, double>>? _monthlyTotalsFuture;
  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    // read db on initial startup
    Provider.of<ExpenseDatabase>(context, listen: false).readExpense();

    // load futures
    refreshData();
    super.initState();
  }

  // refresh graph data
  void refreshData() {
    _monthlyTotalsFuture = Provider.of<ExpenseDatabase>(context, listen: false)
        .calculateMonthlyTotals();
    _calculateCurrentMonthTotal =
        Provider.of<ExpenseDatabase>(context, listen: false)
            .calculateCurrentMonthTotal();
  }

  // open new expense box
  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("New Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // user i/p --> expense name
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: "Name"),
            ),
            // user i/p --> expense amount
            TextField(
              controller: amountController,
              decoration: InputDecoration(hintText: "Amount"),
            )
          ],
        ),
        actions: [
          // cancel button
          _cancelButton(),
          // save button
          _createNewExpenseButton()
        ],
      ),
    );
  }

  // open edit Box
  void openEditBox(Expense expense) {
    // prefilling existing values into field
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // user i/p --> expense name
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: existingName),
            ),
            // user i/p --> expense amount
            TextField(
              controller: amountController,
              decoration: InputDecoration(hintText: existingAmount),
            )
          ],
        ),
        actions: [
          // cancel button
          _cancelButton(),
          // save button
          _editExpenseButton(expense),
        ],
      ),
    );
  }

  // open delete box
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Expense"),
        actions: [
          // cancel button
          _cancelButton(),
          // delete button
          _deleteExpenseButton(expense.id),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(builder: (context, value, child) {
      // get dates
      int startMonth = value.getStarMonth();
      int startYear = value.getStarYear();
      int currentMonth = DateTime.now().month;
      int currentYear = DateTime.now().year;
      // cal the no. of month since first month
      int monthCount =
          calculateMonthCount(startYear, startMonth, currentYear, currentMonth);

      // only display the expenses for the current month
      List<Expense> currentMonthExpenses = value.allExpense.where((expense) {
        return expense.date.year == currentYear &&
            expense.date.month == currentMonth;
      }).toList();
      // return UI
      return Scaffold(
        backgroundColor: Colors.grey.shade300,
        floatingActionButton: FloatingActionButton(
          onPressed: openNewExpenseBox,
          backgroundColor: Colors.grey.shade300, // Set the background color
          foregroundColor: Colors.black,
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: FutureBuilder<double>(
            future: _calculateCurrentMonthTotal,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\₹' + snapshot.data!.toStringAsFixed(2)),
                    Text(getCurrentMonthName()),
                  ],
                );
              } else {
                return Text("loading..");
              }
            },
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Graph UI
              SizedBox(
                height: 250,
                child: FutureBuilder(
                  future: _monthlyTotalsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      Map<String, double> monthlyTotals = snapshot.data ?? {};
                      List<double> monthlySummary = List.generate(
                        monthCount,
                        (index) {
                          int year = startYear + (startMonth + index - 1) ~/ 12;
                          int month = (startMonth + index - 1) % 12 + 1;

                          String yearMonthKey = '$year-$month';
                          return monthlyTotals[yearMonthKey] ?? 0.0;
                        },
                      );

                      return MyBarGraph(
                          monthlySummary: monthlySummary,
                          startMonth: startMonth);
                    }
                    //loading
                    else {
                      return const Center(
                        child: Text('loading..'),
                      );
                    }
                  },
                ),
              ),
              // Expense list UI
              const SizedBox(height: 25,),
              Expanded(
                child: ListView.builder(
                  itemCount: currentMonthExpenses.length,
                  itemBuilder: (context, index) {
                    int reversedIndex = currentMonthExpenses.length - 1 - index;

                    Expense individualExpense = currentMonthExpenses[index];
                    return MyListTile(
                      title: individualExpense.name,
                      trailing: formatAmount(individualExpense.amount),
                      onEditPressed: (context) =>
                          openEditBox(individualExpense),
                      onDeletePressed: (context) =>
                          openDeleteBox(individualExpense),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  // CANCEL BUTTON
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        Navigator.pop(context);

        nameController.clear();
        amountController.clear();
      },
      child: const Text("Cancel"),
    );
  }

  // SAVE BUTTON --> createNewExpense
  Widget _createNewExpenseButton() {
    return MaterialButton(
      onPressed: () async {
        // only save if there is something in the text field
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          //pop box
          Navigator.pop(context);
          // create new expense
          Expense newExpense = Expense(
              name: nameController.text,
              amount: convertStringToDouble(amountController.text),
              date: DateTime.now());
          // save to db
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);
          // refresh graph
          refreshData();
          // clear controller
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text("Save"),
    );
  }

  // SAVE BUTTON --> editExpense
  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        // only save if there is something in the text field
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          //pop box
          Navigator.pop(context);
          // create new updated expense
          Expense updatedExpense = Expense(
              name: nameController.text.isNotEmpty
                  ? nameController.text
                  : expense.name,
              amount: amountController.text.isNotEmpty
                  ? convertStringToDouble(amountController.text)
                  : expense.amount,
              date: DateTime.now());
          int existingId = expense.id;
          // save to db
          await context
              .read<ExpenseDatabase>()
              .updateExpense(existingId, updatedExpense);
          // refresh graph
          refreshData();
          // clear controller
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text("Save"),
    );
  }

  // DELETE BUTTON
  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        Navigator.pop(context);

        // delete the expense
        await context.read<ExpenseDatabase>().deleteExpense(id);

        // refresh graph
        refreshData();
      },
      child: const Text('Delete'),
    );
  }
}
