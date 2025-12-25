import 'package:flutter/material.dart';
import '../../services/cats.dart';
import '../../models/category.dart';

// Создаем сам виджет CategoriesTab
class CategoriesTab extends StatefulWidget {
  const CategoriesTab({super.key});

  @override
  State<CategoriesTab> createState() => CategoriesTabState();
}

class CategoriesTabState extends State<CategoriesTab> {
  final CategoryService _service = CategoryService();
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  void refreshData() {
    setState(() {
      _categoriesFuture = _service.getCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои категории'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: refreshData),
        ],
      ),
      body: FutureBuilder<List<Category>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final cats = snapshot.data ?? [];
          return ListView.builder(
            itemCount: cats.length,
            itemBuilder: (context, index) {
              final cat = cats[index];
              return ListTile(
                leading: Icon(
                  cat.type == CategoryType.income ? Icons.add_circle : Icons.remove_circle,
                  color: cat.type == CategoryType.income ? Colors.green : Colors.red,
                ),
                title: Text(cat.name),
                subtitle: Text(cat.type == CategoryType.income ? 'Доходы' : 'Расходы'),
                onTap: () => _showCategoryDialog(cat),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'category_add_button',
        onPressed: () => _showCategoryDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Универсальный диалог для создания и редактирования
  void _showCategoryDialog(Category? category) {
    final nameController = TextEditingController(text: category?.name);
    String type = category?.type == CategoryType.income ? 'income' : 'expense';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(category == null ? 'Новая категория' : 'Редактировать'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Название'),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: type,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('Доход')),
                  DropdownMenuItem(value: 'expense', child: Text('Расход')),
                ],
                onChanged: (val) => setDialogState(() => type = val!),
              ),
            ],
          ),
          actions: [
            if (category != null)
              TextButton(
                onPressed: () async {
                  await _service.deleteCategory(category.id);
                  Navigator.pop(context);
                  refreshData();
                },
                child: const Text('Удалить', style: TextStyle(color: Colors.red)),
              ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
            ElevatedButton(
              onPressed: () async {
                bool success;
                if (category == null) {
                  success = await _service.createCategory(nameController.text, type);
                } else {
                  success = await _service.updateCategory(category.id, nameController.text, type);
                }
                if (success) {
                  Navigator.pop(context);
                  refreshData();
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}