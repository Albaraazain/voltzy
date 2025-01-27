import 'package:flutter/material.dart';

@immutable
class CategoryService {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final double durationHours;
  final String categoryId;
  final String? imageUrl;
  final bool isActive;

  const CategoryService({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.durationHours,
    required this.categoryId,
    this.imageUrl,
    this.isActive = true,
  });

  factory CategoryService.fromJson(Map<String, dynamic> json) {
    return CategoryService(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      basePrice: (json['base_price'] as num).toDouble(),
      durationHours: json['estimated_duration'] != null
          ? (json['estimated_duration'] as num).toDouble()
          : 1.0,
      categoryId: json['category_id'] as String,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'base_price': basePrice,
      'estimated_duration': durationHours,
      'category_id': categoryId,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }
}
