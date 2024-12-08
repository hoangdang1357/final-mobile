import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'gemini_chat.dart';
import 'manage_monthly_budget.dart';

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

  // Filter expenses by selected month
  void _filterExpensesByMonth() {
    monthlyExpenses = expenses.where((expense) {
      return expense.date.year == selectedMonth.year &&
          expense.date.month == selectedMonth.month;
    }).toList();
  }

  // Select a new month from the date picker
  Future<void> _selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null &&
        (picked.year != selectedMonth.year ||
            picked.month != selectedMonth.month)) {
      setState(() {
        selectedMonth = picked;
        _filterExpensesByMonth();
      });
    }
  }

  // Calculate total expenses for the selected month
  double getTotalExpenses() {
    double total = 0.0;
    for (var expense in monthlyExpenses) {
      total += expense.amount;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Monthly Expense Management"),
        centerTitle: true,
        backgroundColor: Color(0xFF2ECC71),
        elevation: 20,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Button to select the month
            ElevatedButton(
              onPressed: _selectMonth,
              child: Text(
                "Select Month: ${DateFormat.yMMMM().format(selectedMonth)}",
              ),
            ),
            const SizedBox(height: 20),

            // Display the total expenses for the selected month
            Text(
              "Total Expenses: \$${getTotalExpenses().toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // List of expenses
            Expanded(
              child: monthlyExpenses.isEmpty
                  ? Center(
                      child: Text(
                        "No expenses found for ${DateFormat.yMMMM().format(selectedMonth)}",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: monthlyExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = monthlyExpenses[index];
                        return ListTile(
                          title: Text(expense.item),
                          subtitle: Text(
                            "${expense.isIncome ? "Income" : "Expense"} - ${DateFormat.yMMMMd().format(expense.date)}",
                          ),
                          trailing: Text(
                            NumberFormat.currency(locale: 'en_US', symbol: '\$')
                                .format(expense.amount),
                            style: TextStyle(
                              color:
                                  expense.isIncome ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 65,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
              tooltip: "Manage Monthly Expenses",
            ),
            IconButton(
              icon: const Icon(Icons.insert_chart_outlined),
              onPressed: () {},
              tooltip: "Overview",
            ),
            IconButton(
              icon: const Icon(Icons.access_time_outlined),
              onPressed: () {
                // Điều hướng đến trang cài đặt hoặc bất kỳ hành động nào
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManageMonthlyBudgetScreen(),
                  ),
                );
              },
              tooltip: "Monthly Budget",
            ),
            IconButton(
              icon: const Icon(Icons.android),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GeminiChatbot(),
                  ),
                );
              },
              tooltip: "AI chat",
            ),
          ],
        ),
      ),
    );
  }
}
