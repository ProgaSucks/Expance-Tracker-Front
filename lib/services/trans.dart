import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/transaction.dart';
import '../core.dart';

class TransactionService {
  final storage = const FlutterSecureStorage();

  Future<List<Transaction>> getTransactions() async {
    String? token = await storage.read(key: 'jwt');
    
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/transactions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Transaction.fromJson(item)).toList();
    } else {
      throw Exception('Ошибка загрузки транзакций');
    }
  }

  Future<bool> createTransaction({
  required double amount,
  required String description,
  required String type,
  required int categoryId,
}) async {
  String? token = await storage.read(key: 'jwt');
  
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/transactions'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'amount': amount.toString(),
      'description': description,
      'type': type,
      'category_id': categoryId,
      'date': DateTime.now().toIso8601String().split('T')[0],
    }),
  );

  return response.statusCode == 201;
}

Future<bool> updateTransaction({
  required int id,
  required double amount,
  required String description,
  required String type,
  required int categoryId,
  required String date,
}) async {
  String? token = await storage.read(key: 'jwt');
  
  final response = await http.put(
    Uri.parse('${ApiConfig.baseUrl}/transactions/$id'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'amount': amount,
      'description': description,
      'type': type,
      'category_id': categoryId,
      'date': date, // Передаем дату, которая уже была (или измененную)
    }),
  );
  return response.statusCode == 200;
}

Future<bool> deleteTransaction(int id) async {
    String? token = await storage.read(key: 'jwt');
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/transactions/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 204; // Обычно бэкенд возвращает 204 No Content
  }
}