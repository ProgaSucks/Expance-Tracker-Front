enum TransactionType { income, expense }

class Transaction {
  final int id;
  final double amount;
  final String description;
  final TransactionType type;
  final String date;
  final int categoryId;

  Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.type,
    required this.date,
    required this.categoryId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      // Безопасный парсинг Decimal из строки
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      description: json['description'] ?? '',
      // Преобразуем строку 'income'/'expense' в enum
      type: json['type'].toString().toLowerCase() == 'income' ? TransactionType.income : TransactionType.expense,
      date: json['date'],
      categoryId: json['category_id'],
    );
  }
}