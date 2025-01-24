import 'package:flutter/foundation.dart';
import 'service_model.dart';

@immutable
class Category {
  final String id;
  final String name;
  final String? description;
  final String? iconName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Service> services;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.iconName,
    required this.createdAt,
    required this.updatedAt,
    this.services = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconName: json['icon_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      services: json['services'] != null
          ? (json['services'] as List<dynamic>)
              .map((e) => Service.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_name': iconName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'services': services.map((e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          iconName == other.iconName;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ description.hashCode ^ iconName.hashCode;

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Service>? services,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      services: services ?? this.services,
    );
  }
}
