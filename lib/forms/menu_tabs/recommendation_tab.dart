import 'package:flutter/material.dart';
import '../../services/recs.dart';
import '../../models/recommendation.dart';

class RecommendationsTab extends StatefulWidget {
  const RecommendationsTab({super.key});

  @override
  State<RecommendationsTab> createState() => RecommendationsTabState();
}

class RecommendationsTabState extends State<RecommendationsTab> {
  final RecsService _recsService = RecsService();
  late Future<List<Recommendation>> _recsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _recsFuture = _recsService.getRecommendations();
  }

  Future<void> refreshData() async {
    setState(() {
      _loadData();
    });
    await _recsFuture;
  }

  Future<void> _markRead(int id) async {
    await _recsService.markAsRead(id);
    refreshData(); // Обновляем список, чтобы убрать выделение "непрочитано"
  }

  // Вспомогательный метод для выбора иконки и цвета в зависимости от типа
  Map<String, dynamic> _getStyleForType(String type) {
    switch (type) {
      case 'overspend':
        return {'icon': Icons.warning_amber_rounded, 'color': Colors.red};
      case 'saving':
        return {'icon': Icons.savings, 'color': Colors.green};
      case 'habit_report':
        return {'icon': Icons.insights, 'color': Colors.blue};
      case 'edu_card':
        return {'icon': Icons.school, 'color': Colors.purple};
      default:
        return {'icon': Icons.info_outline, 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Советы и рекомендации'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshData,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: FutureBuilder<List<Recommendation>>(
          future: _recsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Ошибка загрузки рекомендаций'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 100),
                  Center(child: Text('Пока нет рекомендаций для вас')),
                ],
              );
            }

            final recs = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recs.length,
              itemBuilder: (context, index) {
                final rec = recs[index];
                final style = _getStyleForType(rec.type);

                return Card(
                  elevation: rec.isRead ? 1 : 4, // Непрочитанные "выше"
                  color: rec.isRead ? Colors.white : Colors.blue.shade50, // Непрочитанные подсвечены
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(style['icon'], color: style['color']),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                rec.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (!rec.isRead)
                              IconButton(
                                icon: const Icon(Icons.check_circle_outline, color: Colors.blue),
                                onPressed: () => _markRead(rec.id),
                                tooltip: 'Пометить как прочитанное',
                              )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(rec.message, style: const TextStyle(fontSize: 14)),
                        if (rec.categoryName != null) ...[
                          const SizedBox(height: 12),
                          Chip(
                            label: Text(rec.categoryName!),
                            backgroundColor: style['color'].withOpacity(0.1),
                            labelStyle: TextStyle(color: style['color'], fontSize: 12),
                          )
                        ],
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            rec.createdAt.toString().split('.')[0], // Простой формат даты
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}