import 'homeowner_model.dart';
import 'professional_model.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'base_service_model.dart';
import 'profile_model.dart';
import '../core/services/logger_service.dart';

@immutable
class Job {
  // Payment status constants
  static const String PAYMENT_STATUS_PENDING = 'payment_pending';
  static const String PAYMENT_STATUS_PROCESSING = 'payment_processing';
  static const String PAYMENT_STATUS_COMPLETED = 'payment_completed';
  static const String PAYMENT_STATUS_FAILED = 'payment_failed';
  static const String PAYMENT_STATUS_REFUNDED = 'payment_refunded';

  // Verification status constants
  static const String VERIFICATION_STATUS_PENDING = 'verification_pending';
  static const String VERIFICATION_STATUS_APPROVED = 'verification_approved';
  static const String VERIFICATION_STATUS_REJECTED = 'verification_rejected';

  // Job status constants
  static const String STATUS_AWAITING_ACCEPTANCE = 'awaiting_acceptance';
  static const String STATUS_SCHEDULED = 'scheduled';
  static const String STATUS_STARTED = 'started';
  static const String STATUS_COMPLETED = 'completed';
  static const String STATUS_CANCELLED = 'cancelled';

  // Request type constants
  static const String REQUEST_TYPE_DIRECT = 'direct';
  static const String REQUEST_TYPE_BROADCAST = 'broadcast';

  // Price constants
  static const double MIN_PRICE = 20.0;
  static const double MAX_PRICE = 1000.0;

  // Valid status transitions
  static const Map<String, List<String>> VALID_STATUS_TRANSITIONS = {
    STATUS_AWAITING_ACCEPTANCE: [STATUS_SCHEDULED, STATUS_CANCELLED],
    STATUS_SCHEDULED: [STATUS_STARTED, STATUS_CANCELLED],
    STATUS_STARTED: [STATUS_COMPLETED, STATUS_CANCELLED],
    STATUS_COMPLETED: [],
    STATUS_CANCELLED: [],
  };

  final String id;
  final String title;
  final String description;
  final double price;
  final String status;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String homeownerId;
  final String? professionalId;
  final String verificationStatus;
  final String paymentStatus;
  final String requestType;
  final Map<String, dynamic>? paymentDetails;
  final Map<String, dynamic>? verificationDetails;
  final DateTime? expiresAt;
  final Homeowner? homeowner;
  final Professional? professional;
  final double? locationLat;
  final double? locationLng;
  final double? radiusKm;
  final BaseService service;
  final String? notes;
  final DateTime? maintenance_due_date;

  const Job({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.status,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.homeownerId,
    this.professionalId,
    required this.verificationStatus,
    required this.paymentStatus,
    required this.requestType,
    this.paymentDetails,
    this.verificationDetails,
    this.expiresAt,
    this.homeowner,
    this.professional,
    this.locationLat,
    this.locationLng,
    this.radiusKm,
    required this.service,
    this.notes,
    this.maintenance_due_date,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    try {
      LoggerService.debug('Starting Job.fromJson conversion');
      LoggerService.debug('Processing homeowner data');
      final homeownerData = json['homeowner'] as Map<String, dynamic>?;
      LoggerService.debug('Processing professional data');
      final professionalData = json['professional'] as Map<String, dynamic>?;
      LoggerService.debug('Processing service data');
      final serviceData = json['service'] as Map<String, dynamic>?;
      if (serviceData == null) {
        LoggerService.error('Service data is null for job ${json['id']}');
        throw Exception('Service data is required but was null');
      }

      // Create homeowner with profile if data exists
      Homeowner? homeowner;
      if (homeownerData != null && homeownerData['profile'] != null) {
        LoggerService.debug('Creating homeowner profile');
        final profile =
            Profile.fromJson(homeownerData['profile'] as Map<String, dynamic>);
        homeowner = Homeowner.fromJson(homeownerData, profile: profile);
      }

      LoggerService.debug('Creating Job object');
      return Job(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(),
        status: json['status'] as String,
        date: DateTime.parse(json['date'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        homeownerId: json['homeowner_id'] as String,
        professionalId: json['professional_id'] as String?,
        verificationStatus: json['verification_status'] as String,
        paymentStatus: json['payment_status'] as String,
        requestType: json['request_type'] as String,
        paymentDetails: json['payment_details'] as Map<String, dynamic>?,
        verificationDetails:
            json['verification_details'] as Map<String, dynamic>?,
        expiresAt: json['expires_at'] != null
            ? DateTime.parse(json['expires_at'] as String)
            : null,
        homeowner: homeowner,
        professional: professionalData != null
            ? Professional.fromJson(professionalData)
            : null,
        locationLat: json['location_lat'] != null
            ? (json['location_lat'] as num).toDouble()
            : null,
        locationLng: json['location_lng'] != null
            ? (json['location_lng'] as num).toDouble()
            : null,
        radiusKm: json['radius_km'] != null
            ? (json['radius_km'] as num).toDouble()
            : null,
        service: BaseService.fromJson(serviceData),
        notes: json['notes'] as String?,
        maintenance_due_date: json['maintenance_due_date'] != null
            ? DateTime.parse(json['maintenance_due_date'] as String)
            : null,
      );
    } catch (e, stackTrace) {
      LoggerService.error('Error in Job.fromJson', e, stackTrace);
      LoggerService.debug('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'status': status,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'homeowner_id': homeownerId,
      'professional_id': professionalId,
      'verification_status': verificationStatus,
      'payment_status': paymentStatus,
      'request_type': requestType,
      'payment_details': paymentDetails,
      'verification_details': verificationDetails,
      'expires_at': expiresAt?.toIso8601String(),
      'homeowner': homeowner?.toJson(),
      'professional': professional?.toJson(),
      'location_lat': locationLat,
      'location_lng': locationLng,
      'radius_km': radiusKm,
      'service': service.toJson(),
      'notes': notes,
      'maintenance_due_date': maintenance_due_date?.toIso8601String(),
    };
  }

  bool canTransitionTo(String newStatus) {
    final validTransitions = VALID_STATUS_TRANSITIONS[status];
    return validTransitions?.contains(newStatus) ?? false;
  }

  String get formattedDate => DateFormat('MMM d, y').format(date);
  String get formattedTime => DateFormat('h:mm a').format(date);

  Job copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? status,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? homeownerId,
    String? professionalId,
    String? verificationStatus,
    String? paymentStatus,
    String? requestType,
    Map<String, dynamic>? paymentDetails,
    Map<String, dynamic>? verificationDetails,
    DateTime? expiresAt,
    Homeowner? homeowner,
    Professional? professional,
    double? locationLat,
    double? locationLng,
    double? radiusKm,
    BaseService? service,
    String? notes,
    DateTime? maintenance_due_date,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      status: status ?? this.status,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      homeownerId: homeownerId ?? this.homeownerId,
      professionalId: professionalId ?? this.professionalId,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      requestType: requestType ?? this.requestType,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      verificationDetails: verificationDetails ?? this.verificationDetails,
      expiresAt: expiresAt ?? this.expiresAt,
      homeowner: homeowner ?? this.homeowner,
      professional: professional ?? this.professional,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      radiusKm: radiusKm ?? this.radiusKm,
      service: service ?? this.service,
      notes: notes ?? this.notes,
      maintenance_due_date: maintenance_due_date ?? this.maintenance_due_date,
    );
  }

  static bool isValidStatus(String status) {
    return [
      STATUS_AWAITING_ACCEPTANCE,
      STATUS_SCHEDULED,
      STATUS_STARTED,
      STATUS_COMPLETED,
      STATUS_CANCELLED
    ].contains(status);
  }

  static bool isValidPaymentStatus(String status) {
    return [
      PAYMENT_STATUS_PENDING,
      PAYMENT_STATUS_PROCESSING,
      PAYMENT_STATUS_COMPLETED,
      PAYMENT_STATUS_FAILED,
      PAYMENT_STATUS_REFUNDED
    ].contains(status);
  }

  static bool isValidVerificationStatus(String status) {
    return [
      VERIFICATION_STATUS_PENDING,
      VERIFICATION_STATUS_APPROVED,
      VERIFICATION_STATUS_REJECTED
    ].contains(status);
  }

  static bool isValidPrice(double price) {
    return price >= MIN_PRICE && price <= MAX_PRICE;
  }

  static bool isValidStatusTransition(String currentStatus, String newStatus) {
    if (!isValidStatus(currentStatus) || !isValidStatus(newStatus)) {
      return false;
    }

    // Allow same status (idempotent updates)
    if (currentStatus == newStatus) {
      return true;
    }

    // Check if the transition is allowed
    final allowedTransitions = VALID_STATUS_TRANSITIONS[currentStatus];
    return allowedTransitions?.contains(newStatus) ?? false;
  }

  // Computed getters
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isAccepted => status.toLowerCase() == 'accepted';
  bool get isInProgress => status.toLowerCase() == 'in_progress';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
}
