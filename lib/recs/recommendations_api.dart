// lib/services/recommendations_api.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class Recommendation {
  final int id;
  final String type;
  final String title;
  final String message;
  final String periodStart;
  final String periodEnd;
  final String createdAt;
  final bool isRead;
  final int userId;
  final int? categoryId;
  final String? categoryName;

  Recommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.periodStart,
    required this.periodEnd,
    required this.createdAt,
    required this.isRead,
    required this.userId,
    this.categoryId,
    this.categoryName,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      periodStart: json['period_start'] as String,
      periodEnd: json['period_end'] as String,
      createdAt: json['created_at'] as String,
      isRead: json['is_read'] as bool,
      userId: json['user_id'] as int,
      categoryId: json['category_id'] as int?,
      categoryName: json['category_name'] as String?,
    );
  }
}

class RecommendationsList {
  final int total;
  final int unreadCount;
  final List<Recommendation> recommendations;

  RecommendationsList({
    required this.total,
    required this.unreadCount,
    required this.recommendations,
  });

  factory RecommendationsList.fromJson(Map<String, dynamic> json) {
    return RecommendationsList(
      total: json['total'] as int,
      unreadCount: json['unread_count'] as int,
      recommendations: (json['recommendations'] as List)
          .map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class RecommendationsAPI {
  late Dio _dio;
  final String baseURL;

  RecommendationsAPI({this.baseURL = 'http://localhost:8001/api/v1'}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseURL,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            _clearAuth();
          }
          return handler.next(error);
        },
      ),
    );
  }

  String? _getAccessToken() {
    // Получить токен из SharedPreferences или другого хранилища
    return null; // TODO: реализовать получение токена
  }

  void _clearAuth() {
    // TODO: очистить токен и перенаправить на логин
  }

  Future<RecommendationsList> getRecommendations({
    bool unreadOnly = true,
    String? type,
  }) async {
    try {
      final response = await _dio.get(
        '/recommendations',
        queryParameters: {
          'unread_only': unreadOnly,
          if (type != null) 'rec_type': type,
        },
      );
      return RecommendationsList.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Recommendation> getDailyTip() async {
    try {
      final response = await _dio.get('/recommendations/daily-tip');
      return Recommendation.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Recommendation> markAsRead(int id) async {
    try {
      final response = await _dio.patch('/recommendations/$id/read');
      return Recommendation.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> recalculate() async {
    try {
      final response = await _dio.post('/recommendations/recalculate');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> healthCheck() async {
    try {
      await _dio.get('/recommendations');
      return true;
    } catch (e) {
      return false;
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null) {
        return Exception(error.response?.data['detail'] ?? 'Error');
      }
      return Exception(error.message ?? 'Unknown error');
    }
    return Exception('Unknown error');
  }
}
