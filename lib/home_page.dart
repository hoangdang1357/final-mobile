import 'package:expense_tracker/expense_model.dart';
import 'package:expense_tracker/item.dart';
import 'package:expense_tracker/fund_condition_widget.dart';
import 'package:expense_tracker/option_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

List<ExpenseModel> expenses = [];

class _HomePageState extends State<HomePage> {
  final itemController = TextEditingController();
  final amountController = TextEditingController();
  final dateController = TextEditingController();
  int amount = 0;
  int totalMoney = 0;
  int spentMoney = 0;
  int income = 0;
  DateTime? pickedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: SizedBox(
        height: 67,
        child: FloatingActionButton(
          backgroundColor: Colors.purple,
          onPressed: () {
            _showAddOrEditDialog();
          },
          child: const Icon(Icons.add, size: 26),
        ),
      ),
      appBar: AppBar(
        title: const Text("Expense Tracker"),
        centerTitle: true,
        backgroundColor: Colors.red.shade500,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FundCondition(
                      type: "Monthly budget",
                      amount: "$totalMoney",
                      icon: "blue"),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: FundCondition(
                      type: "EXPENSE", amount: "$spentMoney", icon: "orange"),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 8),
                  child: FundCondition(
                      type: "INCOME", amount: "$income", icon: "grey"),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.builder(
                itemCount: expenses.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Item(
                      expense: expenses[index],
                      onDelete: () {},
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showAddOrEditDialog(
                              expense: expenses[index], index: index);
                        } else if (value == 'delete') {
                          _showDeleteDialog(index);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      icon: const Icon(Icons.more_vert),
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

  void _showAddOrEditDialog({ExpenseModel? expense, int? index}) {
    final isEditing = expense != null;

    if (isEditing) {
      itemController.text = expense.item;
      amountController.text = expense.amount.toString();
      dateController.text = DateFormat.yMMMMd().format(expense.date);
      pickedDate = expense.date;
      context
          .read<OptionProvider>()
          .updateOption(expense.isIncome ? "income" : "expense");
    } else {
      itemController.clear();
      amountController.clear();
      dateController.clear();
      pickedDate = null;
      context.read<OptionProvider>().updateOption("expense");
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? "EDIT TRANSACTION" : "ADD TRANSACTION"),
          actions: [
            TextButton(
              onPressed: () {
                amount = int.parse(amountController.text);
                final newExpense = ExpenseModel(
                  item: itemController.text,
                  amount: amount,
                  isIncome:
                      context.read<OptionProvider>().currentOption == "income",
                  date: pickedDate!,
                );

                setState(() {
                  if (isEditing && index != null) {
                    final oldExpense = expenses[index];
                    if (oldExpense.isIncome) {
                      income -= oldExpense.amount;
                      totalMoney -= oldExpense.amount;
                    } else {
                      spentMoney -= oldExpense.amount;
                      totalMoney += oldExpense.amount;
                    }

                    expenses[index] = newExpense;
                  } else {
                    expenses.add(newExpense);
                  }

                  if (newExpense.isIncome) {
                    income += newExpense.amount;
                    totalMoney += newExpense.amount;
                  } else {
                    spentMoney += newExpense.amount;
                    totalMoney -= newExpense.amount;
                  }
                });

                itemController.clear();
                amountController.clear();
                dateController.clear();
                Navigator.pop(context);
              },
              child: Text(isEditing ? "SAVE" : "ADD"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL"),
            ),
          ],
          content: SizedBox(
            height: 340,
            child: Column(
              children: [
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
                const SizedBox(height: 18),
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
                const SizedBox(height: 15),
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
              ],
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
          title: const Text("Confirm to Delete the Item?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL"),
            ),
            TextButton(
              onPressed: () {
                final myExpense = expenses[index];
                setState(() {
                  if (myExpense.isIncome) {
                    income -= myExpense.amount;
                    totalMoney -= myExpense.amount;
                  } else {
                    spentMoney -= myExpense.amount;
                    totalMoney += myExpense.amount;
                  }
                  expenses.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text("DELETE"),
            ),
          ],
        );
      },
    );
  }
}
