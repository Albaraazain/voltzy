import 'package:flutter/foundation.dart';

@immutable
class ClientNote {
  final String id;
  final String homeownerId;
  final String professionalId;
  final String title;
  final String content;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClientNote({
    required this.id,
    required this.homeownerId,
    required this.professionalId,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClientNote.fromJson(Map<String, dynamic> json) {
    return ClientNote(
      id: json['id'] as String,
      homeownerId: json['homeowner_id'] as String,
      professionalId: json['professional_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'homeowner_id': homeownerId,
        'professional_id': professionalId,
        'title': title,
        'content': content,
        'category': category,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  ClientNote copyWith({
    String? id,
    String? homeownerId,
    String? professionalId,
    String? title,
    String? content,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClientNote(
      id: id ?? this.id,
      homeownerId: homeownerId ?? this.homeownerId,
      professionalId: professionalId ?? this.professionalId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
