import 'package:flutter/material.dart';

class BillCategory {
  final String label;
  final IconData icon;
  final Color color;
  const BillCategory(this.label, this.icon, this.color);
}

class BillCategories {
  BillCategories._();

  static const List<BillCategory> all = [
    BillCategory('Housing', Icons.house_outlined, Color(0xFF818CF8)),
    BillCategory('Utilities', Icons.bolt_outlined, Color(0xFFFBBF24)),
    BillCategory('Internet', Icons.wifi_rounded, Color(0xFF38BDF8)),
    BillCategory('Entertainment', Icons.movie_outlined, Color(0xFFA78BFA)),
    BillCategory(
        'Insurance', Icons.favorite_outline_rounded, Color(0xFFF472B6)),
    BillCategory(
        'Loan', Icons.directions_car_filled_outlined, Color(0xFFF87171)),
    BillCategory('Other', Icons.receipt_long_outlined, Color(0xFF4ADE80)),
  ];

  static BillCategory of(String label) {
    return all.firstWhere(
          (c) => c.label == label,
      orElse: () => all.last,
    );
  }
}