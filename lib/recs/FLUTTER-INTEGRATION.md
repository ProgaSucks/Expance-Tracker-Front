# 🚀 ИНТЕГРАЦИЯ FLUTTER ФРОНТА

## 📁 КОПИРОВАНИЕ ФАЙЛОВ

**Backend:** Без изменений (5 файлов) — код остаётся прежним

**Flutter Frontend (в lib/):**
```
recommendations_api.dart       → lib/services/recommendations_api.dart
recommendations_provider.dart  → lib/providers/recommendations_provider.dart
recommendation_card.dart       → lib/widgets/recommendation_card.dart
daily_tip.dart                → lib/widgets/daily_tip.dart
recommendations_list.dart      → lib/widgets/recommendations_list.dart
```

---

## 📦 ЗАВИСИМОСТИ

В `pubspec.yaml` добавь:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  dio: ^5.3.0
```

Затем:
```bash
flutter pub get
```

---

## 🔧 КОНФИГУРАЦИЯ

### 1. lib/main.dart

```dart
import 'package:provider/provider.dart';
import 'providers/recommendations_provider.dart';
import 'services/recommendations_api.dart';
import 'widgets/daily_tip.dart';
import 'widgets/recommendations_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expance Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RecommendationsProvider(
            api: RecommendationsAPI(
              baseURL: 'http://localhost:8001/api/v1',
              // Для реального приложения используй IP адрес сервера
              // baseURL: 'http://192.168.1.100:8001/api/v1',
            ),
          ),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('Expance Tracker')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: const [
              DailyTip(),
              SizedBox(height: 24),
              RecommendationsList(),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 2. Получение токена (iOS/Android)

В `lib/services/recommendations_api.dart` измени `_getAccessToken()`:

```dart
import 'package:shared_preferences/shared_preferences.dart';

String? _getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('access_token');
}
```

Добавь в `pubspec.yaml`:
```yaml
shared_preferences: ^2.0.0
```

---

## 🌐 НАСТРОЙКА API URL

**Для разработки (localhost):**
```dart
baseURL: 'http://localhost:8001/api/v1'
```

**Для реального сервера:**
```dart
baseURL: 'http://192.168.1.100:8001/api/v1'  // IP сервера
// или
baseURL: 'https://api.example.com/api/v1'     // доменное имя
```

**Создай конфиг файл (рекомендуется):**

`lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8001/api/v1',
  );
}
```

Используй:
```dart
baseURL: ApiConfig.apiUrl
```

---

## 📋 КРАТКИЙ ЧЕКЛИСТ

- [ ] Скопировал 5 Flutter файлов в lib/
- [ ] Добавил зависимости (provider, dio) в pubspec.yaml
- [ ] Обновил lib/main.dart с MultiProvider
- [ ] Настроил API URL (для своего сервера)
- [ ] Реализовал получение токена из SharedPreferences
- [ ] Запустил `flutter pub get`
- [ ] Добавил компоненты DailyTip и RecommendationsList на главную страницу
- [ ] Запустил приложение: `flutter run`
- [ ] Проверил что компоненты загружаются

---

## ✅ СТРУКТУРА ПРОЕКТА

```
lib/
├── main.dart                          (обновить)
├── services/
│   └── recommendations_api.dart       (НОВЫЙ)
├── providers/
│   └── recommendations_provider.dart  (НОВЫЙ)
└── widgets/
    ├── recommendation_card.dart       (НОВЫЙ)
    ├── daily_tip.dart                (НОВЫЙ)
    └── recommendations_list.dart      (НОВЫЙ)
```

---

## 🚀 ЗАПУСК

```bash
# Получить зависимости
flutter pub get

# Запустить приложение
flutter run

# Запустить на конкретном девайсе
flutter run -d <device_id>

# Убедиться что Backend работает
curl http://localhost:8001/docs
```

---

## 🔗 ЭНДПОИНТЫ (НЕ МЕНЯЮТСЯ)

```
GET    /api/v1/recommendations/           Получить рекомендации
POST   /api/v1/recommendations/recalculate    Пересчитать
GET    /api/v1/recommendations/daily-tip     Совет дня
PATCH  /api/v1/recommendations/{id}/read     Отметить прочитанным
```

---

## 💡 ВАЖНЫЕ МОМЕНТЫ

1. **Provider паттерн** — используется для управления состоянием (как React Context)
2. **Dio** — HTTP клиент (аналог Axios)
3. **SharedPreferences** — хранение токенов (как localStorage)
4. **Responsive дизайн** — использует встроенные Material компоненты
5. **Dark mode** — работает из коробки через Theme.of()

---

## ❓ ЧАСТЫЕ ОШИБКИ

**"Connection refused"**
→ Убедись что Backend запущен на http://localhost:8001

**"Dio error 401"**
→ Добавь реальный токен в SharedPreferences перед запросом

**"Provider not found"**
→ Убедись что MultiProvider обёрнут на нужном уровне иерархии виджетов

**"Widgets null"**
→ Добавь проверки `if (provider.dailyTip != null)` перед использованием

---

**Готово! 🎉 Теперь Flutter приложение работает с рекомендациями.**
