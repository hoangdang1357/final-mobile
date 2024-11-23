import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/expense_model.dart';

class FirestoreService {
  final CollectionReference expense =
      FirebaseFirestore.instance.collection("expense");

  Future<List<ExpenseModel>> fetchExpenses() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('expense').get();

      // Chuyển dữ liệu từ Firestore thành danh sách ExpenseModel
      return snapshot.docs.map((doc) {
        return ExpenseModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      print("Error fetching expenses: $e");
      return [];
    }
  }

  // Add a new expense
  Future<void> addExpense(ExpenseModel expenseModel) async {
    try {
      await expense.add(expenseModel.toMap());
      print("Expense added");
    } catch (e) {
      throw Exception("Failed to add expense: $e");
    }
  }

  // Read all expenses for a specific month
  Future<List<ExpenseModel>> getExpensesByMonth(DateTime selectedMonth) async {
    try {
      QuerySnapshot snapshot = await expense
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(selectedMonth.year, selectedMonth.month, 1)))
          .where('date',
              isLessThan: Timestamp.fromDate(
                  DateTime(selectedMonth.year, selectedMonth.month + 1, 1)))
          .get();

      return snapshot.docs.map((doc) {
        return ExpenseModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      throw Exception("Failed to load expenses: $e");
    }
  }

// Hàm cập nhật Expense lên Firestore
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await FirebaseFirestore.instance
          .collection('expense')
          .doc(expense.id) // Dùng docId để cập nhật
          .update(expense.toMap());
    } catch (e) {
      print("Error updating expense: $e");
      rethrow;
    }
  }

  // Delete an expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      await expense.doc(expenseId).delete();
    } catch (e) {
      throw Exception("Failed to delete expense: $e");
    }
  }
}
