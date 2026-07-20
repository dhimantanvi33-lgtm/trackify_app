import 'package:flutter/material.dart';

class CategoryMeta {
  final IconData icon;
  final Color color;
  const CategoryMeta(this.icon, this.color);
}

const Map<String, CategoryMeta> categoryMetaMap = {
  'Food': CategoryMeta(Icons.restaurant_outlined, Color(0xFF818CF8)),
  'Travel': CategoryMeta(Icons.directions_transit_outlined, Color(0xFF38BDF8)),
  'Shopping': CategoryMeta(Icons.shopping_bag_outlined, Color(0xFFFBBF24)),
  'Bills': CategoryMeta(Icons.receipt_long_outlined, Color(0xFFF87171)),
  'Health': CategoryMeta(Icons.favorite_outline_rounded, Color(0xFFF472B6)),
  'Entertainment': CategoryMeta(Icons.movie_outlined, Color(0xFFA78BFA)),
  'Education': CategoryMeta(Icons.school_outlined, Color(0xFF34D399)),
  'Income': CategoryMeta(
      Icons.account_balance_wallet_outlined, Color(0xFF4ADE80)),
  'Other': CategoryMeta(Icons.more_horiz_rounded, Color(0xFF94A3B8)),
};

CategoryMeta metaFor(String category) =>
    categoryMetaMap[category] ?? categoryMetaMap['Other']!;