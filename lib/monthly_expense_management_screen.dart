import 'package:expense_tracker/expense_model.dart';
import 'package:expense_tracker/home_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyExpenseScreen extends StatefulWidget {
  const MonthlyExpenseScreen({Key? key}) : super(key: key);

  @override
  State<MonthlyExpenseScreen> createState() => _MonthlyExpenseScreenState();
}

class _MonthlyExpenseScreenState extends State<MonthlyExpenseScreen> {
  DateTime selectedMonth = DateTime.now();
  List<ExpenseModel> monthlyExpenses = [];

  @override
  void initState() {
    super.initState();
    _filterExpensesByMonth();
  }

  void _filterExpensesByMonth() {
    monthlyExpenses = expenses.where((expense) {
      return expense.date.year == selectedMonth.year &&
          expense.date.month == selectedMonth.month;
    }).toList();
  }

  Future<void> _selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && (picked.year != selectedMonth.year || picked.month != selectedMonth.month)) {
      setState(() {
        selectedMonth = picked;
        _filterExpensesByMonth();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monthly Expense Management"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _selectMonth,
              child: Text(
                "Select Month: ${DateFormat.yMMMM().format(selectedMonth)}",
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: monthlyExpenses.length,
                itemBuilder: (context, index) {
                  final expense = monthlyExpenses[index];
                  return ListTile(
                    title: Text(expense.item),
                    subtitle: Text(
                      "${expense.isIncome ? "Income" : "Expense"} - ${DateFormat.yMMMMd().format(expense.date)}",
                    ),
                    trailing: Text(
                      expense.amount.toString(),
                      style: TextStyle(
                        color: expense.isIncome ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}