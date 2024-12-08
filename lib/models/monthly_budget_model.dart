// monthly_budget_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MonthlyBudget {
  final String id;
  final DateTime month;
  final double budget;

  MonthlyBudget({
    required this.id,
    required this.month,
    required this.budget,
  });

  // Convert from Firestore document to model
  factory MonthlyBudget.fromFirestore(Map<String, dynamic> doc) {
    return MonthlyBudget(
      id: doc['id'] ?? '',
      month: (doc['month'] as Timestamp).toDate(),
      budget: doc['budget'] ?? 0.0,
    );
  }

  // Convert from model to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'month': Timestamp.fromDate(month),
      'budget': budget,
    };
  }
}
