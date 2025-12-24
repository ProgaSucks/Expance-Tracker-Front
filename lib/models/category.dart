enum CategoryType { income, expense }

class Category {
  final int id;
  final String name;
  final CategoryType type;

  Category({required this.id, required this.name, required this.type});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      // В бэкенде тип категории — это строка 'income' или 'expense'
      type: json['type'] == 'income' ? CategoryType.income : CategoryType.expense,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}