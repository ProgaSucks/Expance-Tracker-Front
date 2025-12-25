// lib/widgets/daily_tip.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'recommendations_provider.dart';

class DailyTip extends StatefulWidget {
  final int refreshInterval; // в секундах

  const DailyTip({Key? key, this.refreshInterval = 3600}) : super(key: key);

  @override
  State<DailyTip> createState() => _DailyTipState();
}

class _DailyTipState extends State<DailyTip> {
  @override
  void initState() {
    super.initState();
    _loadTip();
  }

  void _loadTip() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecommendationsProvider>().fetchDailyTip();
    });
  }

  String _getIcon(String type) {
    const icons = {
      'overspend': '⚠️',
      'saving': '✨',
      'habit_report': '📊',
      'edu_card': '💡',
    };
    return icons[type] ?? '📌';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecommendationsProvider>(
      builder: (context, provider, child) {
        if (provider.loading) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Загружаем совет дня...'),
                ],
              ),
            ),
          );
        }

        if (provider.error != null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange, size: 32),
                  const SizedBox(height: 8),
                  Text(provider.error!),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadTip,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.dailyTip == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Icon(Icons.info, color: Colors.blue, size: 32),
                  const SizedBox(height: 8),
                  const Text('Пока нет советов для вас'),
                  const SizedBox(height: 4),
                  const Text(
                    'Добавьте транзакции чтобы получить рекомендации',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        }

        final tip = provider.dailyTip!;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getIcon(tip.type),
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Совет дня',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadTip,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  tip.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  tip.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  _formatDate(tip.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}.${date.month}.${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
