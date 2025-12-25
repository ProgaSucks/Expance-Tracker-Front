import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core.dart';
import '../main.dart'; // Для доступа к navigatorKey

class ApiClient {
  final storage = const FlutterSecureStorage();
  final http.Client _client = http.Client();

  // Общий метод для обработки запросов
  Future<http.Response> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      // Если токен просрочен — очищаем хранилище и выходим
      await storage.delete(key: 'jwt');
      
      // Вызываем глобальный переход на экран логина
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
    }
    return response;
  }

  Future<Map<String, String>> _getHeaders() async {
    String? token = await storage.read(key: 'jwt');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String path) async {
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  Future<http.Response> delete(String path) async {
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  Future<http.Response> post(String path, dynamic body) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<http.Response> put(String path, dynamic body) async {
    final response = await _client.put(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<http.Response> patch(String path, dynamic body) async {
    final response = await _client.put(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }
}