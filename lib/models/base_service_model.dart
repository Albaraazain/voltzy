import 'package:flutter/foundation.dart';

@immutable
class BaseService {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final double basePrice;
  final double? durationHours;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const BaseService({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.basePrice,
    this.durationHours,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory BaseService.fromJson(Map<String, dynamic> json) {
    try {
      return BaseService(
        id: json['id'] as String,
        categoryId: json['category_id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        basePrice: (json['base_price'] ?? json['basePrice'] as num).toDouble(),
        durationHours: json['duration_hours'] != null
            ? (json['duration_hours'] as num).toDouble()
            : json['durationHours'] != null
                ? (json['durationHours'] as num).toDouble()
                : null,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : json['createdAt'] != null
                ? DateTime.parse(json['createdAt'] as String)
                : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : json['updatedAt'] != null
                ? DateTime.parse(json['updatedAt'] as String)
                : null,
        deletedAt: json['deleted_at'] != null
            ? DateTime.parse(json['deleted_at'] as String)
            : json['deletedAt'] != null
                ? DateTime.parse(json['deletedAt'] as String)
                : null,
      );
    } catch (e, stackTrace) {
      print('Error parsing BaseService: $e');
      print('JSON data: $json');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'base_price': basePrice,
      'duration_hours': durationHours,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  BaseService copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? description,
    double? basePrice,
    double? durationHours,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return BaseService(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      durationHours: durationHours ?? this.durationHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseService &&
        other.id == id &&
        other.categoryId == categoryId &&
        other.name == name &&
        other.description == description &&
        other.basePrice == basePrice &&
        other.durationHours == durationHours &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      categoryId,
      name,
      description,
      basePrice,
      durationHours,
      createdAt,
      updatedAt,
      deletedAt,
    );
  }
}
