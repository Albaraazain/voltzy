// This file is deprecated. Use base_service_model.dart and professional_service_model.dart instead.
export 'base_service_model.dart';
export 'professional_service_model.dart';

import 'package:flutter/foundation.dart';
import 'base_service_model.dart';

@immutable
class Service extends BaseService {
  @override
  final String description;
  @override
  final double basePrice;
  @override
  final double? durationHours;
  @override
  final String categoryId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;

  const Service({
    required String id,
    required String name,
    required this.description,
    required this.basePrice,
    required this.categoryId,
    this.durationHours,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  }) : super(
          id: id,
          name: name,
          description: description,
          basePrice: basePrice,
          categoryId: categoryId,
          durationHours: durationHours,
          createdAt: createdAt,
          updatedAt: updatedAt,
          deletedAt: deletedAt,
        );

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      basePrice: (json['base_price'] as num).toDouble(),
      categoryId: json['category_id'] as String,
      durationHours: (json['duration_hours'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'base_price': basePrice,
      'duration_hours': durationHours,
      'category_id': categoryId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  @override
  Service copyWith({
    String? id,
    String? name,
    String? description,
    double? basePrice,
    String? categoryId,
    double? durationHours,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      categoryId: categoryId ?? this.categoryId,
      durationHours: durationHours ?? this.durationHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Service &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.basePrice == basePrice &&
        other.categoryId == categoryId &&
        other.durationHours == durationHours &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.deletedAt == deletedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      basePrice,
      categoryId,
      durationHours,
      createdAt,
      updatedAt,
      deletedAt,
    );
  }
}
