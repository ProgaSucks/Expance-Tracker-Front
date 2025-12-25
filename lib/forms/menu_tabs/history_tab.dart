import 'package:flutter/material.dart';
import '../../services/trans.dart';
import '../../models/transaction.dart';
import '../../services/cats.dart';
import '../../models/category.dart';
import '../transaction/add_trans.dart';
import '../transaction/edit_trans.dart';

// Создаем виджет HistoryTab
class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История операций'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить список',
            onPressed: refreshData, // Вызывает загрузку транзакций и категорий
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: FutureBuilder(
          future: _historyData,
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            // Если данных нет, RefreshIndicator все равно должен содержать 
            // что-то прокручиваемое (например, ListView), иначе свайп не сработает.
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

            return ListView.builder(
              // КРИТИЧНО для RefreshIndicator на маленьких списках:
              physics: const AlwaysScrollableScrollPhysics(), 
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final category = categories.firstWhere(
                  (c) => c.id == tx.categoryId,
                  orElse: () => Category(id: 0, name: '?', type: CategoryType.expense),
                );
                final bool isIncome = category.type == CategoryType.income;

                return ListTile(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditTransactionScreen(transaction: tx)),
                    );
                    if (result == true) refreshData(); // Обновляем при возврате
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Переходим на экран формы и ждем результат
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
          
          // Если транзакция добавлена, обновляем экран
          if (result == true) refreshData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}