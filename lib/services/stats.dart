import 'dart:convert';
import '../models/statistics.dart';
import '../api_client.dart';

class StatsService {
  final ApiClient _apiClient = ApiClient();

  Future<Statistics?> getSummary() async {
    final response = await _apiClient.get('/statistics/summary');

    if (response.statusCode == 200) {
      return Statistics.fromJson(jsonDecode(response.body));
    }
    return null;
  }
  
  // Добавим метод получения данных профиля для имени пользователя
  Future<String?> getUserEmail() async {
    final response = await _apiClient.get('/auth/me');
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['email'];
    }
    return null;
  }
}