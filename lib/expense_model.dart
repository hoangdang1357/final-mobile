import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  String id;
  final String item;
  final double amount;
  final DateTime date;
  final String type;
  final bool isIncome;

  ExpenseModel({
    required this.id,
    required this.item,
    required this.amount,
    required this.date,
    required this.type,
    required this.isIncome,
  });

  // Chuyển từ Map sang ExpenseModel
  factory ExpenseModel.fromMap(Map<String, dynamic> map, String id) {
    return ExpenseModel(
      id: id,
      item: map['item'],
      amount: map['amount'],
      date: (map['date'] as Timestamp).toDate(),
      type: map['type'],
      isIncome: map['isIncome'],
    );
  }

  // Chuyển từ ExpenseModel sang Map
  Map<String, dynamic> toMap() {
    return {
      'item': item,
      'amount': amount,
      'date': date,
      'type': type,
      'isIncome': isIncome,
    };
  }
}
