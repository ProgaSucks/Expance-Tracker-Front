import 'dart:convert';
import '../models/transaction.dart';
import '../core.dart';
import '../api_client.dart';

class TransactionService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Transaction>> getTransactions() async {
    final response = await _apiClient.get('/transactions');

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
  final response = await _apiClient.post(
    '/transactions', {
      'amount': amount.toString(),
      'description': description,
      'type': type,
      'category_id': categoryId,
      'date': DateTime.now().toIso8601String().split('T')[0],
    },
  );

  return response.statusCode == 201;
}

Future<bool> updateTransaction({
  required int id,
  required double amount,
  required String description,
  required String type,
  required int categoryId,
}) async {
  final response = await _apiClient.put(
    '/transactions/$id', {
      'amount': amount,
      'description': description,
      'type': type,
      'category_id': categoryId,
    },
  );
  return response.statusCode == 200;
}

Future<bool> deleteTransaction(int id) async {
    final response = await _apiClient.delete(
      '/transactions/$id',
    );
    return response.statusCode == 204; // Обычно бэкенд возвращает 204 No Content
  }
}