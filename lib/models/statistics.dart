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
    return Statistics(
      totalIncome: (json['total_income'] as num).toDouble(),
      totalExpense: (json['total_expense'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      transactionsCount: json['transactions_count'] as int,
    );
  }
}