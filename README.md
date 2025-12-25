# Expance-Tracker-Front
I love my friends

Карта проекта:
lib/
├── main.dart                   # Точка входа, настройка темы и маршрутов
├── core/
│   └── constants.dart          # Константы (ApiConfig.baseUrl с вашим IP)
├── models/
│   ├── category.dart           # Класс Category + логика сравнения объектов (==)
│   ├── transaction.dart        # Класс Transaction + маппинг из JSON
│   └── statistics.dart         # Класс Statistics (сводка баланса)
├── services/
│   ├── auth_service.dart       # Авторизация и работа с JWT (FlutterSecureStorage)
│   ├── category_service.dart   # Методы GET, POST, PUT, DELETE для категорий
│   ├── transaction_service.dart# CRUD для транзакций (без поля date в PUT)
│   └── stats_service.dart      # Запрос агрегированной статистики
├── screens/
│   ├── login_screen.dart       # Вход в приложение
│   ├── register_screen.dart    # Регистрация нового пользователя
│   ├── home_screen.dart        # Главный экран с BottomNavigationBar и IndexedStack
│   ├── categories_screen.dart  # [НОВОЕ] Управление категориями (создание/удаление)
│   └── tabs/
│       ├── summary_tab.dart    # Вкладка "Обзор" (с кнопкой Refresh и Pull-to-Refresh)
│       └── history_tab.dart    # Вкладка "История" (сопоставление ID категорий с типами)
└── forms/
    ├── add_transaction.dart    # Экран добавления новой операции
    └── edit_transaction.dart   # Экран редактирования (с диалогом подтверждения удаления)