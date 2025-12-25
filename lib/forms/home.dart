import 'package:flutter/material.dart';
import 'menu_tabs/summary_tab.dart';
import 'menu_tabs/history_tab.dart';
import 'menu_tabs/categories_tab.dart';
import 'menu_tabs/recommendation_tab.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login.dart';

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
  late DateTimeRange _selectedDateRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
      _selectedDateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
  }

  // 2. Метод для обновления периода
  void _updateDateRange(DateTimeRange newRange) {
    setState(() {
      _selectedDateRange = newRange;
    });
  }

  Future<void> _logout() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'jwt'); // Удаляем токен
    
    if (mounted) {
      // Возвращаемся на экран входа и очищаем стек навигации
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == 4) {
      _logout();
      return;
    }

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
    _pages = [
      SummaryTab(key: _summaryKey,
        dateRange: _selectedDateRange,
        onDateRangeChanged: _updateDateRange),
      HistoryTab(key: _historyKey,
        dateRange: _selectedDateRange,
        onDateRangeChanged: _updateDateRange),
      CategoriesTab(key: _categoriesKey),
      const RecommendationsTab(), // <--- Новый таб (индекс 3)
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Обзор'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'История'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Категории'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: 'Советы'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Выход'),
        ],
        selectedItemColor: Colors.blue,   // Цвет выбранной иконки
        unselectedItemColor: Colors.grey, // Цвет неактивных иконок
      ),
    );
  }
}