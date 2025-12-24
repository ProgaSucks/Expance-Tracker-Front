import 'package:flutter/material.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../services/cats.dart';
import '../../services/trans.dart';

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction; // Принимаем транзакцию для правки

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descController;
  
  late String _type;
  Category? _selectedCategory;
  List<Category> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Инициализируем поля данными из существующей транзакции
    _amountController = TextEditingController(text: widget.transaction.amount.toString());
    _descController = TextEditingController(text: widget.transaction.description);
    _type = widget.transaction.type.name;
    _loadCategoriesAndSetSelected();
  }

  Future<void> _loadCategoriesAndSetSelected() async {
  final cats = await CategoryService().getCategories();
  setState(() {
    _categories = cats;
    _selectedCategory = _categories.firstWhere((c) => c.id == widget.transaction.categoryId);
    if (_selectedCategory != null) {
      _type = _selectedCategory!.type.name; 
    }
  });
}

Future<bool> _showDeleteDialog() async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Удаление'),
      content: const Text('Вы уверены, что хотите удалить эту транзакцию?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Удалить', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  ) ?? false; // Если закрыли диалог мимо кнопок, возвращаем false
}

  void _update() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      setState(() => _isLoading = true);
      
      final success = await TransactionService().updateTransaction(
        id: widget.transaction.id,
        amount: double.parse(_amountController.text),
        description: _descController.text,
        type: _type,
        categoryId: _selectedCategory!.id,
      );

      if (success) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать'),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () async {
            final confirmed = await _showDeleteDialog();
            if (confirmed) {
              final success = await TransactionService().deleteTransaction(widget.transaction.id);
              if (success) Navigator.pop(context, true);
            }
          },
        ),
      ],),
      body: _categories.isEmpty 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'expense', label: Text('Расход')),
                      ButtonSegment(value: 'income', label: Text('Доход')),
                    ],
                    selected: {_type},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _type = newSelection.first;
                        _selectedCategory = null; 
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(labelText: 'Сумма', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Введите сумму' : null,
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<Category>(
                    decoration: const InputDecoration(labelText: 'Категория', border: OutlineInputBorder()),
                    value: _selectedCategory,
                    items: _categories
                        .where((c) => c.type.name == _type)
                        .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                    validator: (v) => v == null ? 'Выберите категорию' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Комментарий', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _update,
                    child: const Text('Обновить данные'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}