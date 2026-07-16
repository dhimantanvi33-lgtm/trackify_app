import 'package:flutter/material.dart';
import 'package:trackify/core/constants/app_colors.dart';
import 'package:trackify/features/auth/widgets/bg_glow.dart';
import 'package:trackify/features/dashboard/widgets/bidget_progress.dart';
import 'package:trackify/features/dashboard/widgets/expense_pie_chart.dart';
import 'package:trackify/features/dashboard/widgets/spending_line_chart.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  int _periodIndex = 1; // 0 = Week, 1 = Month, 2 = Year

  static const _periods = ['Week', 'Month', 'Year'];

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

  static const _breakdown = [
    _CategoryStat(
      label: 'Food',
      amount: 4000,
      percentage: 0.40,
      color: Color(0xFF818CF8),
      icon: Icons.restaurant_outlined,
    ),
    _CategoryStat(
      label: 'Travel',
      amount: 2500,
      percentage: 0.25,
      color: Color(0xFF38BDF8),
      icon: Icons.directions_transit_outlined,
    ),
    _CategoryStat(
      label: 'Shopping',
      amount: 2000,
      percentage: 0.20,
      color: Color(0xFFFBBF24),
      icon: Icons.shopping_bag_outlined,
    ),
    _CategoryStat(
      label: 'Bills',
      amount: 1500,
      percentage: 0.15,
      color: Color(0xFFF87171),
      icon: Icons.receipt_long_outlined,
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ─────────────────────────────────────
                      Row(
                        children: [
                          const Text(
                            'Statistics',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cream,
                            ),
                          ),
                          const Spacer(),
                          _IconBtn(
                            icon: Icons.calendar_today_outlined,
                            onTap: () {},
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Period toggle ───────────────────────────────
                      _PeriodToggle(
                        labels: _periods,
                        selected: _periodIndex,
                        onChanged: (i) => setState(() => _periodIndex = i),
                      ),

                      const SizedBox(height: 20),

                      // ── Summary cards ────────────────────────────────
                      Row(
                        children: const [
                          Expanded(
                            child: _SummaryCard(
                              label: 'Total Spent',
                              amount: 10000,
                              icon: Icons.arrow_upward_rounded,
                              color: Color(0xFFF87171),
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: _SummaryCard(
                              label: 'Total Income',
                              amount: 35000,
                              icon: Icons.arrow_downward_rounded,
                              color: Color(0xFF4ADE80),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      const ExpensePieChart(categories: _categories),

                      const SizedBox(height: 20),

                      MonthlySpendingChart(
                        weeklyData: _weeklySpend,
                        labels: _weekLabels,
                      ),

                      const SizedBox(height: 24),

                      const _SectionLabel(label: 'Category Breakdown'),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.muted.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.muted.withOpacity(0.12),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            for (int i = 0; i < _breakdown.length; i++) ...[
                              _CategoryStatRow(stat: _breakdown[i]),
                              if (i != _breakdown.length - 1)
                                const SizedBox(height: 16),
                            ],
                          ],
                        ),
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
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────

class _CategoryStat {
  final String label;
  final double amount;
  final double percentage;
  final Color color;
  final IconData icon;

  const _CategoryStat({
    required this.label,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.icon,
  });
}

class _PeriodToggle extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  const _PeriodToggle({
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.muted.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border:
        Border.all(color: AppColors.muted.withOpacity(0.15), width: 1),
      ),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected == i
                        ? AppColors.accent.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: selected == i
                        ? Border.all(
                        color: AppColors.accent.withOpacity(0.35),
                        width: 1)
                        : null,
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight:
                      selected == i ? FontWeight.w700 : FontWeight.w500,
                      color: selected == i
                          ? AppColors.accent
                          : AppColors.muted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.muted.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.cream,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryStatRow extends StatelessWidget {
  final _CategoryStat stat;
  const _CategoryStatRow({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: stat.color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(stat.icon, size: 17, color: stat.color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    stat.label,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cream,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₹${stat.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: stat.percentage,
                  minHeight: 6,
                  backgroundColor: AppColors.muted.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(stat.color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.muted.withOpacity(0.7),
        letterSpacing: 0.5,
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.muted.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border:
          Border.all(color: AppColors.muted.withOpacity(0.15), width: 1),
        ),
        child: Icon(icon, size: 18, color: AppColors.muted),
      ),
    );
  }
}