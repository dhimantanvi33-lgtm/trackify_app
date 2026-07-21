import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:trackify/model/bill_model.dart';
import 'package:trackify/services/bills_service.dart';

enum BillsStatus { idle, loading, error }

class BillProvider extends ChangeNotifier {
  BillProvider({BillService? billService})
      : _billService = billService ?? BillService();

  final BillService _billService;
  StreamSubscription<List<Bill>>? _subscription;

  List<Bill> _bills = [];
  BillsStatus _status = BillsStatus.idle;
  String? _errorMessage;
  bool _isSaving = false;

  List<Bill> get bills => List.unmodifiable(_bills);
  BillsStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;
  bool get isLoading => _status == BillsStatus.loading;

  double get totalDue => _bills
      .where((b) => b.status != BillStatus.paid)
      .fold(0.0, (sum, b) => sum + b.amount);

  int get paidCount => _bills.where((b) => b.status == BillStatus.paid).length;
  int get dueCount => _bills.where((b) => b.status == BillStatus.due).length;
  int get overdueCount =>
      _bills.where((b) => b.status == BillStatus.overdue).length;

  List<Bill> billsForFilter(int filterIndex) {
    switch (filterIndex) {
      case 1:
        return _bills
            .where((b) =>
        b.status == BillStatus.due || b.status == BillStatus.overdue)
            .toList();
      case 2:
        return _bills.where((b) => b.status == BillStatus.paid).toList();
      default:
        return _bills;
    }
  }

  void startListening() {
    _status = BillsStatus.loading;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _billService.watchBills().listen(
          (bills) {
        _bills = bills;
        _status = BillsStatus.idle;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object e) {
        _status = BillsStatus.error;
        _errorMessage =
        e is BillException ? e.message : 'Failed to load bills';
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _bills = [];
    _status = BillsStatus.idle;
  }

  Future<bool> addBill({
    required String title,
    required String category,
    required double amount,
    required DateTime dueDate,
    required bool isRecurring,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final bill = Bill(
        id: '',
        title: title,
        category: category,
        amount: amount,
        dueDate: dueDate,
        isRecurring: isRecurring,
        isPaid: false,
      );
      await _billService.addBill(bill);
      _isSaving = false;
      notifyListeners();
      return true;
    } on BillException catch (e) {
      _isSaving = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _isSaving = false;
      _errorMessage = 'Something went wrong. Please try again';
      notifyListeners();
      return false;
    }
  }

  Future<bool> togglePaid(Bill bill) async {
    final index = _bills.indexWhere((b) => b.id == bill.id);
    final previous = index != -1 ? _bills[index] : null;

    if (index != -1) {
      _bills[index] = bill.copyWith(isPaid: !bill.isPaid);
      notifyListeners();
    }

    try {
      await _billService.setPaidStatus(bill.id, !bill.isPaid);
      return true;
    } on BillException catch (e) {
      _errorMessage = e.message;
      if (index != -1 && previous != null) _bills[index] = previous;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again';
      if (index != -1 && previous != null) _bills[index] = previous;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBill(String billId) async {
    try {
      await _billService.deleteBill(billId);
      return true;
    } on BillException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}