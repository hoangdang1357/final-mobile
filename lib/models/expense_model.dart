import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
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

  // Convert a Firestore document into an ExpenseModel object
  factory ExpenseModel.fromMap(Map<String, dynamic> data, String docId) {
    return ExpenseModel(
      id: docId,
      item: data['item'],
      amount: data['amount'],
      date: (data['date'] as Timestamp).toDate(),
      type: data['type'],
      isIncome: data['isIncome'],
    );
  }

  // Convert an ExpenseModel object to a map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      // 'id': docID,
      'item': item,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'type': type,
      'isIncome': isIncome,
    };
  }
}

extension ExpenseModelCopyWith on ExpenseModel {
  ExpenseModel copyWith({
    String? id,
    String? item,
    double? amount,
    DateTime? date,
    String? type,
    bool? isIncome,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      item: item ?? this.item,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      isIncome: isIncome ?? this.isIncome,
    );
  }
}
