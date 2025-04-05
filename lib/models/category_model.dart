class Category {
  final String id;
  final String name;
  final String category;

  Category({
    required this.id,
    required this.name,
    required this.category,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id']['\$oid'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
    );
  }
}
