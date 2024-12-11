import 'package:expense_tracker/screens/monthly_budgets.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'gemini_chat.dart';
import 'home_page.dart';

class ExpenseStatsScreen extends StatefulWidget {
  final List<ExpenseModel> expenses;

  const ExpenseStatsScreen({super.key, required this.expenses});

  @override
  State<ExpenseStatsScreen> createState() => _ExpenseStatsScreenState();
}

class _ExpenseStatsScreenState extends State<ExpenseStatsScreen> {
  DateTime _selectedMonth = DateTime.now();
  double _totalExpense = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateMonthlyExpense();
  }

  void _calculateMonthlyExpense() {
    final expensesForMonth = widget.expenses.where((expense) {
      return !expense.isIncome &&
          expense.date.year == _selectedMonth.year &&
          expense.date.month == _selectedMonth.month;
    });

    setState(() {
      _totalExpense =
          expensesForMonth.fold(0.0, (sum, expense) => sum + expense.amount);
    });
  }

  Future<void> _pickMonth() async {
    final DateTime? picked = await showMonthPicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
      });
      _calculateMonthlyExpense();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, double> expenseByType = _calculateExpenseByType();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Expense Statistics"),
        centerTitle: true,
        backgroundColor: const Color(0xFF6439FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickMonth,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6439FF),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                "Select Month: ${DateFormat.yMMMM().format(_selectedMonth)}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              "Total Expense: \$${_totalExpense.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: _generatePieChartSections(expenseByType),
                  centerSpaceRadius: 30,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: ListView(
                children: expenseByType.entries
                    .map(
                      (entry) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getColorForType(entry.key),
                          radius: 10,
                        ),
                        title: Text(entry.key),
                        trailing: Text(
                          "\$${entry.value.toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
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
              icon: const Icon(Icons.access_time_outlined),
              onPressed: () {},
              tooltip: "Expense statistics",
            ),
            IconButton(
              icon: const Icon(Icons.wallet),
              onPressed: () {
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

  Map<String, double> _calculateExpenseByType() {
    final Map<String, double> expenseByType = {};

    for (var expense in widget.expenses) {
      if (!expense.isIncome &&
          expense.date.year == _selectedMonth.year &&
          expense.date.month == _selectedMonth.month) {
        expenseByType.update(
          expense.type,
          (value) => value + expense.amount,
          ifAbsent: () => expense.amount,
        );
      }
    }

    return expenseByType;
  }

  List<PieChartSectionData> _generatePieChartSections(
      Map<String, double> expenseByType) {
    final total = expenseByType.values.fold(0.0, (sum, value) => sum + value);

    return expenseByType.entries.map((entry) {
      final percentage = (entry.value / total) * 100;
      return PieChartSectionData(
        value: entry.value,
        title: "${percentage.toStringAsFixed(1)}%",
        color: _getColorForType(entry.key),
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 80,
      );
    }).toList();
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'food':
        return Colors.green;
      case 'entertainment':
        return Colors.blue;
      case 'clothes':
        return Colors.orange;
      case 'service':
        return Colors.red;
      case 'transportation':
        return Colors.purple;
      case 'other':
      default:
        return Colors.grey;
    }
  }
}
