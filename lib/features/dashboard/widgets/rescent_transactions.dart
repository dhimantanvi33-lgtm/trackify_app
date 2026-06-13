import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TransactionItem {
  final String title;
  final String category;
  final double amount;
  final bool isExpense;
  final IconData icon;
  final Color iconColor;
  final String time;

  const TransactionItem({
    required this.title,
    required this.category,
    required this.amount,
    required this.isExpense,
    required this.icon,
    required this.iconColor,
    required this.time,
  });
}

class RecentTransactions extends StatelessWidget {
  final List<TransactionItem> transactions;
  final VoidCallback? onViewAll;

  const RecentTransactions({
    super.key,
    required this.transactions,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.muted.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.muted.withOpacity(0.12), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.cream,
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'View all',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...transactions.asMap().entries.map((entry) {
            final i = entry.key;
            final tx = entry.value;
            return Column(
              children: [
                _TransactionRow(item: tx),
                if (i < transactions.length - 1)
                  Divider(
                    color: AppColors.muted.withOpacity(0.1),
                    height: 20,
                    thickness: 1,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final TransactionItem item;
  const _TransactionRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: item.iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(item.icon, color: item.iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        // Title + category
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.category} · ${item.time}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        // Amount
        Text(
          '${item.isExpense ? '-' : '+'}₹${item.amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: item.isExpense
                ? const Color(0xFFF87171)
                : const Color(0xFF4ADE80),
          ),
        ),
      ],
    );
  }
}