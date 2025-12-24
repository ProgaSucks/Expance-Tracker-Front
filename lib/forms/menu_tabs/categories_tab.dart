import 'package:flutter/material.dart';
import '../../services/cats.dart';
import '../../models/category.dart';

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