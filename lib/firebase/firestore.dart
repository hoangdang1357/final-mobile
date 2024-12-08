import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/models/expense_model.dart';
import 'package:expense_tracker/models/monthly_budget_model.dart';

class FirestoreService {
  final CollectionReference expense =
      FirebaseFirestore.instance.collection("expense");

  // Add Monthly Budget
  // Add a new monthly budget
  Future<void> addMonthlyBudget(MonthlyBudget budget) async {
    try {
      await FirebaseFirestore.instance
          .collection('monthly_budgets')
          .add(budget.toMap());
    } catch (e) {
      print('Error adding monthly budget: $e');
    }
  }

  // Fetch all monthly budgets
  // Fetch monthly budgets from Firestore
  Future<List<MonthlyBudget>> fetchMonthlyBudgets() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('monthly_budgets').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final budget = (data['budget'] is int)
            ? (data['budget'] as int).toDouble()
            : data['budget'].toDouble(); // Ensure budget is a double
        return MonthlyBudget(
          id: doc.id,
          month: (data['month'] as Timestamp).toDate(),
          budget: budget,
        );
      }).toList();
    } catch (e) {
      print("Error fetching monthly budgets: $e");
      return [];
    }
  }

  // Delete a monthly budget from Firestore
  Future<void> deleteMonthlyBudget(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('monthly_budgets')
          .doc(id)
          .delete();
    } catch (e) {
      print("Error deleting monthly budget: $e");
    }
  }

  // Get Monthly Budgets
  Stream<List<Map<String, dynamic>>> getMonthlyBudgets() {
    return FirebaseFirestore.instance
        .collection('monthly_budget')
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map(
          (doc) {
            return doc.data() as Map<String, dynamic>;
          },
        ).toList();
      },
    );
  }

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
  Future<DocumentReference> addExpense(ExpenseModel expense) async {
    try {
      // Add expense to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('expense')
          .add(expense.toMap());
      return docRef; // Return the document reference (which includes the ID)
    } catch (e) {
      print("Error adding expense to Firestore: $e");
      rethrow;
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

  // Update an existing expense
  Future<void> updateExpense(ExpenseModel expenseModel) async {
    try {
      await expense.doc(expenseModel.id).update(expenseModel.toMap());
    } catch (e) {
      throw Exception("Failed to update expense: $e");
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
