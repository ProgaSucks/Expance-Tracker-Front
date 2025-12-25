import 'dart:convert';
import '../api_client.dart';
import '../models/recommendation.dart';

class RecsService {
  final ApiClient _apiClient = ApiClient();

  // Получение списка всех рекомендаций
  Future<List<Recommendation>> getRecommendations() async {
    // unread_only=false чтобы видеть историю, можно менять по желанию
    final response = await _apiClient.get('/recommendations');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Бэкенд возвращает объект { "total": ..., "recommendations": [...] }
      final List<dynamic> list = data['recommendations'];
      return list.map((json) => Recommendation.fromJson(json)).toList();
    }
    return [];
  }

  // Получение ежедневного совета ("daily-tip")
  Future<Recommendation?> getDailyTip() async {
    final response = await _apiClient.get('/recommendations/daily-tip');

    if (response.statusCode == 200) {
      return Recommendation.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // Пометить как прочитанное
  Future<bool> markAsRead(int id) async {
    final response = await _apiClient.patch('/recommendations/$id/read', {});
    return response.statusCode == 200;
  }
}