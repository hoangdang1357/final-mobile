import 'package:expense_tracker/screens/gemini_chat.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/firebase/firestore.dart';
import 'package:expense_tracker/item.dart';
import 'package:expense_tracker/screens/manage_monthly_budget.dart';
import 'package:expense_tracker/option_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/screens/monthly_expense_management_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

List<ExpenseModel> expenses = [];
List<ExpenseModel> filteredExpenses = [];

class _HomePageState extends State<HomePage> {
  final itemController = TextEditingController();
  final amountController = TextEditingController();
  final dateController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  double totalMoney = 0;
  double spentMoney = 0;
  double income = 0;
  DateTime? pickedDate;
  String? selectedType = 'food'; // Default type is "food"

  @override
  void initState() {
    super.initState();

    // fetchMonthlyBudgets();
    _loadExpenses();
    filteredExpenses = List.from(expenses);
    _searchController.addListener(_filterExpenses);
  }

  // Hàm tải dữ liệu từ Firestore

  // Hàm tải dữ liệu từ Firestore
  void _loadExpenses() async {
    final fetchedExpenses = await _firestoreService.fetchExpenses();
    setState(() {
      expenses = fetchedExpenses;
      filteredExpenses = List.from(expenses);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: SizedBox(
        height: 55,
        child: FloatingActionButton(
          backgroundColor: Colors.purple,
          onPressed: _showAddOrEditDialog,
          child: const Icon(Icons.add, size: 26),
        ),
      ),
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        centerTitle: true,
        backgroundColor: Color(0xFF6439FF),
        elevation: 20,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: filteredExpenses.isEmpty
                  ? const Center(
                      child: Text("No expenses found"),
                    )
                  : ListView.builder(
                      itemCount: filteredExpenses.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onLongPressStart: (LongPressStartDetails details) {
                            showMenu<String>(
                              context: context,
                              position: RelativeRect.fromLTRB(
                                details.globalPosition.dx,
                                details.globalPosition.dy,
                                MediaQuery.of(context).size.width -
                                    details.globalPosition.dx,
                                MediaQuery.of(context).size.height -
                                    details.globalPosition.dy,
                              ),
                              items: [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ).then((value) {
                              if (value == 'edit') {
                                _showAddOrEditDialog(
                                  expense: filteredExpenses[index],
                                  index:
                                      expenses.indexOf(filteredExpenses[index]),
                                );
                              } else if (value == 'delete') {
                                _showDeleteDialog(
                                    expenses.indexOf(filteredExpenses[index]));
                              }
                            });
                          },
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            title: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Item(
                                    expense: filteredExpenses[index],
                                    onDelete: () => _deleteExpense(expenses
                                        .indexOf(filteredExpenses[index])),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
              onPressed: () {},
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

  void _showAddOrEditDialog({ExpenseModel? expense, int? index}) {
    final isEditing = expense != null;

    if (isEditing) {
      itemController.text = expense.item;
      amountController.text = expense.amount.toString();
      dateController.text = DateFormat.yMMMMd().format(expense.date);
      pickedDate = expense.date;
      selectedType = expense.type;
      context
          .read<OptionProvider>()
          .updateOption(expense.isIncome ? "income" : "expense");
    } else {
      itemController.clear();
      amountController.clear();
      dateController.clear();
      pickedDate = null;
      selectedType = 'food';
      context.read<OptionProvider>().updateOption("expense");
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 500),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isEditing ? "EDIT TRANSACTION" : "ADD TRANSACTION",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: itemController,
                      decoration: const InputDecoration(
                        hintText: "Enter the Item",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "Enter the Amount",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onTap: () async {
                        pickedDate = await showDatePicker(
                          context: context,
                          initialDate: pickedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          dateController.text =
                              DateFormat.yMMMMd().format(pickedDate!);
                        }
                      },
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: "DATE",
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: "Transaction Type",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedType = newValue;
                        });
                      },
                      items: <String>[
                        'entertainment',
                        'clothes',
                        'service',
                        'transportation',
                        'food',
                        'other',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Consumer<OptionProvider>(
                      builder: (context, optionProvider, child) {
                        return Column(
                          children: [
                            RadioListTile(
                              title: const Text("Expense"),
                              value: "expense",
                              groupValue: optionProvider.currentOption,
                              onChanged: (value) {
                                optionProvider.updateOption(value!);
                              },
                            ),
                            RadioListTile(
                              title: const Text("Income"),
                              value: "income",
                              groupValue: optionProvider.currentOption,
                              onChanged: (value) {
                                optionProvider.updateOption(value!);
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_validateInputs()) {
                              final newExpense = ExpenseModel(
                                item: itemController.text,
                                amount: double.parse(amountController.text),
                                date: pickedDate!,
                                type: selectedType!,
                                isIncome: context
                                        .read<OptionProvider>()
                                        .currentOption ==
                                    "income",
                                id: '',
                              );

                              if (isEditing) {
                                _updateExpense(expense, newExpense, index!);
                              } else {
                                _addExpense(newExpense);
                              }

                              _clearInputs();
                              Navigator.pop(context);
                            } else {
                              _showErrorDialog("Please fill all fields");
                            }
                          },
                          child: const Text("Save"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this expense?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteExpense(index);

                Navigator.pop(context);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void _filterExpenses() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredExpenses = expenses.where((expense) {
        return expense.item.toLowerCase().contains(query) ||
            expense.amount.toString().contains(query) ||
            DateFormat.yMMMMd()
                .format(expense.date)
                .toLowerCase()
                .contains(query) ||
            expense.type.toLowerCase().contains(query) ||
            (expense.isIncome ? "income" : "expense")
                .toLowerCase()
                .contains(query);
      }).toList();
    });
  }

  bool _validateInputs() {
    return itemController.text.isNotEmpty &&
        amountController.text.isNotEmpty &&
        pickedDate != null;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _clearInputs() {
    itemController.clear();
    amountController.clear();
    dateController.clear();
    pickedDate = null;
    selectedType = 'food';
    context.read<OptionProvider>().updateOption("expense");
  }

  void _addExpense(ExpenseModel newExpense) async {
    try {
      final docRef = await _firestoreService.addExpense(newExpense);

      final newExpenseWithId = newExpense.copyWith(id: docRef.id);

      setState(() {
        expenses.add(newExpenseWithId);
        _filterExpenses();
      });
    } catch (e) {
      _showErrorDialog("Failed to add expense: $e");
    }
  }

  void _updateExpense(
      ExpenseModel oldExpense, ExpenseModel newExpense, int index) async {
    try {
      await _firestoreService.deleteExpense(oldExpense.id);
      await _firestoreService.addExpense(newExpense);
      setState(() {
        expenses[index] = newExpense;
        _filterExpenses();
      });
    } catch (e) {
      _showErrorDialog("Failed to update expense: $e");
    }
  }

  void _deleteExpense(int index) async {
    final myExpense = expenses[index];
    try {
      await _firestoreService.deleteExpense(myExpense.id);
    } catch (e) {
      _showErrorDialog("Failed to delete expense: $e");
    }
  }
}
