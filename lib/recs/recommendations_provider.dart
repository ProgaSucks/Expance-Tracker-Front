// lib/providers/recommendations_provider.dart

import 'package:flutter/foundation.dart';
import '../services/recommendations_api.dart';

class RecommendationsProvider extends ChangeNotifier {
  final RecommendationsAPI api;

  List<Recommendation> recommendations = [];
  Recommendation? dailyTip;
  int unreadCount = 0;
  bool loading = true;
  String? error;

  RecommendationsProvider({required this.api});

  Future<void> fetchRecommendations({bool unreadOnly = true}) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      final result = await api.getRecommendations(unreadOnly: unreadOnly);
      recommendations = result.recommendations;
      unreadCount = result.unreadCount;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDailyTip() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      dailyTip = await api.getDailyTip();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await api.markAsRead(id);
      await fetchRecommendations();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> recalculate() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      await api.recalculate();
      await fetchRecommendations();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
