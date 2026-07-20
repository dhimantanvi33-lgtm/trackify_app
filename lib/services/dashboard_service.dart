// lib/services/dashboard_service.dart
import 'package:trackify/model/expense_model.dart';
import 'package:trackify/services/expense_service.dart';

class DashboardService {
  DashboardService({ExpenseService? expenseService})
      : _expenseService = expenseService ?? ExpenseService();

  final ExpenseService _expenseService;

  Stream<List<ExpenseModel>> watchAllTransactions() {
    return _expenseService.watchExpenses();
  }
}