class Recommendation {
  final int id;
  final String type; // overspend, saving, habit_report, edu_card
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? categoryName;

  Recommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    this.categoryName,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'],
      categoryName: json['category_name'],
    );
  }
}