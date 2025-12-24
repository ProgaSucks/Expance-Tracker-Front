class Statistics {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int transactionsCount;

  Statistics({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionsCount,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    // Функция-помощник для парсинга, так как бэкенд шлет строки
    double parseDouble(dynamic value) {
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return (value as num?)?.toDouble() ?? 0.0;
    }

    return Statistics(
      totalIncome: parseDouble(json['total_income']),
      totalExpense: parseDouble(json['total_expense']),
      balance: parseDouble(json['balance']),
      transactionsCount: json['transactions_count'] as int? ?? 0,
    );
  }
}