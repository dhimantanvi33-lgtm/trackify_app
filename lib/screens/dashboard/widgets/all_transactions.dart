import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackify/core/constants/app_colors.dart';
import 'package:trackify/provider/dashboard_provider.dart';
import 'package:trackify/screens/auth/widgets/bg_glow.dart';
import 'package:trackify/screens/dashboard/widgets/rescent_transactions.dart';

class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  int _filterIndex = 0; // 0 = All, 1 = Income, 2 = Expense
  static const _filters = ['All', 'Income', 'Expense'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TransactionItem> _applyFilters(List<TransactionItem> items) {
    var result = items;

    if (_filterIndex == 1) {
      result = result.where((t) => !t.isExpense).toList();
    } else if (_filterIndex == 2) {
      result = result.where((t) => t.isExpense).toList();
    }

    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      result = result
          .where((t) =>
      t.title.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q))
          .toList();
    }

    return result;
  }

  String _dateHeader(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(d.year, d.month, d.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${that.day} ${months[that.month - 1]} ${that.year}';
  }

  List<(String, List<TransactionItem>)> _groupByDay(
      List<TransactionItem> items) {
    final groups = <(String, List<TransactionItem>)>[];
    for (final item in items) {
      final header = _dateHeader(item.date);
      if (groups.isNotEmpty && groups.last.$1 == header) {
        groups.last.$2.add(item);
      } else {
        groups.add((header, [item]));
      }
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final filtered = _applyFilters(dashboard.allTransactions);
    final groups = _groupByDay(filtered);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const BgGlow(),
          SafeArea(
            child: Column(
              children: [
                // ── Header ─────────────────────────────────────
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.muted.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.muted.withOpacity(0.15),
                                width: 1),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18, color: AppColors.muted),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'All Transactions',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cream,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // ── Search ─────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded,
                                size: 18,
                                color: AppColors.muted.withOpacity(0.6)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: AppColors.cream,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search transactions',
                                  hintStyle: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    color: AppColors.muted.withOpacity(0.4),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onChanged: (v) => setState(() => _query = v),
                              ),
                            ),
                            if (_query.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchCtrl.clear();
                                  setState(() => _query = '');
                                },
                                child: Icon(Icons.close_rounded,
                                    size: 16,
                                    color: AppColors.muted.withOpacity(0.6)),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Filter tabs ──────────────────────────────
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.muted.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.muted.withOpacity(0.15),
                              width: 1),
                        ),
                        child: Row(
                          children: [
                            for (int i = 0; i < _filters.length; i++)
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _filterIndex = i),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.all(4),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: _filterIndex == i
                                          ? AppColors.accent.withOpacity(0.15)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: _filterIndex == i
                                          ? Border.all(
                                          color: AppColors.accent
                                              .withOpacity(0.35),
                                          width: 1)
                                          : null,
                                    ),
                                    child: Text(
                                      _filters[i],
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        fontWeight: _filterIndex == i
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: _filterIndex == i
                                            ? AppColors.accent
                                            : AppColors.muted,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── List ───────────────────────────────────────────
                Expanded(
                  child: dashboard.isLoading && dashboard.allTransactions.isEmpty
                      ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                      : groups.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 36,
                            color: AppColors.muted.withOpacity(0.35)),
                        const SizedBox(height: 10),
                        Text(
                          'No transactions found',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.muted.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: groups.length,
                    itemBuilder: (context, groupIndex) {
                      final (header, items) = groups[groupIndex];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 10, left: 4),
                              child: Text(
                                header,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.muted.withOpacity(0.7),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.muted.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColors.muted.withOpacity(0.12),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  for (int i = 0; i < items.length; i++) ...[
                                    TransactionRow(item: items[i]),
                                    if (i < items.length - 1)
                                      Divider(
                                        color: AppColors.muted.withOpacity(0.1),
                                        height: 20,
                                        thickness: 1,
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}