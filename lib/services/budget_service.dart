import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetException implements Exception {
  final String message;
  BudgetException(this.message);

  @override
  String toString() => message;
}

class BudgetService {
  BudgetService({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  String get _uid {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw BudgetException('You must be logged in to do this');
    }
    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> get _budgetDoc => _firestore
      .collection('users')
      .doc(_uid)
      .collection('settings')
      .doc('budget');

  Future<void> setBudget(double amount) async {
    try {
      await _budgetDoc.set({
        'amount': amount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw BudgetException(e.message ?? 'Failed to save budget');
    }
  }

  Future<double?> getBudget() async {
    try {
      final snap = await _budgetDoc.get();
      final data = snap.data();
      if (data == null || data['amount'] == null) return null;
      return (data['amount'] as num).toDouble();
    } on FirebaseException catch (e) {
      throw BudgetException(e.message ?? 'Failed to load budget');
    }
  }

  Stream<double?> watchBudget() {
    return _budgetDoc.snapshots().map((snap) {
      final data = snap.data();
      if (data == null || data['amount'] == null) return null;
      return (data['amount'] as num).toDouble();
    });
  }
}