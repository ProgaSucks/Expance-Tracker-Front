import 'dart:convert';
import '../models/category.dart';
import '../api_client.dart';

class CategoryService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Category>> getCategories() async {
    final response = await _apiClient.get('/categories');

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Category.fromJson(item)).toList();
    } else {
      throw Exception('Не удалось загрузить категории');
    }
  }

  Future<bool> createCategory(String name, String type) async {
    final response = await _apiClient.post(
      '/categories', {'name': name, 'type': type},
    );
    return response.statusCode == 201;
  }

  Future<bool> updateCategory(int id, String name, String type) async {
    final response = await _apiClient.put(
      '/categories/$id', {'name': name, 'type': type},
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteCategory(int id) async {
    final response = await _apiClient.delete(
      '/categories/$id',
    );
    return response.statusCode == 204;
  }
}