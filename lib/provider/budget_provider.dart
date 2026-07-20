import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:trackify/services/budget_service.dart';

enum BudgetStatus { idle, loading, error }

class BudgetProvider extends ChangeNotifier {
  BudgetProvider({BudgetService? budgetService})
      : _budgetService = budgetService ?? BudgetService();

  final BudgetService _budgetService;
  StreamSubscription<double?>? _subscription;

  double? _monthlyBudget;
  BudgetStatus _status = BudgetStatus.idle;
  String? _errorMessage;
  bool _isSaving = false;

  double? get monthlyBudget => _monthlyBudget;
  BudgetStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;
  bool get isLoading => _status == BudgetStatus.loading;
  bool get hasBudget => _monthlyBudget != null;

  void startListening() {
    _status = BudgetStatus.loading;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _budgetService.watchBudget().listen(
          (amount) {
        _monthlyBudget = amount;
        _status = BudgetStatus.idle;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object e) {
        _status = BudgetStatus.error;
        _errorMessage =
        e is BudgetException ? e.message : 'Failed to load budget';
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _monthlyBudget = null;
    _status = BudgetStatus.idle;
  }

  Future<bool> setBudget(double amount) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _budgetService.setBudget(amount);
      _monthlyBudget = amount;
      _isSaving = false;
      notifyListeners();
      return true;
    } on BudgetException catch (e) {
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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}