import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'professional_model.dart';
import 'homeowner_model.dart';
import 'profile_model.dart';

@immutable
class DirectRequest {
  static const String STATUS_AWAITING_ACCEPTANCE = 'awaiting_acceptance';
  static const String STATUS_SCHEDULED = 'scheduled';
  static const String STATUS_STARTED = 'started';
  static const String STATUS_COMPLETED = 'completed';
  static const String STATUS_CANCELLED = 'cancelled';

  final String id;
  final String status;
  final String message;
  final DateTime date;
  final String time;
  final String? declineReason;
  final Homeowner? homeowner;
  final Professional? professional;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Profile profile;

  String get homeownerId => homeowner?.id ?? '';
  String get professionalId => professional?.id ?? '';

  String get statusText {
    switch (status) {
      case STATUS_AWAITING_ACCEPTANCE:
        return 'Awaiting Acceptance';
      case STATUS_SCHEDULED:
        return 'Scheduled';
      case STATUS_STARTED:
        return 'Started';
      case STATUS_COMPLETED:
        return 'Completed';
      case STATUS_CANCELLED:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  String get formattedPreferredDate {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String get formattedPreferredTime => time;

  const DirectRequest({
    required this.id,
    required this.status,
    required this.message,
    required this.date,
    required this.time,
    this.declineReason,
    this.homeowner,
    this.professional,
    required this.createdAt,
    required this.updatedAt,
    required this.profile,
  });

  factory DirectRequest.fromJson(Map<String, dynamic> json) {
    final homeownerData = json['homeowner'] as Map<String, dynamic>?;
    final professionalData = json['professional'] as Map<String, dynamic>?;

    // Get profile from either homeowner or professional
    final homeownerProfile = homeownerData != null
        ? Profile.fromJson(homeownerData['profile'] as Map<String, dynamic>)
        : null;

    return DirectRequest(
      id: json['id'] as String,
      status: json['status'] as String,
      message: json['description'] as String,
      date: DateTime.parse(json['preferred_date'] as String),
      time: json['preferred_time'] as String,
      declineReason: json['decline_reason'] as String?,
      homeowner: homeownerData != null
          ? Homeowner.fromJson(homeownerData, profile: homeownerProfile!)
          : null,
      professional: professionalData != null
          ? Professional.fromJson(professionalData)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      profile: homeownerProfile ??
          (professionalData != null
              ? Profile.fromJson(
                  professionalData['profile'] as Map<String, dynamic>)
              : Profile.empty()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'description': message,
      'preferred_date': date.toIso8601String(),
      'preferred_time': time,
      'decline_reason': declineReason,
      'homeowner_id': homeowner?.id,
      'professional_id': professional?.id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DirectRequest copyWith({
    String? id,
    String? status,
    String? message,
    DateTime? date,
    String? time,
    String? declineReason,
    Homeowner? homeowner,
    Professional? professional,
    DateTime? createdAt,
    DateTime? updatedAt,
    Profile? profile,
  }) {
    return DirectRequest(
      id: id ?? this.id,
      status: status ?? this.status,
      message: message ?? this.message,
      date: date ?? this.date,
      time: time ?? this.time,
      declineReason: declineReason ?? this.declineReason,
      homeowner: homeowner ?? this.homeowner,
      professional: professional ?? this.professional,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profile: profile ?? this.profile,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DirectRequest &&
        other.id == id &&
        other.status == status &&
        other.message == message &&
        other.date == date &&
        other.time == time &&
        other.declineReason == declineReason &&
        other.homeowner == homeowner &&
        other.professional == professional &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.profile == profile;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      status,
      message,
      date,
      time,
      declineReason,
      homeowner,
      professional,
      createdAt,
      updatedAt,
      profile,
    );
  }
}
