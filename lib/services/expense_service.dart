import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trackify/model/expense_model.dart';


class ExpenseException implements Exception {
  final String message;
  ExpenseException(this.message);

  @override
  String toString() => message;
}

class ExpenseService {
  ExpenseService({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  String get _uid {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw ExpenseException('You must be logged in to do this');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _expensesRef =>
      _firestore.collection('users').doc(_uid).collection('expenses');

  Future<String> addExpense(ExpenseModel expense) async {
    try {
      final doc = await _expensesRef.add(expense.toMap());
      return doc.id;
    } on FirebaseException catch (e, stackTrace) {
      throw ExpenseException(e.message ?? 'Failed to save transaction');
    } catch (e, stackTrace) {
      rethrow;
    }
  }
  Future<void> updateExpense(ExpenseModel expense) async {
    if (expense.id == null) {
      throw ExpenseException('Missing transaction id');
    }
    try {
      await _expensesRef.doc(expense.id).update(expense.toMap());
    } on FirebaseException catch (e) {
      throw ExpenseException(e.message ?? 'Failed to update transaction');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _expensesRef.doc(id).delete();
    } on FirebaseException catch (e) {
      throw ExpenseException(e.message ?? 'Failed to delete transaction');
    }
  }

  Stream<List<ExpenseModel>> watchExpenses() {
    return _expensesRef.orderBy('date', descending: true).snapshots().map(
          (snap) => snap.docs
          .map((d) => ExpenseModel.fromMap(d.id, d.data()))
          .toList(),
    );
  }
}