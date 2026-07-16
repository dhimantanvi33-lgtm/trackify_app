import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:trackify/model/expense_model.dart';
import 'package:trackify/services/expense_service.dart';


enum ExpenseStatus { idle, loading, error }

class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider({ExpenseService? expenseService})
      : _expenseService = expenseService ?? ExpenseService();

  final ExpenseService _expenseService;
  StreamSubscription<List<ExpenseModel>>? _subscription;

  List<ExpenseModel> _expenses = [];
  ExpenseStatus _status = ExpenseStatus.idle;
  String? _errorMessage;
  bool _isSaving = false;

  List<ExpenseModel> get expenses => _expenses;
  ExpenseStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;
  bool get isLoading => _status == ExpenseStatus.loading;

  double get totalIncome => _expenses
      .where((e) => !e.isExpense)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalExpense => _expenses
      .where((e) => e.isExpense)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get balance => totalIncome - totalExpense;

  void startListening() {
    _status = ExpenseStatus.loading;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _expenseService.watchExpenses().listen(
          (data) {
        _expenses = data;
        _status = ExpenseStatus.idle;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object e) {
        _status = ExpenseStatus.error;
        _errorMessage =
        e is ExpenseException ? e.message : 'Failed to load transactions';
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _expenses = [];
    _status = ExpenseStatus.idle;
  }

  Future<bool> addExpense(ExpenseModel expense) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _expenseService.addExpense(expense);
      _isSaving = false;
      notifyListeners();
      return true;
    } on ExpenseException catch (e) {
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

  Future<bool> deleteExpense(String id) async {
    try {
      await _expenseService.deleteExpense(id);
      return true;
    } on ExpenseException catch (e) {
      _errorMessage = e.message;
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