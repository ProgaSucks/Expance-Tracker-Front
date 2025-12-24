import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/category.dart';
import '../core.dart';

class CategoryService {
  final storage = const FlutterSecureStorage();

  Future<List<Category>> getCategories() async {
    String? token = await storage.read(key: 'jwt');
    
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/categories'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Category.fromJson(item)).toList();
    } else {
      throw Exception('Не удалось загрузить категории');
    }
  }
}