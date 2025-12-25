// lib/widgets/recommendation_card.dart

import 'package:flutter/material.dart';
import '../services/recommendations_api.dart';

class RecommendationCard extends StatefulWidget {
  final Recommendation recommendation;
  final VoidCallback? onMarkAsRead;
  final bool loading;

  const RecommendationCard({
    Key? key,
    required this.recommendation,
    this.onMarkAsRead,
    this.loading = false,
  }) : super(key: key);

  @override
  State<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  bool _isMarking = false;

  String _getIcon(String type) {
    const icons = {
      'overspend': '⚠️',
      'saving': '✨',
      'habit_report': '📊',
      'edu_card': '💡',
    };
    return icons[type] ?? '📌';
  }

  String _getTypeLabel(String type) {
    const labels = {
      'overspend': 'Перерасход',
      'saving': 'Экономия',
      'habit_report': 'Отчёт о привычках',
      'edu_card': 'Совет',
    };
    return labels[type] ?? type;
  }

  String _formatPeriod(String start) {
    try {
      final date = DateTime.parse(start);
      return '${date.month} месяц ${date.year}';
    } catch (e) {
      return start;
    }
  }

  Future<void> _handleMarkAsRead() async {
    if (_isMarking || widget.onMarkAsRead == null) return;

    setState(() => _isMarking = true);
    try {
      widget.onMarkAsRead?.call();
    } finally {
      setState(() => _isMarking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _getIcon(widget.recommendation.type),
                  style: const TextTheme().displaySmall,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recommendation.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(_getTypeLabel(widget.recommendation.type)),
                        backgroundColor:
                            Colors.blue.withOpacity(0.2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.recommendation.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatPeriod(widget.recommendation.periodStart),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (!widget.recommendation.isRead && widget.onMarkAsRead != null)
                  ElevatedButton(
                    onPressed: _isMarking ? null : _handleMarkAsRead,
                    child: Text(_isMarking ? 'Отправляю...' : 'Отметить'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
