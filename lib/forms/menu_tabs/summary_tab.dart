import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/cats.dart';
import '../../services/trans.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';

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
  // Теперь храним список из [List<Transaction>, List<Category>]
  late Future<List<dynamic>> _dataFuture;
  
  final TransactionService _transService = TransactionService();
  final CategoryService _catService = CategoryService();
  // StatsService больше не нужен для загрузки summary

  @override
  void initState() {
    super.initState();
    _initiateDataFetch();
  }

  @override
  void didUpdateWidget(covariant SummaryTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dateRange != widget.dateRange) {
      // Если дата изменилась, нам достаточно перестроить UI (setState), 
      // так как транзакции у нас уже загружены все. 
      // Но если вы хотите обновлять данные с сервера при смене даты, оставьте refreshData().
      // Для простоты оставим обновление:
      refreshData();
    }
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

  void _initiateDataFetch() {
    // Загружаем только транзакции и категории
    _dataFuture = Future.wait([
      _transService.getTransactions(),      // индекс 0
      _catService.getCategories(),          // индекс 1
    ]);
  }

  Future<void> refreshData() async {
    setState(() {
      _initiateDataFetch();
    });
    await _dataFuture;
  }

  // --- МЕТОДЫ ПОСТРОЕНИЯ ГРАФИКОВ ---
  // Теперь принимают уже отфильтрованный список и Map категорий для скорости
  List<PieChartSectionData> _generateChartSections(
    List<Transaction> transactions,
    Map<int, Category> categoryMap,
    CategoryType type, 
  ) {
    // 1. Оставляем только нужный тип (Доход/Расход)
    final targetTransactions = transactions.where((tx) {
      final cat = categoryMap[tx.categoryId];
      return cat != null && cat.type == type;
    }).toList();

    if (targetTransactions.isEmpty) return [];

    // 2. Группируем суммы
    final Map<int, double> catTotals = {};
    double totalSum = 0;

    for (var tx in targetTransactions) {
      catTotals[tx.categoryId] = (catTotals[tx.categoryId] ?? 0) + tx.amount;
      totalSum += tx.amount;
    }

    // 3. Цвета
    final List<Color> colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple,
      Colors.teal, Colors.pink, Colors.amber, Colors.indigo, Colors.brown
    ];
    int colorIndex = 0;

    return catTotals.entries.map((entry) {
      final catId = entry.key;
      final amount = entry.value;
      final category = categoryMap[catId] ?? Category(id: 0, name: '?', type: type);
      final percentage = (amount / totalSum * 100).toStringAsFixed(1);
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        color: color,
        value: amount,
        title: '$percentage%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  Widget _buildLegend(
    List<Transaction> transactions, 
    Map<int, Category> categoryMap,
    CategoryType type
  ) {
    final targetTransactions = transactions.where((tx) {
      final cat = categoryMap[tx.categoryId];
      return cat != null && cat.type == type;
    }).toList();

    if (targetTransactions.isEmpty) return const SizedBox.shrink();

    final Map<int, double> catTotals = {};
    for (var tx in targetTransactions) {
      catTotals[tx.categoryId] = (catTotals[tx.categoryId] ?? 0) + tx.amount;
    }

    final List<Color> colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple,
      Colors.teal, Colors.pink, Colors.amber, Colors.indigo, Colors.brown
    ];
    int colorIndex = 0;

    final sortedEntries = catTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedEntries.map((entry) {
        final category = categoryMap[entry.key] ?? Category(id: 0, name: '?', type: type);
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

  Widget _buildChartBlock({
    required String title,
    required List<PieChartSectionData> sections,
    required List<Transaction> filteredTransactions,
    required Map<int, Category> categoryMap,
    required CategoryType type,
  }) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (sections.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: Text('Нет операций за этот период', style: TextStyle(color: Colors.grey))),
          )
        else
          Column(
            children: [
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildLegend(filteredTransactions, categoryMap, type),
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            onPressed: refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
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
      return const SizedBox(
        height: 300, 
        child: Center(child: CircularProgressIndicator())
      );
    }

    if (snapshot.hasError || !snapshot.hasData) {
      return const SizedBox(
        height: 300, 
        child: Center(child: Text('Не удалось загрузить данные'))
      );
    }

    // Распаковываем данные (внимание на индексы, они сдвинулись)
    final List<Transaction> transactions = snapshot.data![0] ?? [];
    final List<Category> categories = snapshot.data![1] ?? [];

    // --- 1. ПРЕДВАРИТЕЛЬНАЯ ОБРАБОТКА ДАННЫХ ---
    
    // Создаем Map для быстрого поиска категории по ID (оптимизация)
    final Map<int, Category> categoryMap = {
      for (var c in categories) c.id: c
    };

    // Фильтруем транзакции по дате ОДИН раз
    final filteredTransactions = transactions.where((tx) {
      final txDate = DateTime.parse(tx.date);
      return txDate.isAfter(widget.dateRange.start.subtract(const Duration(seconds: 1))) &&
             txDate.isBefore(widget.dateRange.end.add(const Duration(days: 1)));
    }).toList();

    // --- 2. РАСЧЕТ СТАТИСТИКИ (Balance, Income, Expense) ---
    double totalIncome = 0;
    double totalExpense = 0;

    for (var tx in filteredTransactions) {
      final category = categoryMap[tx.categoryId];
      if (category != null) {
        if (category.type == CategoryType.income) {
          totalIncome += tx.amount;
        } else {
          totalExpense += tx.amount;
        }
      }
    }
    
    final balance = totalIncome - totalExpense;
    final transactionsCount = filteredTransactions.length;

    // --- 3. ГЕНЕРАЦИЯ ДАННЫХ ДЛЯ ГРАФИКОВ ---
    // Передаем уже отфильтрованный список, чтобы не делать это снова
    final incomeSections = _generateChartSections(filteredTransactions, categoryMap, CategoryType.income);
    final expenseSections = _generateChartSections(filteredTransactions, categoryMap, CategoryType.expense);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Карточки теперь используют рассчитанные нами значения
        _buildMainBalanceCard(balance),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Доходы',
                value: totalIncome,
                color: Colors.green,
                icon: Icons.trending_up,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                label: 'Расходы',
                value: totalExpense,
                color: Colors.red,
                icon: Icons.trending_down,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDateRangeCard(label: 'Период: ${_formatDateRange(widget.dateRange)}'),
        
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // --- БЛОК ДОХОДОВ ---
        Center(
          child: _buildChartBlock(
            title: 'Структура доходов',
            sections: incomeSections,
            filteredTransactions: filteredTransactions,
            categoryMap: categoryMap,
            type: CategoryType.income,
          ),
        ),

        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 16),

        // --- БЛОК РАСХОДОВ ---
        Center(
          child: _buildChartBlock(
            title: 'Структура расходов',
            sections: expenseSections,
            filteredTransactions: filteredTransactions,
            categoryMap: categoryMap,
            type: CategoryType.expense,
          ),
        ),

        const SizedBox(height: 24),
        Text(
          'Всего операций: $transactionsCount',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  // --- UI КОМПОНЕНТЫ ---
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
            'Баланс за период', // Изменили заголовок, чтобы было понятнее
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

  Widget _buildDateRangeCard({required String label}) {
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
                label.replaceFirst('Период: ', ''),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
      ),
    );
  }
}