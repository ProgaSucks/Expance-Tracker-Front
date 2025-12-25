// lib/widgets/recommendations_list.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recommendations_provider.dart';
import 'recommendation_card.dart';

class RecommendationsList extends StatefulWidget {
  const RecommendationsList({Key? key}) : super(key: key);

  @override
  State<RecommendationsList> createState() => _RecommendationsListState();
}

class _RecommendationsListState extends State<RecommendationsList> {
  String _filter = 'unread';

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  void _loadRecommendations() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationsProvider>().fetchRecommendations(
            unreadOnly: _filter == 'unread',
          );
    });
  }

  List<String> _getFilteredTypes() {
    final types = {'overspend', 'saving', 'habit_report', 'edu_card'};
    return types.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecommendationsProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb, size: 24),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Рекомендации',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (provider.unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${provider.unreadCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Обновить'),
                      onPressed: provider.loading ? null : _loadRecommendations,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  children: [
                    _buildFilterChip('unread', 'Непрочитанные'),
                    const SizedBox(width: 8),
                    _buildFilterChip('overspend', '⚠️ Перерасход'),
                    const SizedBox(width: 8),
                    _buildFilterChip('saving', '✨ Экономия'),
                    const SizedBox(width: 8),
                    _buildFilterChip('habit_report', '📊 Отчёт'),
                    const SizedBox(width: 8),
                    _buildFilterChip('edu_card', '💡 Совет'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Content
            if (provider.loading)
              Center(
                child: Column(
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Загружаем рекомендации...'),
                  ],
                ),
              )
            else if (provider.error != null)
              Card(
                color: Colors.red.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 32),
                      const SizedBox(height: 8),
                      Text(provider.error!),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadRecommendations,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              )
            else if (provider.recommendations.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        _filter == 'unread'
                            ? 'Все рекомендации прочитаны'
                            : 'Нет рекомендаций',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Добавьте транзакции для новых рекомендаций',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.recommendations.length,
                itemBuilder: (context, index) {
                  final rec = provider.recommendations[index];
                  return RecommendationCard(
                    recommendation: rec,
                    onMarkAsRead: () =>
                        context.read<RecommendationsProvider>().markAsRead(rec.id),
                    loading: provider.loading,
                  );
                },
              ),

            // Footer
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: Text(
                    'Показано ${provider.recommendations.length} из ${provider.recommendations.length} рекомендаций',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String value, String label) {
    return FilterChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (selected) {
        if (selected) {
          setState(() => _filter = value);
          _loadRecommendations();
        }
      },
    );
  }
}
