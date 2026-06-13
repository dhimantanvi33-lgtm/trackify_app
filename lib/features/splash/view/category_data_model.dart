import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CategoryData {
  final String name;
  final IconData icon;
  final Color color;
  final double startAngle; // degrees
  final double sweepAngle; // degrees

  const CategoryData({
    required this.name,
    required this.icon,
    required this.color,
    required this.startAngle,
    required this.sweepAngle,
  });
}

const List<CategoryData> kCategories = [
  CategoryData(name: 'Food',     icon: Icons.restaurant,      color: Color(0xFF4CAF7D), startAngle: 0,   sweepAngle: 72),
  CategoryData(name: 'Home',     icon: Icons.home_rounded,    color: Color(0xFFF5A623), startAngle: 72,  sweepAngle: 72),
  CategoryData(name: 'Travel',   icon: Icons.flight_rounded,  color: Color(0xFFFF6B6B), startAngle: 144, sweepAngle: 72),
  CategoryData(name: 'Health',   icon: Icons.favorite_rounded,color: Color(0xFF5B8DEF), startAngle: 216, sweepAngle: 52),
  CategoryData(name: 'Shopping', icon: Icons.shopping_bag_rounded, color: Color(0xFFC96FE0), startAngle: 268, sweepAngle: 48),
  CategoryData(name: 'Bills',    icon: Icons.receipt_long_rounded, color: Color(0xFFFF9F43), startAngle: 316, sweepAngle: 44),
];