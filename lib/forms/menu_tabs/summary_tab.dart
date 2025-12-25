import 'package:flutter/material.dart';
import '../../services/stats.dart';
import '../../models/statistics.dart';


// Виджет вкладки общей статистики
class SummaryTab extends StatefulWidget {
  const SummaryTab({super.key});

  @override
  State<SummaryTab> createState() => SummaryTabState();
}

class SummaryTabState extends State<SummaryTab> {
  // Переменная для хранения текущего запроса к API
  late Future<Statistics?> _activeStatsRequest;
  final StatsService _apiService = StatsService();

  @override
  void initState() {
    super.initState();
    _initiateDataFetch();
  }

  // Метод для инициализации загрузки
  void _initiateDataFetch() {
    _activeStatsRequest = _apiService.getSummary();
  }

  // Обработчик Pull-to-Refresh
  Future<void> refreshData() async {
    setState(() {
      _initiateDataFetch();
    });
    // Ждем завершения, чтобы скрыть индикатор загрузки
    await _activeStatsRequest;
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    // Если SummaryTab сам возвращает Scaffold, добавьте сюда:
    appBar: AppBar(
      title: const Text('Обзор'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'Обновить данные',
          onPressed: refreshData, // Тот же метод, что и для Pull-to-Refresh
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: refreshData,
      child: FutureBuilder<Statistics?>(
        future: _activeStatsRequest,
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

  Widget _buildContent(AsyncSnapshot<Statistics?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (snapshot.hasError || snapshot.data == null) {
      return const SizedBox(
        height: 300,
        child: Center(child: Text('Не удалось загрузить сводку')),
      );
    }

    final summary = snapshot.data!;

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
}