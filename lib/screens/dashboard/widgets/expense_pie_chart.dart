import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ExpenseCategory {
  final String label;
  final double percentage;
  final Color color;
  final IconData icon;

  const ExpenseCategory({
    required this.label,
    required this.percentage,
    required this.color,
    required this.icon,
  });
}

class ExpensePieChart extends StatelessWidget {
  final List<ExpenseCategory> categories;

  const ExpensePieChart({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Expense Categories',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Pie chart
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: _PieChartPainter(categories),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${categories.length}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cream,
                      ),
                    ),
                    Text(
                      'types',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Legend
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categories
                  .map((cat) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _LegendItem(category: cat),
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final ExpenseCategory category;
  const _LegendItem({required this.category});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: category.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Icon(category.icon, size: 13, color: AppColors.muted),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            category.label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
        ),
        Text(
          '${category.percentage.toInt()}%',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.cream,
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<ExpenseCategory> categories;
  _PieChartPainter(this.categories);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.62;

    double startAngle = -math.pi / 2;

    for (final cat in categories) {
      final sweepAngle = 2 * math.pi * (cat.percentage / 100);
      final paint = Paint()
        ..color = cat.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = outerRadius - innerRadius
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(
            center: center, radius: (outerRadius + innerRadius) / 2),
        startAngle,
        sweepAngle - 0.04, // small gap between segments
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Shared section card ────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.muted.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.muted.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}