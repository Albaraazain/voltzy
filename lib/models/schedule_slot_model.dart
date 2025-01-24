import '../models/job_model.dart';

class ScheduleSlot {
  static const String STATUS_AVAILABLE = 'AVAILABLE';
  static const String STATUS_BOOKED = 'BOOKED';
  static const String STATUS_BLOCKED = 'BLOCKED';

  final String id;
  final String professionalId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String status;
  final String? jobId;
  final Job? job;
  final String? recurringRule;
  final DateTime createdAt;
  final DateTime updatedAt;

  ScheduleSlot({
    required this.id,
    required this.professionalId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.jobId,
    this.job,
    this.recurringRule,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ScheduleSlot.fromJson(Map<String, dynamic> json) {
    return ScheduleSlot(
      id: json['id'] as String,
      professionalId: json['professional_id'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      status: json['status'] as String,
      jobId: json['job_id'] as String?,
      job: json['job'] != null ? Job.fromJson(json['job']) : null,
      recurringRule: json['recurring_rule'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professional_id': professionalId,
      'date': date.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'job_id': jobId,
      'job': job?.toJson(),
      'recurring_rule': recurringRule,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ScheduleSlot copyWith({
    String? id,
    String? professionalId,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? status,
    String? jobId,
    Job? job,
    String? recurringRule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ScheduleSlot(
      id: id ?? this.id,
      professionalId: professionalId ?? this.professionalId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      jobId: jobId ?? this.jobId,
      job: job ?? this.job,
      recurringRule: recurringRule ?? this.recurringRule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
