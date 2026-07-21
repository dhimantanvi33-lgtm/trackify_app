import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trackify/core/constants/app_colors.dart';
import 'package:trackify/model/bill_model.dart';
import 'package:trackify/provider/bill_provider.dart';
import 'package:trackify/screens/auth/widgets/bg_glow.dart';
import 'package:trackify/screens/dashboard/bills/add_bills.dart';
import 'package:trackify/screens/dashboard/bills/bill_category.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enterAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  int _filterIndex = 0;

  static const _filters = ['All', 'Upcoming', 'Paid'];

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BillProvider>().startListening();
    });
  }

  @override
  void dispose() {
    _enterAnim.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillProvider>();
    final filtered = provider.billsForFilter(_filterIndex);

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
                      Row(
                        children: [
                          const Text(
                            'Bills',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cream,
                            ),
                          ),
                          const Spacer(),
                          _IconBtn(
                            icon: Icons.add_rounded,
                            onTap: () async {
                              final added = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const AddBillScreen()),
                              );
                              if (added == true && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Bill added')),
                                );
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Summary card ─────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accent.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Due This Month',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.muted.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '₹${provider.totalDue.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.cream,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _StatusPill(
                                  label: '${provider.paidCount} Paid',
                                  color: const Color(0xFF4ADE80),
                                ),
                                const SizedBox(width: 8),
                                _StatusPill(
                                  label: '${provider.dueCount} Due',
                                  color: const Color(0xFFFBBF24),
                                ),
                                const SizedBox(width: 8),
                                _StatusPill(
                                  label: '${provider.overdueCount} Overdue',
                                  color: const Color(0xFFF87171),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── Filter tabs ──────────────────────────────────
                      _FilterToggle(
                        labels: _filters,
                        selected: _filterIndex,
                        onChanged: (i) => setState(() => _filterIndex = i),
                      ),

                      const SizedBox(height: 20),

                      // ── Bills list ───────────────────────────────────
                      if (provider.isLoading && provider.bills.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                            ),
                          ),
                        )
                      else if (provider.errorMessage != null &&
                          provider.bills.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              provider.errorMessage!,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.muted.withOpacity(0.7),
                              ),
                            ),
                          ),
                        )
                      else if (filtered.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long_outlined,
                                      size: 36,
                                      color: AppColors.muted.withOpacity(0.35)),
                                  const SizedBox(height: 10),
                                  Text(
                                    'No bills here',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      color: AppColors.muted.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Column(
                            children: [
                              for (final bill in filtered) ...[
                                _BillCard(
                                  bill: bill,
                                  dateLabel: _formatDate(bill.dueDate),
                                  onToggle: () => provider.togglePaid(bill),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ],
                          ),

                      const SizedBox(height: 16),
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

class _FilterToggle extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  const _FilterToggle({
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

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  final Bill bill;
  final String dateLabel;
  final VoidCallback onToggle;

  const _BillCard({
    required this.bill,
    required this.dateLabel,
    required this.onToggle,
  });

  (Color, String) _statusMeta() {
    switch (bill.status) {
      case BillStatus.paid:
        return (const Color(0xFF4ADE80), 'Paid');
      case BillStatus.due:
        return (const Color(0xFFFBBF24), 'Due');
      case BillStatus.overdue:
        return (const Color(0xFFF87171), 'Overdue');
    }
  }

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusLabel) = _statusMeta();
    final isPaid = bill.status == BillStatus.paid;
    final categoryMeta = BillCategories.of(bill.category);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.muted.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.muted.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: categoryMeta.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(categoryMeta.icon, size: 20, color: categoryMeta.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        bill.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cream,
                        ),
                      ),
                    ),
                    if (bill.isRecurring) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.autorenew_rounded,
                          size: 13, color: AppColors.muted.withOpacity(0.5)),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${bill.category} • Due $dateLabel',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: AppColors.muted.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${bill.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPaid
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 12,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
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
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}