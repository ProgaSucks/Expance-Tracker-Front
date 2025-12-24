import 'dart:convert';
import '../models/token.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core.dart';

class AuthService {
  final storage = const FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.baseUrl + '/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final token = Token.fromJson(jsonDecode(response.body));
      // Сохраняем токен для будущих запросов [cite: 8]
      await storage.write(key: 'jwt', value: token.accessToken);
      return true;
    } else {
      // Бэкенд вернет 401 при ошибке [cite: 29]
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.baseUrl + '/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Бэкенд возвращает 201 Created при успешной регистрации
      return response.statusCode == 201;
    } catch (e) {
      print("Ошибка регистрации: $e");
      return false;
    }
  }
}