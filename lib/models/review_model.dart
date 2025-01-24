import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'homeowner_model.dart';

@immutable
class Review {
  final String id;
  final String jobId;
  final String homeownerId;
  final String professionalId;
  final double rating;
  final String comment;
  final List<String> photos;
  final String? response;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Homeowner homeowner;

  const Review({
    required this.id,
    required this.jobId,
    required this.homeownerId,
    required this.professionalId,
    required this.rating,
    required this.comment,
    required this.photos,
    this.response,
    required this.createdAt,
    required this.updatedAt,
    required this.homeowner,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      homeownerId: json['homeowner_id'] as String,
      professionalId: json['professional_id'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      response: json['response'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      homeowner: Homeowner.fromJson(json['homeowner']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'homeowner_id': homeownerId,
      'professional_id': professionalId,
      'rating': rating,
      'comment': comment,
      'photos': photos,
      'response': response,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'homeowner': homeowner.toJson(),
    };
  }

  Review copyWith({
    String? id,
    String? jobId,
    String? homeownerId,
    String? professionalId,
    double? rating,
    String? comment,
    List<String>? photos,
    String? response,
    DateTime? createdAt,
    DateTime? updatedAt,
    Homeowner? homeowner,
  }) {
    return Review(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      homeownerId: homeownerId ?? this.homeownerId,
      professionalId: professionalId ?? this.professionalId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      photos: photos ?? this.photos,
      response: response ?? this.response,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      homeowner: homeowner ?? this.homeowner,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Review &&
        other.id == id &&
        other.jobId == jobId &&
        other.homeownerId == homeownerId &&
        other.professionalId == professionalId &&
        other.rating == rating &&
        other.comment == comment &&
        other.photos == photos &&
        other.response == response &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.homeowner == homeowner;
  }

  @override
  int get hashCode => Object.hash(
        id,
        jobId,
        homeownerId,
        professionalId,
        rating,
        comment,
        photos,
        response,
        createdAt,
        updatedAt,
        homeowner,
      );

  // Computed getters
  bool get hasResponse => response != null && response!.isNotEmpty;
  String get formattedDate => DateFormat('MMM d, y').format(createdAt);
  Widget get ratingWidget => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          return Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: index < rating ? Colors.amber : Colors.grey,
            size: 16,
          );
        }),
      );
}
