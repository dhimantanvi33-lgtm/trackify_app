import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trackify/model/bill_model.dart';

class BillException implements Exception {
  final String message;
  BillException(this.message);

  @override
  String toString() => message;
}

class BillService {
  BillService({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  String get _uid {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw BillException('You must be logged in to do this');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _billsCol =>
      _firestore.collection('users').doc(_uid).collection('bills');

  Future<void> addBill(Bill bill) async {
    try {
      await _billsCol.add(bill.toMap());
    } on FirebaseException catch (e) {
      throw BillException(e.message ?? 'Failed to save bill');
    }
  }

  Future<void> updateBill(Bill bill) async {
    try {
      await _billsCol.doc(bill.id).update(bill.toMap());
    } on FirebaseException catch (e) {
      throw BillException(e.message ?? 'Failed to update bill');
    }
  }

  Future<void> setPaidStatus(String billId, bool isPaid) async {
    try {
      await _billsCol.doc(billId).update({
        'isPaid': isPaid,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw BillException(e.message ?? 'Failed to update bill');
    }
  }

  Future<void> deleteBill(String billId) async {
    try {
      await _billsCol.doc(billId).delete();
    } on FirebaseException catch (e) {
      throw BillException(e.message ?? 'Failed to delete bill');
    }
  }

  Stream<List<Bill>> watchBills() {
    return _billsCol.orderBy('dueDate').snapshots().map((snap) {
      return snap.docs.map((doc) => Bill.fromMap(doc.id, doc.data())).toList();
    });
  }
}