import 'package:expense_tracker/screens/gemini_chat.dart';
import 'package:expense_tracker/screens/home_page.dart';
import 'package:expense_tracker/screens/monthly_expense_management_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../firebase/firestore.dart';
import '../models/monthly_budget_model.dart';

class ManageMonthlyBudgetScreen extends StatefulWidget {
  const ManageMonthlyBudgetScreen({super.key});

  @override
  State<ManageMonthlyBudgetScreen> createState() =>
      _ManageMonthlyBudgetScreenState();
}

class _ManageMonthlyBudgetScreenState extends State<ManageMonthlyBudgetScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<MonthlyBudget> _monthlyBudgets = [];

  @override
  void initState() {
    super.initState();
    _loadMonthlyBudgets(); // Call to load data as soon as the screen loads
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
                TextButton(
                  onPressed: () async {
                    selectedMonth = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedMonth != null) {
                      // Date selected, do nothing for now
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
                        id: '', // Firestore will auto-generate the ID
                        month: selectedMonth!,
                        budget: double.parse(budgetController.text),
                      );
                      await _firestoreService.addMonthlyBudget(newBudget);
                      _loadMonthlyBudgets(); // Reload the budgets
                      Navigator.pop(context); // Close the dialog
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
              icon: const Icon(Icons.insert_chart_outlined),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MonthlyExpenseScreen(),
                  ),
                );
              },
              tooltip: "Overview",
            ),
            IconButton(
              icon: const Icon(Icons.access_time_outlined),
              onPressed: () {
                // Điều hướng đến trang cài đặt hoặc bất kỳ hành động nào
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
