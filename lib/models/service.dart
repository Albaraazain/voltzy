class Service {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final double basePrice;
  final double durationHours;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Service({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.basePrice,
    required this.durationHours,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      basePrice: (json['base_price'] as num).toDouble(),
      durationHours: (json['duration_hours'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }
}
