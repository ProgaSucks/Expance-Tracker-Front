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
  
  // Создаем ключи для доступа к состоянию вкладок
  final GlobalKey<SummaryTabState> _summaryKey = GlobalKey();
  final GlobalKey<HistoryTabState> _historyKey = GlobalKey();
  final GlobalKey<CategoriesTabState> _categoriesKey = GlobalKey();
  // Список виджетов для вкладок
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      SummaryTab(key: _summaryKey),
      HistoryTab(key: _historyKey),
      CategoriesTab(key: _categoriesKey),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Вызываем обновление в зависимости от выбранной вкладки
    switch (index) {
      case 0:
        _summaryKey.currentState?.refreshData();
        break;
      case 1:
        _historyKey.currentState?.refreshData();
        break;
      case 2:
        _categoriesKey.currentState?.refreshData();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Обзор'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'История'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Категории'),
        ],
      ),
    );
  }
}