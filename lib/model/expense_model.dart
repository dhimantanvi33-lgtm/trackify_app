class ExpenseModel {
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;
  final bool isExpense;

  const ExpenseModel({
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    required this.isExpense,
  });
}
 