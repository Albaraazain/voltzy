import 'package:flutter/foundation.dart';

import 'base_service_model.dart';
import 'profile_model.dart';
import 'professional_service_model.dart';
import 'location_model.dart';
import 'payment_info_model.dart';
import 'notification_preferences_model.dart';

@immutable
class Professional {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImage;
  final String? bio;
  final double? hourlyRate;
  final bool isVerified;
  final String? location;
  final List<ProfessionalService> services;
  final Map<String, dynamic>? paymentInfo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? rating;
  final int? reviewCount;
  final List<String> specialties;
  final bool isAvailable;
  final Profile? profile;
  final String? phone;
  final String? licenseNumber;
  final int? yearsOfExperience;
  final Map<String, dynamic>? notificationPreferences;
  final double? locationLat;
  final double? locationLng;
  final int? jobsCompleted;

  const Professional({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImage,
    this.bio,
    this.hourlyRate,
    this.isVerified = false,
    this.location,
    required this.services,
    this.paymentInfo,
    this.createdAt,
    this.updatedAt,
    this.rating,
    this.reviewCount,
    this.specialties = const [],
    this.isAvailable = true,
    this.profile,
    this.phone,
    this.licenseNumber,
    this.yearsOfExperience,
    this.notificationPreferences,
    this.locationLat,
    this.locationLng,
    this.jobsCompleted,
  });

  factory Professional.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] != null
        ? Profile.fromJson(json['profile'] as Map<String, dynamic>)
        : null;

    final services =
        (json['professional_services'] as List<dynamic>?)?.map((ps) {
              final baseService =
                  BaseService.fromJson(ps['service'] as Map<String, dynamic>);
              return ProfessionalService.fromJson(ps, baseService);
            }).toList() ??
            [];

    return Professional(
      id: json['id'] as String,
      name: profile?.name ?? '',
      email: profile?.email ?? '',
      phoneNumber: json['phone_number'] as String?,
      profileImage: json['profile_image'] as String?,
      bio: json['bio'] as String?,
      hourlyRate: json['hourly_rate'] != null
          ? (json['hourly_rate'] as num).toDouble()
          : null,
      isVerified: json['is_verified'] as bool? ?? false,
      location: json['location'] as String?,
      services: services,
      paymentInfo: json['payment_info'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['review_count'] as int?,
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isAvailable: json['is_available'] as bool? ?? true,
      profile: profile,
      phone: json['phone'] as String?,
      licenseNumber: json['license_number'] as String?,
      yearsOfExperience: json['years_of_experience'] as int?,
      notificationPreferences:
          json['notification_preferences'] as Map<String, dynamic>?,
      locationLat: json['location_lat'] != null
          ? (json['location_lat'] as num).toDouble()
          : null,
      locationLng: json['location_lng'] != null
          ? (json['location_lng'] as num).toDouble()
          : null,
      jobsCompleted: json['jobs_completed'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'profile_image': profileImage,
      'bio': bio,
      'hourly_rate': hourlyRate,
      'is_verified': isVerified,
      'location': location,
      'payment_info': paymentInfo,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'rating': rating,
      'review_count': reviewCount,
      'specialties': specialties,
      'is_available': isAvailable,
      'phone': phone,
      'license_number': licenseNumber,
      'years_of_experience': yearsOfExperience,
      'notification_preferences': notificationPreferences,
      'location_lat': locationLat,
      'location_lng': locationLng,
      'jobs_completed': jobsCompleted,
    };
  }

  Professional copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImage,
    String? bio,
    double? hourlyRate,
    bool? isVerified,
    String? location,
    List<ProfessionalService>? services,
    Map<String, dynamic>? paymentInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    int? reviewCount,
    List<String>? specialties,
    bool? isAvailable,
    Profile? profile,
    String? phone,
    String? licenseNumber,
    int? yearsOfExperience,
    Map<String, dynamic>? notificationPreferences,
    double? locationLat,
    double? locationLng,
    int? jobsCompleted,
  }) {
    return Professional(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      isVerified: isVerified ?? this.isVerified,
      location: location ?? this.location,
      services: services ?? this.services,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      specialties: specialties ?? this.specialties,
      isAvailable: isAvailable ?? this.isAvailable,
      profile: profile ?? this.profile,
      phone: phone ?? this.phone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      jobsCompleted: jobsCompleted ?? this.jobsCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Professional &&
        other.id == id &&
        other.profile == profile &&
        other.profileImage == profileImage &&
        other.phone == phone &&
        other.licenseNumber == licenseNumber &&
        other.yearsOfExperience == yearsOfExperience &&
        other.hourlyRate == hourlyRate &&
        other.rating == rating &&
        other.jobsCompleted == jobsCompleted &&
        other.isAvailable == isAvailable &&
        other.isVerified == isVerified &&
        other.services == services &&
        other.specialties == specialties &&
        other.paymentInfo == paymentInfo &&
        other.notificationPreferences == notificationPreferences &&
        other.locationLat == locationLat &&
        other.locationLng == locationLng;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      profile,
      profileImage,
      phone,
      licenseNumber,
      yearsOfExperience,
      hourlyRate,
      rating,
      jobsCompleted,
      isAvailable,
      isVerified,
      Object.hashAll(services),
      Object.hashAll(specialties),
      paymentInfo,
      notificationPreferences,
      locationLat,
      locationLng,
    );
  }
}
