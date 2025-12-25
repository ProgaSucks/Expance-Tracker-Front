import 'dart:convert';
import '../models/token.dart';
import '../api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<bool> login(String email, String password) async {
    final response = await _apiClient.post(
        '/auth/login', {
          'email': email,
          'password': password,
        },
    );

    if (response.statusCode == 200) {
      final token = Token.fromJson(jsonDecode(response.body));
      // Сохраняем токен для будущих запросов [cite: 8]
      await _apiClient.storage.write(key: 'jwt', value: token.accessToken);
      return true;
    } else {
      // Бэкенд вернет 401 при ошибке [cite: 29]
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/register', {
          'email': email,
          'password': password,
        },
      );

      // Бэкенд возвращает 201 Created при успешной регистрации
      return response.statusCode == 201;
    } catch (e) {
      print("Ошибка регистрации: $e");
      return false;
    }
  }
}