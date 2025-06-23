class Device {
  final String id;
  final String name;
  final String? reference;
  final String category;
  final String? description;
  final String? image;

  Device({
    required this.id,
    required this.name,
    this.reference,
    required this.category,
    this.description,
    this.image,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      reference: json['reference'],
      category: json['category'] ?? '',
      description: json['description'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'reference': reference,
      'category': category,
      'description': description,
      'image': image,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Device && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Device{id: $id, name: $name, category: $category}';
  }
}