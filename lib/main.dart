import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../forms/login.dart';
import '../forms/register.dart';
import '../forms/home.dart';

void main() {
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Finance Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // Современный дизайн
      ),
      // AuthCheck — это обертка, которая решит, что показать первым
      home: const AuthCheck(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  final storage = const FlutterSecureStorage();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  // Проверяем наличие токена в защищенном хранилище
  Future<void> _checkToken() async {
    String? token = await storage.read(key: 'jwt');
    setState(() {
      _isLoggedIn = token != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Пока проверяем токен — показываем индикатор загрузки
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Если токен есть — на главный экран, если нет — на логин
    return _isLoggedIn ? const HomeScreen() : LoginScreen();
  }
}