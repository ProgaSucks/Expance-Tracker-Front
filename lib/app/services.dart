import 'dart:convert';
import '../schemas/schemas.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl = "http://192.168.0.10:8001/"; // Для эмулятора Android
  final storage = const FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
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
}