import 'package:flutter/material.dart';
import '../services/stats.dart';
import '../models/statistics.dart';
import '../services/trans.dart';
import '../models/transaction.dart';
import '../services/cats.dart';
import '../models/category.dart';
import 'transaction/add_trans.dart';
import 'transaction/edit_trans.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Индекс текущей вкладки
  
  // Список виджетов для вкладок
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const SummaryTab(), // Наша первая вкладка
      const HistoryTab(), // Заменили заглушку
      const CategoriesTab(), // Наш новый виджет
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Обзор'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'История'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Категории'),
        ],
      ),
    );
  }
}

// Виджет вкладки общей статистики
class SummaryTab extends StatelessWidget {
  const SummaryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final statsService = StatsService();

    return Scaffold(
      appBar: AppBar(title: const Text('Мои Финансы')),
      body: FutureBuilder(
        future: Future.wait([statsService.getUserEmail(), statsService.getSummary()]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data![1] == null) {
            return const Center(child: Text('Ошибка загрузки данных'));
          }

          String email = snapshot.data![0] ?? "Пользователь";
          Statistics stats = snapshot.data![1];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Привет, $email', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 20),
                _buildStatCard('Баланс', '${stats.balance} ₽', Colors.blue),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Доходы', '${stats.totalIncome} ₽', Colors.green)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('Расходы', '${stats.totalExpense} ₽', Colors.red)),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Всего операций: ${stats.transactionsCount}'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// Создаем виджет HistoryTab
class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final txService = TransactionService();
    final catService = CategoryService();

    return Scaffold(
      appBar: AppBar(title: const Text('История операций')),
      body: FutureBuilder(
        // Загружаем оба списка параллельно
        future: Future.wait([
          txService.getTransactions(),
          catService.getCategories(),
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Ошибка загрузки данных'));
          }

          final List<Transaction> transactions = snapshot.data![0];
          final List<Category> categories = snapshot.data![1];

          if (transactions.isEmpty) {
            return const Center(child: Text('Транзакций пока нет'));
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              
              // Находим категорию для этой транзакции
              final category = categories.firstWhere(
                (c) => c.id == tx.categoryId,
                orElse: () => Category(id: 0, name: '?', type: CategoryType.expense),
              );

              // Теперь тип берем из найденной категории!
              final bool isIncome = category.type == CategoryType.income;

              return ListTile(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditTransactionScreen(transaction: tx)),
                  );
                  if (result == true) (context as Element).markNeedsBuild();
                },
                leading: CircleAvatar(
                  backgroundColor: isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  child: Icon(
                    isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(tx.description.isEmpty ? category.name : tx.description),
                subtitle: Text(tx.date.split('T')[0]),
                trailing: Text(
                  '${isIncome ? "+" : "-"}${tx.amount} ₽',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isIncome ? Colors.green : Colors.red,
                    fontSize: 16,
                  ),
                ),
              );
            },
          );
        },
      ),
      // ... ваш FloatingActionButton ...
    );
  }
}


// Создаем сам виджет CategoriesTab
class CategoriesTab extends StatelessWidget {
  const CategoriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final service = CategoryService();

    return Scaffold(
      appBar: AppBar(title: const Text('Категории')),
      body: FutureBuilder<List<Category>>(
        future: service.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Категории не найдены'));
          }

          final categories = snapshot.data!;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isIncome = cat.type == CategoryType.income;

              return ListTile(
                leading: Icon(
                  isIncome ? Icons.add_circle_outline : Icons.remove_circle_outline,
                  color: isIncome ? Colors.green : Colors.red,
                ),
                title: Text(cat.name),
                subtitle: Text(isIncome ? 'Доходная' : 'Расходная'),
                trailing: const Icon(Icons.chevron_right),
              );
            },
          );
        },
      ),
    );
  }
}