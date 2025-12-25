import 'package:flutter/material.dart';
import '../../services/trans.dart';
import '../../models/transaction.dart';
import '../../services/cats.dart';
import '../../models/category.dart';
import '../transaction/add_trans.dart';
import '../transaction/edit_trans.dart';

// Создаем виджет HistoryTab
class HistoryTab extends StatefulWidget {
  final DateTimeRange dateRange;
  final Function(DateTimeRange) onDateRangeChanged;

  const HistoryTab({super.key, 
    required this.dateRange,
    required this.onDateRangeChanged,});

  @override
  State<HistoryTab> createState() => HistoryTabState();
}

class HistoryTabState extends State<HistoryTab> {
  late Future<List<dynamic>> _historyData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Метод для инициализации/сброса данных
  void _loadData() {
    _historyData = Future.wait([
      TransactionService().getTransactions(),
      CategoryService().getCategories(),
    ]);
  }

  // Функция, которую вызовет RefreshIndicator
  Future<void> refreshData() async {
    setState(() {
      _loadData(); // Пересоздаем Future, что инициирует новый запрос
    });
    await _historyData; // Ждем завершения загрузки, чтобы индикатор исчез
  }

  Map<String, List<Transaction>> _groupTransactions(List<Transaction> transactions) {
  // Фильтруем список по выбранному диапазону
  final filteredTransactions = transactions.where((tx) {
    final txDate = DateTime.parse(tx.date);
    // Проверяем, входит ли дата в интервал (с учетом времени)
    return txDate.isAfter(widget.dateRange.start.subtract(const Duration(seconds: 1))) &&
           txDate.isBefore(widget.dateRange.end.add(const Duration(days: 1)));
  }).toList();

  // Сортируем
  filteredTransactions.sort((a, b) => b.date.compareTo(a.date));

  final groups = <String, List<Transaction>>{};
  for (var tx in filteredTransactions) {
    final date = tx.date.split('T')[0];
    groups.putIfAbsent(date, () => []).add(tx);
  }
  return groups;
}

  Future<void> _selectDateRange() async {
  final DateTimeRange? picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    initialDateRange: widget.dateRange,
    helpText: 'Выберите период',
  );

  if (picked != null && picked != widget.dateRange) {
    setState(() {
      widget.onDateRangeChanged(picked);
    });
  }
}

// Метод для превращения DateTimeRange в красивую строку "YYYY-MM-DD — YYYY-MM-DD"
String _formatDateRange(DateTimeRange range) {
  final start = range.start.toString().split(' ')[0];
  final end = range.end.toString().split(' ')[0];
  return '$start — $end';
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История операций'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'Выбрать период',
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshData,
          ),
        ],
      ),
      // Используем Column для размещения заголовка над списком
      body: Column(
        children: [
          // --- ПЛАШКА С ПЕРИОДОМ ---
          Container(
            width: double.infinity,
            color: Colors.grey[200], // Легкий серый фон
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Период: ${_formatDateRange(widget.dateRange)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // --- СПИСОК ТРАНЗАКЦИЙ ---
          // Оборачиваем в Expanded, чтобы список занимал все оставшееся место
          Expanded(
            child: RefreshIndicator(
              onRefresh: refreshData,
              child: FutureBuilder(
                future: _historyData,
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data![0].isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 100),
                        Center(child: Text('Транзакций пока нет. Потяните вниз для обновления.')),
                      ],
                    );
                  }

                  final List<Transaction> transactions = snapshot.data![0];
                  final List<Category> categories = snapshot.data![1];

                  final groupedTransactions = _groupTransactions(transactions);

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    // Убираем padding сверху, чтобы не было дырки между плашкой и списком
                    padding: const EdgeInsets.only(bottom: 80), 
                    children: groupedTransactions.entries.expand((entry) {
                      final date = entry.key;
                      final txList = entry.value;

                      return [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            date,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                          ),
                        ),
                        ...txList.map((tx) {
                          final category = categories.firstWhere(
                            (c) => c.id == tx.categoryId,
                            orElse: () => Category(id: 0, name: '?', type: CategoryType.expense),
                          );
                          final bool isIncome = category.type == CategoryType.income;

                          return ListTile(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditTransactionScreen(transaction: tx)),
                              );
                              if (result == true) refreshData();
                            },
                            leading: CircleAvatar(
                              backgroundColor: isIncome
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              child: Icon(
                                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                                color: isIncome ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(tx.description.isEmpty ? category.name : tx.description),
                            trailing: Text(
                              '${isIncome ? "+" : "-"}${tx.amount} ₽',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isIncome ? Colors.green : Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          );
                        }),
                      ];
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'history_add_button',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
          if (result == true) refreshData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}