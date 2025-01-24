import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'professional_model.dart';
import 'homeowner_model.dart';

@immutable
class DirectRequest {
  static const String STATUS_PENDING = 'pending';
  static const String STATUS_ACCEPTED = 'accepted';
  static const String STATUS_DECLINED = 'declined';
  static const String STATUS_CANCELLED = 'cancelled';
  static const String STATUS_RESCHEDULED = 'rescheduled';
  static const String STATUS_IN_PROGRESS = 'in_progress';
  static const String STATUS_COMPLETED = 'completed';

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

  String get homeownerId => homeowner?.id ?? '';
  String get professionalId => professional?.id ?? '';

  String get statusText {
    switch (status) {
      case STATUS_PENDING:
        return 'Pending';
      case STATUS_ACCEPTED:
        return 'Accepted';
      case STATUS_DECLINED:
        return 'Declined';
      case STATUS_CANCELLED:
        return 'Cancelled';
      case STATUS_RESCHEDULED:
        return 'Rescheduled';
      case STATUS_IN_PROGRESS:
        return 'In Progress';
      case STATUS_COMPLETED:
        return 'Completed';
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
  });

  factory DirectRequest.fromJson(Map<String, dynamic> json) {
    return DirectRequest(
      id: json['id'] as String,
      status: json['status'] as String,
      message: json['message'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      declineReason: json['decline_reason'] as String?,
      homeowner: json['homeowner'] != null
          ? Homeowner.fromJson(json['homeowner'] as Map<String, dynamic>)
          : null,
      professional: json['professional'] != null
          ? Professional.fromJson(json['professional'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'message': message,
      'date': date.toIso8601String(),
      'time': time,
      'decline_reason': declineReason,
      'homeowner': homeowner?.toJson(),
      'professional': professional?.toJson(),
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
        other.updatedAt == updatedAt;
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
    );
  }
}
