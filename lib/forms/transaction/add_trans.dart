import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/cats.dart';
import '../../services/trans.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  
  String _type = 'expense'; // По умолчанию расход
  Category? _selectedCategory;
  List<Category> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final cats = await CategoryService().getCategories();
    setState(() {
      _categories = cats;
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      setState(() => _isLoading = true);
      
      final success = await TransactionService().createTransaction(
        amount: double.parse(_amountController.text),
        description: _descController.text,
        type: _type,
        categoryId: _selectedCategory!.id,
      );

      if (success) {
        Navigator.pop(context, true); // Возвращаемся и сигнализируем об успехе
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новая операция')),
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
                      ButtonSegment(value: 'expense', label: Text('Расход'), icon: Icon(Icons.remove_circle)),
                      ButtonSegment(value: 'income', label: Text('Доход'), icon: Icon(Icons.add_circle)),
                    ],
                    selected: {_type},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _type = newSelection.first;
                        _selectedCategory = null; // Сбрасываем категорию при смене типа
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
                    initialValue: _selectedCategory,
                    items: _categories
                        .where((c) => c.type.name == _type) // Фильтруем категории по типу
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
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                    child: const Text('Сохранить'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}