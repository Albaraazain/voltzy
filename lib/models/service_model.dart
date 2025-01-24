import 'package:flutter/foundation.dart';

@immutable
class Service {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final double? basePrice;
  final int? estimatedDuration;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Service({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    this.basePrice,
    this.estimatedDuration,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getter for backward compatibility
  String get title => name;

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      basePrice: json['base_price'] != null
          ? (json['base_price'] as num).toDouble()
          : null,
      estimatedDuration: json['estimated_duration'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'base_price': basePrice,
      'estimated_duration': estimatedDuration,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Service &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          categoryId == other.categoryId &&
          name == other.name &&
          description == other.description &&
          basePrice == other.basePrice &&
          estimatedDuration == other.estimatedDuration;

  @override
  int get hashCode =>
      id.hashCode ^
      categoryId.hashCode ^
      name.hashCode ^
      description.hashCode ^
      basePrice.hashCode ^
      estimatedDuration.hashCode;

  Service copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? description,
    double? basePrice,
    int? estimatedDuration,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Service(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
