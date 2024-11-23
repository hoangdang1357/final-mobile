import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/expense_model.dart';

class Item extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onDelete;

  const Item({
    Key? key,
    required this.expense,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 9,
        bottom: 7,
        left: 12,
        right: 11,
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(blurRadius: 0.4),
          ],
          borderRadius: BorderRadius.all(
            Radius.circular(11.5),
          ),
          color: Colors.white,
        ),
        child: Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: expense.isIncome
                  ? Image.asset("images/income.png")
                  : Image.asset("images/expense.png"),
            ),
            const SizedBox(width: 11),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.item,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat.yMMMMd().format(expense.date),
                  style: const TextStyle(
                    fontSize: 14.7,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  expense.type, // Display the type
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              "\$${expense.amount}",
              style: TextStyle(
                fontSize: 20,
                color: expense.isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
