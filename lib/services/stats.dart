import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/statistics.dart';
import '../core.dart';

class StatsService {
  final storage = const FlutterSecureStorage();

  Future<Statistics?> getSummary() async {
    String? token = await storage.read(key: 'jwt');
    
    final response = await http.get(
      Uri.parse(ApiConfig.baseUrl + '/statistics/summary'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return Statistics.fromJson(jsonDecode(response.body));
    }
    return null;
  }
  
  // Добавим метод получения данных профиля для имени пользователя
  Future<String?> getUserEmail() async {
    String? token = await storage.read(key: 'jwt');
    final response = await http.get(
      Uri.parse(ApiConfig.baseUrl + '/auth/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['email'];
    }
    return null;
  }
}