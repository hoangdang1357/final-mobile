import 'package:expense_tracker/screens/gemini_chat.dart';
import 'package:expense_tracker/screens/home_page.dart';
import 'package:expense_tracker/screens/expense_statistics.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../firebase/firestore.dart';
import '../models/monthly_budget_model.dart';

// screen 3
class ManageMonthlyBudgetScreen extends StatefulWidget {
  const ManageMonthlyBudgetScreen({super.key});

  @override
  State<ManageMonthlyBudgetScreen> createState() =>
      _ManageMonthlyBudgetScreenState();
}

class _ManageMonthlyBudgetScreenState extends State<ManageMonthlyBudgetScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  DateTime selectedMonth = DateTime.now();

  List<MonthlyBudget> _monthlyBudgets = [];

  @override
  void initState() {
    super.initState();
    _loadMonthlyBudgets();
  }

  void _loadMonthlyBudgets() async {
    final budgets = await _firestoreService.fetchMonthlyBudgets();
    setState(() {
      _monthlyBudgets = budgets;
    });
  }

  void _showAddBudgetDialog() {
    final TextEditingController budgetController = TextEditingController();
    DateTime? selectedMonth;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create Monthly Budget',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: budgetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Enter Budget',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? pickedMonth = await showMonthPicker(
                      context: context,
                      initialDate: selectedMonth ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedMonth != null) {
                      setState(() {
                        selectedMonth = pickedMonth;
                      });
                    }
                  },
                  child: const Text('Pick Month'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedMonth != null &&
                        budgetController.text.isNotEmpty) {
                      final newBudget = MonthlyBudget(
                        id: '',
                        month: selectedMonth!,
                        budget: double.parse(budgetController.text),
                      );
                      await _firestoreService.addMonthlyBudget(newBudget);
                      _loadMonthlyBudgets(); // Reload the budgets
                      Navigator.pop(context);
                    } else {
                      _showErrorDialog('Please fill all fields.');
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Monthly Budgets'),
        centerTitle: true,
        backgroundColor: Color(0xFFFF8C42),
        elevation: 200,
      ),
      body: _monthlyBudgets.isEmpty
          ? const Center(child: Text('No monthly budgets created'))
          : ListView.builder(
              itemCount: _monthlyBudgets.length,
              itemBuilder: (context, index) {
                final budget = _monthlyBudgets[index];
                return ListTile(
                    title: Text(
                      DateFormat('MMMM yyyy').format(budget.month),
                    ),
                    subtitle: Text('Budget: \$${budget.budget.toString()}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _firestoreService.deleteMonthlyBudget(budget.id);
                        _loadMonthlyBudgets();
                      },
                    ));
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBudgetDialog,
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
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
              onPressed: () {
                // Điều hướng đến trang cài đặt hoặc bất kỳ hành động nào
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ExpenseStatsScreen(expenses: expenses),
                  ),
                );
              },
              tooltip: "Expense statistics",
            ),
            IconButton(
              icon: const Icon(Icons.wallet),
              onPressed: () {},
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
