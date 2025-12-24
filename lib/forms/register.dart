import 'package:flutter/material.dart';
import '../services/auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Контроллеры для управления текстом
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // Новый контроллер
  
  final _authService = AuthService();
  bool _isLoading = false;

  void _handleRegister() async {
    // Сначала проверяем валидацию всех полей
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final success = await _authService.register(
        _emailController.text,
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Регистрация успешна! Теперь войдите.')),
        );
        Navigator.pop(context); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка регистрации. Возможно, email занят.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: SingleChildScrollView( // Чтобы клавиатура не перекрывала поля
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите email';
                  if (!value.contains('@')) return 'Введите корректный email';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Пароль'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) return 'Минимум 6 символов';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // Поле подтверждения пароля
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Подтвердите пароль'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Повторите пароль';
                  if (value != _passwordController.text) {
                    return 'Пароли не совпадают'; // Сама логика сравнения
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              _isLoading 
                ? const CircularProgressIndicator() 
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50), // Кнопка на всю ширину
                    ),
                    onPressed: _handleRegister, 
                    child: const Text('Создать аккаунт')
                  ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Важно освобождать ресурсы контроллеров
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}