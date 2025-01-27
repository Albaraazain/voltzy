import 'package:flutter/foundation.dart';
import 'base_service_model.dart';

@immutable
class ProfessionalService {
  final String id;
  final String professionalId;
  final BaseService baseService;
  final double? customPrice;
  final double? customDuration;
  final bool isActive;
  final bool availableToday;
  final DateTime createdAt;
  final Map<String, dynamic>? availabilitySchedule;
  final Map<String, dynamic>? serviceArea;
  final List<String> serviceTags;
  final bool emergencyService;
  final double? emergencyFee;
  final List<String> requirements;
  final double? rating;
  final int? jobsCompleted;
  final bool? isPopular;

  const ProfessionalService({
    required this.id,
    required this.professionalId,
    required this.baseService,
    this.customPrice,
    this.customDuration,
    required this.isActive,
    required this.availableToday,
    required this.createdAt,
    this.availabilitySchedule,
    this.serviceArea,
    this.serviceTags = const [],
    this.emergencyService = false,
    this.emergencyFee,
    this.requirements = const [],
    this.rating,
    this.jobsCompleted,
    this.isPopular,
  });

  factory ProfessionalService.fromJson(
      Map<String, dynamic> json, BaseService baseService) {
    return ProfessionalService(
      id: json['service_id'] as String,
      professionalId: json['professional_id'] as String,
      baseService: baseService,
      customPrice: json['custom_price'] != null
          ? (json['custom_price'] as num).toDouble()
          : null,
      customDuration: json['custom_duration'] != null
          ? (json['custom_duration'] as num).toDouble()
          : null,
      isActive: json['is_active'] as bool? ?? false,
      availableToday: json['available_today'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      availabilitySchedule: json['availability_schedule'] != null
          ? Map<String, dynamic>.from(json['availability_schedule'] as Map)
          : null,
      serviceArea: json['service_area'] != null
          ? Map<String, dynamic>.from(json['service_area'] as Map)
          : null,
      serviceTags: (json['service_tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      emergencyService: json['emergency_service'] as bool? ?? false,
      emergencyFee: json['emergency_fee'] != null
          ? (json['emergency_fee'] as num).toDouble()
          : null,
      requirements: (json['requirements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      jobsCompleted: json['jobs_completed'] as int?,
      isPopular: json['is_popular'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': id,
      'professional_id': professionalId,
      'custom_price': customPrice,
      'custom_duration': customDuration,
      'is_active': isActive,
      'available_today': availableToday,
      'created_at': createdAt.toIso8601String(),
      'availability_schedule': availabilitySchedule,
      'service_area': serviceArea,
      'service_tags': serviceTags,
      'emergency_service': emergencyService,
      'emergency_fee': emergencyFee,
      'requirements': requirements,
      'rating': rating,
      'jobs_completed': jobsCompleted,
      'is_popular': isPopular,
    };
  }

  // Convenience getters to access base service properties
  String get name => baseService.name;
  String get description => baseService.description;
  String get categoryId => baseService.categoryId;

  // Effective values considering customizations
  double get effectivePrice => customPrice ?? baseService.basePrice;
  double? get effectiveDuration => customDuration ?? baseService.durationHours;

  // Convenience getters for service area
  String get serviceAreaCenter => serviceArea?['center'] as String? ?? 'Boston';
  int get serviceAreaRadius => (serviceArea?['radius'] as num?)?.toInt() ?? 25;
  String get serviceAreaUnit => serviceArea?['unit'] as String? ?? 'miles';

  // Convenience getters for availability schedule
  Map<String, dynamic>? get weekdaySchedule =>
      availabilitySchedule?['weekdays'] as Map<String, dynamic>?;
  Map<String, dynamic>? get weekendSchedule =>
      availabilitySchedule?['weekend'] as Map<String, dynamic>?;
  String get weekdayStart => weekdaySchedule?['start'] as String? ?? '08:00';
  String get weekdayEnd => weekdaySchedule?['end'] as String? ?? '18:00';
  String get weekendStart => weekendSchedule?['start'] as String? ?? '09:00';
  String get weekendEnd => weekendSchedule?['end'] as String? ?? '17:00';

  ProfessionalService copyWith({
    String? id,
    String? professionalId,
    BaseService? baseService,
    double? customPrice,
    double? customDuration,
    bool? isActive,
    bool? availableToday,
    DateTime? createdAt,
    Map<String, dynamic>? availabilitySchedule,
    Map<String, dynamic>? serviceArea,
    List<String>? serviceTags,
    bool? emergencyService,
    double? emergencyFee,
    List<String>? requirements,
    double? rating,
    int? jobsCompleted,
    bool? isPopular,
  }) {
    return ProfessionalService(
      id: id ?? this.id,
      professionalId: professionalId ?? this.professionalId,
      baseService: baseService ?? this.baseService,
      customPrice: customPrice ?? this.customPrice,
      customDuration: customDuration ?? this.customDuration,
      isActive: isActive ?? this.isActive,
      availableToday: availableToday ?? this.availableToday,
      createdAt: createdAt ?? this.createdAt,
      availabilitySchedule: availabilitySchedule ?? this.availabilitySchedule,
      serviceArea: serviceArea ?? this.serviceArea,
      serviceTags: serviceTags ?? this.serviceTags,
      emergencyService: emergencyService ?? this.emergencyService,
      emergencyFee: emergencyFee ?? this.emergencyFee,
      requirements: requirements ?? this.requirements,
      rating: rating ?? this.rating,
      jobsCompleted: jobsCompleted ?? this.jobsCompleted,
      isPopular: isPopular ?? this.isPopular,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfessionalService &&
        other.id == id &&
        other.professionalId == professionalId &&
        other.baseService == baseService &&
        other.customPrice == customPrice &&
        other.customDuration == customDuration &&
        other.isActive == isActive &&
        other.availableToday == availableToday &&
        other.createdAt == createdAt &&
        other.availabilitySchedule == availabilitySchedule &&
        other.serviceArea == serviceArea &&
        other.serviceTags == serviceTags &&
        other.emergencyService == emergencyService &&
        other.emergencyFee == emergencyFee &&
        other.requirements == requirements &&
        other.rating == rating &&
        other.jobsCompleted == jobsCompleted &&
        other.isPopular == isPopular;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      professionalId,
      baseService,
      customPrice,
      customDuration,
      isActive,
      availableToday,
      createdAt,
      availabilitySchedule,
      serviceArea,
      serviceTags,
      emergencyService,
      emergencyFee,
      requirements,
      rating,
      jobsCompleted,
      isPopular,
    );
  }
}
