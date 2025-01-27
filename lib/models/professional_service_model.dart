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

  const ProfessionalService({
    required this.id,
    required this.professionalId,
    required this.baseService,
    this.customPrice,
    this.customDuration,
    required this.isActive,
    required this.availableToday,
    required this.createdAt,
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
    };
  }

  // Convenience getters to access base service properties
  String get name => baseService.name;
  String get description => baseService.description;
  String get categoryId => baseService.categoryId;

  // Effective values considering customizations
  double get effectivePrice => customPrice ?? baseService.basePrice;
  double? get effectiveDuration => customDuration ?? baseService.durationHours;

  ProfessionalService copyWith({
    String? id,
    String? professionalId,
    BaseService? baseService,
    double? customPrice,
    double? customDuration,
    bool? isActive,
    bool? availableToday,
    DateTime? createdAt,
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
        other.createdAt == createdAt;
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
    );
  }
}
