import 'package:flutter/foundation.dart';

class ServiceCategory {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['icon_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ServiceCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceCategory &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.iconUrl == iconUrl &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      iconUrl,
      createdAt,
      updatedAt,
    );
  }
}
