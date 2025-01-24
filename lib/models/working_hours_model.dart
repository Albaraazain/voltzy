import 'package:flutter/foundation.dart';

@immutable
class WorkingHours {
  final String id;
  final String professionalId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isWorkingDay;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkingHours({
    required this.id,
    required this.professionalId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isWorkingDay,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      id: json['id'] as String,
      professionalId: json['professional_id'] as String,
      dayOfWeek: json['day_of_week'] as int,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      isWorkingDay: json['is_working_day'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professional_id': professionalId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'is_working_day': isWorkingDay,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  WorkingHours copyWith({
    String? id,
    String? professionalId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    bool? isWorkingDay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkingHours(
      id: id ?? this.id,
      professionalId: professionalId ?? this.professionalId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isWorkingDay: isWorkingDay ?? this.isWorkingDay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get dayName {
    switch (dayOfWeek) {
      case 0:
        return 'Sunday';
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      default:
        return 'Unknown';
    }
  }

  static String getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 0:
        return 'Sunday';
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      default:
        return 'Unknown';
    }
  }

  static List<WorkingHours> defaults({required String professionalId}) {
    final now = DateTime.now();
    return List.generate(7, (index) {
      return WorkingHours(
        id: '',
        professionalId: professionalId,
        dayOfWeek: index,
        startTime: '09:00',
        endTime: '17:00',
        isWorkingDay: index < 5, // Monday-Friday are working days by default
        createdAt: now,
        updatedAt: now,
      );
    });
  }
}
