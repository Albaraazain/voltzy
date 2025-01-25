import 'package:flutter/material.dart';
import '../../../models/service_model.dart';

@immutable
class CategoryService {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final double durationHours;
  final double basePrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const CategoryService({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.durationHours,
    required this.basePrice,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  Service toService() {
    return Service(
      id: id,
      categoryId: categoryId,
      name: name,
      description: description,
      basePrice: basePrice,
      estimatedDuration: (durationHours * 60).round(),
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory CategoryService.fromJson(Map<String, dynamic> json) {
    return CategoryService(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      categoryId: json['category_id'] as String,
      durationHours: (json['duration_hours'] as num).toDouble(),
      basePrice: (json['base_price'] as num).toDouble(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'duration_hours': durationHours,
      'base_price': basePrice,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
