import 'package:flutter/material.dart';
import 'package:trackify/features/auth/widgets/bg_glow.dart';
import 'package:trackify/features/dashboard/bills/bills_screen.dart';
import 'package:trackify/features/dashboard/expense/add_expense.dart';
import 'package:trackify/features/dashboard/stats/stats_screen.dart';
import 'package:trackify/features/dashboard/widgets/bidget_progress.dart';
import 'package:trackify/features/dashboard/widgets/dash_board_header.dart';
import 'package:trackify/features/dashboard/widgets/rescent_transactions.dart';

import '../../core/constants/app_colors.dart';
import 'widgets/balance_card.dart';
import 'widgets/expense_pie_chart.dart';

import 'widgets/spending_line_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;


  static const _categories = [
    ExpenseCategory(
      label: 'Food',
      percentage: 40,
      color: Color(0xFF818CF8),
      icon: Icons.restaurant_outlined,
    ),
    ExpenseCategory(
      label: 'Travel',
      percentage: 25,
      color: Color(0xFF38BDF8),
      icon: Icons.directions_transit_outlined,
    ),
    ExpenseCategory(
      label: 'Shopping',
      percentage: 20,
      color: Color(0xFFFBBF24),
      icon: Icons.shopping_bag_outlined,
    ),
    ExpenseCategory(
      label: 'Bills',
      percentage: 15,
      color: Color(0xFFF87171),
      icon: Icons.receipt_long_outlined,
    ),
  ];

  static const _transactions = [
    TransactionItem(
      title: 'Swiggy Order',
      category: 'Food',
      amount: 500,
      isExpense: true,
      icon: Icons.restaurant_outlined,
      iconColor: Color(0xFF818CF8),
      time: '2h ago',
    ),
    TransactionItem(
      title: 'Metro Card',
      category: 'Travel',
      amount: 200,
      isExpense: true,
      icon: Icons.directions_transit_outlined,
      iconColor: Color(0xFF38BDF8),
      time: '5h ago',
    ),
    TransactionItem(
      title: 'Amazon',
      category: 'Shopping',
      amount: 1000,
      isExpense: true,
      icon: Icons.shopping_bag_outlined,
      iconColor: Color(0xFFFBBF24),
      time: 'Yesterday',
    ),
    TransactionItem(
      title: 'Salary Credit',
      category: 'Income',
      amount: 35000,
      isExpense: false,
      icon: Icons.account_balance_wallet_outlined,
      iconColor: Color(0xFF4ADE80),
      time: '2 days ago',
    ),
  ];

  static final _weeklySpend = [3200.0, 1800.0, 4500.0, 2100.0, 3800.0, 1500.0, 2700.0];
  static const _weekLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];


  @override
  void initState() {
    super.initState();
    _enterAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _enterAnim,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(parent: _enterAnim, curve: Curves.easeOut),
        );
  }

  @override
  void dispose() {
    _enterAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const BgGlow(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DashboardHeader(
                        userName: 'Tanvi',
                        onNotificationTap: () {},
                        onAvatarTap: () {},
                      ),

                      const SizedBox(height: 28),

                      const BalanceCard(
                        totalBalance: 25000,
                        income: 35000,
                        expense: 10000,
                      ),

                      const SizedBox(height: 20),

                      const ExpensePieChart(categories: _categories),

                      const SizedBox(height: 20),

                      MonthlySpendingChart(
                        weeklyData: _weeklySpend,
                        labels: _weekLabels,
                      ),

                      const SizedBox(height: 20),

                      RecentTransactions(
                        transactions: _transactions,
                        onViewAll: () {},
                      ),

                      const SizedBox(height: 20),

                      const BudgetProgress(
                        spent: 10000,
                        total: 15000,
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: _BottomNav(),
    );
  }
}

class _BottomNav extends StatefulWidget {
  @override
  State<_BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<_BottomNav> {
  int _selected = 0;

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.bar_chart_rounded, label: 'Stats'),
    (icon: Icons.add_circle_rounded, label: ''),
    (icon: Icons.receipt_long_outlined, label: 'Bills'),
    (icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.bg,
        border: Border(
          top: BorderSide(
            color: AppColors.muted.withOpacity(0.12),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;

          if (i == 2) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddExpenseScreen(),
                  ),
                );
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            );
          }

          final isSelected = _selected == i;
          return  GestureDetector(
            onTap: () {
              if (i == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatsScreen()),
                );
              } else if (i == 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BillsScreen()),
                );
              } else {
                setState(() => _selected = i);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  size: 22,
                  color: isSelected
                      ? AppColors.accent
                      : AppColors.muted.withOpacity(0.5),
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.accent
                        : AppColors.muted.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}