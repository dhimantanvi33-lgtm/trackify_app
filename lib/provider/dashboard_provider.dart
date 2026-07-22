import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:trackify/model/category.dart';
import 'package:trackify/model/expense_model.dart';
import 'package:trackify/screens/dashboard/widgets/expense_pie_chart.dart';
import 'package:trackify/screens/dashboard/widgets/rescent_transactions.dart';
import 'package:trackify/services/dashboard_service.dart';

enum DashboardStatus { idle, loading, error }

class DashboardProvider extends ChangeNotifier {
  DashboardProvider({DashboardService? dashboardService})
      : _dashboardService = dashboardService ?? DashboardService();

  final DashboardService _dashboardService;
  StreamSubscription<List<ExpenseModel>>? _subscription;

  List<ExpenseModel> _transactions = [];
  DashboardStatus _status = DashboardStatus.idle;
  String? _errorMessage;

  DashboardStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == DashboardStatus.loading;

  double get totalIncome => _transactions
      .where((e) => !e.isExpense)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalExpense => _transactions
      .where((e) => e.isExpense)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalBalance => totalIncome - totalExpense;

  List<ExpenseCategory> get categoryBreakdown {
    final expenseTxns = _transactions.where((e) => e.isExpense).toList();
    if (expenseTxns.isEmpty) return [];

    final totals = <String, double>{};
    for (final t in expenseTxns) {
      totals[t.category] = (totals[t.category] ?? 0) + t.amount;
    }

    final totalSpend = totals.values.fold(0.0, (a, b) => a + b);
    final entries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.map((entry) {
      final meta = metaFor(entry.key);
      final percentage =
      totalSpend == 0 ? 0.0 : (entry.value / totalSpend) * 100;
      return ExpenseCategory(
        label: entry.key,
        percentage: percentage,
        color: meta.color,
        icon: meta.icon,
      );
    }).toList();
  }

  /// All transactions, newest first. Use this (instead of [recentTransactions])
  /// wherever the full history is needed, e.g. an "All Transactions" screen.
  List<TransactionItem> get allTransactions {
    final sorted = _sortedByRecency();
    return sorted.map(_toTransactionItem).toList();
  }

  /// Just the latest 5, for the dashboard's summary card.
  List<TransactionItem> get recentTransactions {
    final sorted = _sortedByRecency();
    return sorted.take(5).map(_toTransactionItem).toList();
  }

  List<ExpenseModel> _sortedByRecency() {
    final sorted = [..._transactions]..sort((a, b) {
      final aTime = a.createdAt ?? a.date;
      final bTime = b.createdAt ?? b.date;
      return bTime.compareTo(aTime);
    });
    return sorted;
  }

  TransactionItem _toTransactionItem(ExpenseModel t) {
    final meta = metaFor(t.category);
    final date = t.createdAt ?? t.date;
    return TransactionItem(
      title: t.title,
      category: t.category,
      amount: t.amount,
      isExpense: t.isExpense,
      icon: meta.icon,
      iconColor: meta.color,
      time: _formatRelativeTime(date),
      date: date,
    );
  }

  static const weekLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  List<double> get weeklySpend {
    final now = DateTime.now();
    final startOfWeek =
    DateTime(now.year, now.month, now.day - (now.weekday - 1));

    return List.generate(7, (i) {
      final day = startOfWeek.add(Duration(days: i));
      return _transactions
          .where((t) =>
      t.isExpense &&
          t.date.year == day.year &&
          t.date.month == day.month &&
          t.date.day == day.day)
          .fold(0.0, (sum, t) => sum + t.amount);
    });
  }

  void startListening() {
    _status = DashboardStatus.loading;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _dashboardService.watchAllTransactions().listen(
          (data) {
        _transactions = data;
        _status = DashboardStatus.idle;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (Object e) {
        _status = DashboardStatus.error;
        _errorMessage = 'Failed to load dashboard data';
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  String _formatRelativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}