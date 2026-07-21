import 'package:cloud_firestore/cloud_firestore.dart';

enum BillStatus { paid, due, overdue }

class Bill {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime dueDate;
  final bool isRecurring;
  final bool isPaid;

  const Bill({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.dueDate,
    required this.isRecurring,
    required this.isPaid,
  });

  BillStatus get status {
    if (isPaid) return BillStatus.paid;
    if (dueDate.isBefore(DateTime.now())) return BillStatus.overdue;
    return BillStatus.due;
  }

  Bill copyWith({
    String? id,
    String? title,
    String? category,
    double? amount,
    DateTime? dueDate,
    bool? isRecurring,
    bool? isPaid,
  }) {
    return Bill(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isRecurring: isRecurring ?? this.isRecurring,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  factory Bill.fromMap(String id, Map<String, dynamic> data) {
    return Bill(
      id: id,
      title: data['title'] as String? ?? '',
      category: data['category'] as String? ?? 'Other',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRecurring: data['isRecurring'] as bool? ?? false,
      isPaid: data['isPaid'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'isRecurring': isRecurring,
      'isPaid': isPaid,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}