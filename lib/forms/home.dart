import 'package:flutter/material.dart';
import 'menu_tabs/summary_tab.dart';
import 'menu_tabs/history_tab.dart';
import 'menu_tabs/categories_tab.dart';

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