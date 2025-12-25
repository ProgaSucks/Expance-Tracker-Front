import 'package:flutter/material.dart';
import '../../services/stats.dart';
import '../../services/cats.dart';
import '../../services/trans.dart';
import '../../models/statistics.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';
import 'package:fl_chart/fl_chart.dart';

// Виджет вкладки общей статистики
class SummaryTab extends StatefulWidget {
  final DateTimeRange dateRange;
  final Function(DateTimeRange) onDateRangeChanged;

  const SummaryTab({
    super.key,
    required this.dateRange,
    required this.onDateRangeChanged,
  });

  @override
  State<SummaryTab> createState() => SummaryTabState();
}

class SummaryTabState extends State<SummaryTab> {
  // Переменная для хранения текущего запроса к API
  
  late Future<List<dynamic>> _dataFuture;
  final StatsService _statsService = StatsService();
  final TransactionService _transService = TransactionService();
  final CategoryService _catService = CategoryService();

  @override
  void initState() {
    super.initState();
    _initiateDataFetch();
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
      widget.onDateRangeChanged(picked);
    }
  }

  String _formatDateRange(DateTimeRange range) {
    final start = range.start.toString().split(' ')[0];
    final end = range.end.toString().split(' ')[0];
    return '$start — $end';
  }

  // Метод для инициализации загрузки
  void _initiateDataFetch() {
    _dataFuture = Future.wait([
      _statsService.getSummary(),           // индекс 0
      _transService.getTransactions(),      // индекс 1
      _catService.getCategories(),          // индекс 2
    ]);
  }

  // Обработчик Pull-to-Refresh
  Future<void> refreshData() async {
    setState(() {
      _initiateDataFetch();
    });
    // Ждем завершения, чтобы скрыть индикатор загрузки
    await _dataFuture;
  }

  // --- ЛОГИКА ПОДГОТОВКИ ДАННЫХ ДЛЯ ГРАФИКА ---
  List<PieChartSectionData> _generateChartSections(
    List<Transaction> transactions, 
    List<Category> categories
  ) {
    // 1. Фильтруем по дате (как в Истории)
    final filtered = transactions.where((tx) {
      final txDate = DateTime.parse(tx.date);
      return txDate.isAfter(widget.dateRange.start.subtract(const Duration(seconds: 1))) &&
             txDate.isBefore(widget.dateRange.end.add(const Duration(days: 1)));
    }).toList();

    // 2. Оставляем только РАСХОДЫ
    // Сначала найдем ID категорий расходов
    final expenseCatIds = categories
        .where((c) => c.type == CategoryType.expense)
        .map((c) => c.id)
        .toSet();
        
    final expenses = filtered.where((tx) => expenseCatIds.contains(tx.categoryId)).toList();

    if (expenses.isEmpty) return [];

    // 3. Группируем суммы по ID категории
    final Map<int, double> catTotals = {};
    double totalExpenseSum = 0;

    for (var tx in expenses) {
      catTotals[tx.categoryId] = (catTotals[tx.categoryId] ?? 0) + tx.amount;
      totalExpenseSum += tx.amount;
    }

    // 4. Превращаем в секции для графика
    // Палитра цветов для категорий
    final List<Color> colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, 
      Colors.teal, Colors.pink, Colors.amber, Colors.indigo, Colors.brown
    ];
    
    int colorIndex = 0;

    return catTotals.entries.map((entry) {
      final catId = entry.key;
      final amount = entry.value;
      final category = categories.firstWhere((c) => c.id == catId, 
          orElse: () => Category(id: 0, name: '?', type: CategoryType.expense));
      
      final percentage = (amount / totalExpenseSum * 100).toStringAsFixed(1);
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        color: color,
        value: amount,
        title: '${percentage}%', // На самом графике только проценты
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        // В badge можно запихнуть иконку, но пока оставим просто
      );
    }).toList();
  }

  Widget _buildLegend(List<Transaction> transactions, List<Category> categories) {
    // Повторяем логику фильтрации, чтобы получить те же категории
    // (В реальном коде лучше вынести это в отдельный метод расчета State)
    final filtered = transactions.where((tx) {
      final txDate = DateTime.parse(tx.date);
      return txDate.isAfter(widget.dateRange.start.subtract(const Duration(seconds: 1))) &&
             txDate.isBefore(widget.dateRange.end.add(const Duration(days: 1)));
    }).toList();

    final expenseCatIds = categories
        .where((c) => c.type == CategoryType.expense)
        .map((c) => c.id)
        .toSet();
    final expenses = filtered.where((tx) => expenseCatIds.contains(tx.categoryId)).toList();
    
    if (expenses.isEmpty) return const SizedBox.shrink();

    final Map<int, double> catTotals = {};
    for (var tx in expenses) {
      catTotals[tx.categoryId] = (catTotals[tx.categoryId] ?? 0) + tx.amount;
    }

    final List<Color> colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, 
      Colors.teal, Colors.pink, Colors.amber, Colors.indigo, Colors.brown
    ];
    int colorIndex = 0;

    // Сортируем по убыванию суммы
    final sortedEntries = catTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedEntries.map((entry) {
        final category = categories.firstWhere((c) => c.id == entry.key, 
            orElse: () => Category(id: 0, name: '?', type: CategoryType.expense));
        final color = colors[colorIndex % colors.length];
        colorIndex++;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(width: 16, height: 16, color: color),
              const SizedBox(width: 8),
              Text(category.name),
              const Spacer(),
              Text('${entry.value.toStringAsFixed(0)} ₽', 
                   style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    // Если SummaryTab сам возвращает Scaffold, добавьте сюда:
    appBar: AppBar(
      title: const Text('Обзор'),
      actions: [
        IconButton(
          icon: const Icon(Icons.date_range),
          tooltip: 'Выбрать период',
          onPressed: _selectDateRange,
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Обновить данные',
          onPressed: refreshData, // Тот же метод, что и для Pull-to-Refresh
        ),
      ],
    ),
    body: 
      RefreshIndicator(
        onRefresh: refreshData,
        child: FutureBuilder<List<dynamic>>(
          future: _dataFuture,
          builder: (context, snapshot) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: _buildContent(snapshot),
            );
          },
        ),
    ),
  );
}

  Widget _buildContent(AsyncSnapshot<List<dynamic>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError || !snapshot.hasData) {
      return const Center(child: Text('Не удалось загрузить данные'));
    }

    // Распаковываем данные
    final Statistics? summary = snapshot.data![0]; 
    final List<Transaction> transactions = snapshot.data![1] ?? [];
    final List<Category> categories = snapshot.data![2] ?? [];
    
    // Если статистики нет, показываем ошибку
    if (summary == null) {
        return const Center(child: Text('Нет данных статистики'));
    }
    
    // Генерируем данные для графика
    final chartSections = _generateChartSections(transactions, categories);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMainBalanceCard(summary.balance),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Доходы',
                value: summary.totalIncome,
                color: Colors.green,
                icon: Icons.trending_up,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                label: 'Расходы',
                value: summary.totalExpense,
                color: Colors.red,
                icon: Icons.trending_down,
              ),
            ),
          ],
        ),
        _buildDateRangeCard(label: 'Период: ${_formatDateRange(widget.dateRange)}'),
        const SizedBox(height: 16),
        // Основной контент статистики
        Center(
          child: Column(
            children: [
            // --- ДИАГРАММА РАСХОДОВ ---
            const Text('Структура расходов', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if(chartSections.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: Text('Нет расходов за этот период', style: TextStyle(color: Colors.grey))),
              ) 
            else
              Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: chartSections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Легенда
                  _buildLegend(transactions, categories),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Всего операций: ${summary.transactionsCount}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  // Виджет главной карточки баланса
  Widget _buildMainBalanceCard(double balanceValue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.indigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Общий баланс',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${balanceValue.toStringAsFixed(2)} ₽',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Виджет маленьких карточек (Доход/Расход)
  Widget _buildStatCard({
    required String label,
    required double value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                '${value.toStringAsFixed(1)} ₽',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Виджет даты
  Widget _buildDateRangeCard({
    required String label,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Период: ${_formatDateRange(widget.dateRange)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ],
          ),
      ),
    );
  }
}