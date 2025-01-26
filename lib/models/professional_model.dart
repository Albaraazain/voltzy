import 'package:flutter/foundation.dart';
import 'package:voltz/models/location_model.dart';
import 'package:voltz/models/payment_info_model.dart';
import 'package:voltz/models/profile_model.dart';
import 'package:voltz/models/service_model.dart';
import 'package:voltz/models/notification_preferences_model.dart';

@immutable
class Professional {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImage;
  final String? bio;
  final double hourlyRate;
  final bool isVerified;
  final Location? location;
  final List<Service> services;
  final PaymentInfo? paymentInfo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double rating;
  final int reviewCount;
  final List<String> specialties;
  final bool isAvailable;
  final Profile profile;
  final String? phone;
  final String? licenseNumber;
  final int yearsOfExperience;
  final NotificationPreferences? notificationPreferences;
  final double? locationLat;
  final double? locationLng;
  final int jobsCompleted;

  const Professional({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImage,
    this.bio,
    required this.hourlyRate,
    required this.isVerified,
    this.location,
    required this.services,
    this.paymentInfo,
    required this.createdAt,
    required this.updatedAt,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.specialties = const [],
    this.isAvailable = true,
    required this.profile,
    this.phone,
    this.licenseNumber,
    required this.yearsOfExperience,
    this.notificationPreferences,
    this.locationLat,
    this.locationLng,
    this.jobsCompleted = 0,
  });

  factory Professional.fromJson(Map<String, dynamic> json) {
    final profile = Profile.fromJson(json['profile'] as Map<String, dynamic>);

    // Parse services from professional_services junction table
    final services = <Service>[];
    if (json['professional_services'] != null) {
      final professionalServices =
          json['professional_services'] as List<dynamic>;
      services.addAll(professionalServices.map(
          (ps) => Service.fromJson(ps['service'] as Map<String, dynamic>)));
    }

    return Professional(
      id: json['id'] as String,
      name: profile.name,
      email: profile.email,
      phoneNumber: json['phone_number'] as String?,
      profileImage: json['profile_image'] as String?,
      bio: json['bio'] as String?,
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['is_verified'] as bool? ?? false,
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      services: services,
      paymentInfo: json['payment_info'] != null
          ? PaymentInfo.fromJson(json['payment_info'])
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isAvailable: json['is_available'] as bool? ?? true,
      profile: profile,
      phone: json['phone'] as String?,
      licenseNumber: json['license_number'] as String?,
      yearsOfExperience: json['years_of_experience'] as int? ?? 0,
      notificationPreferences: json['notification_preferences'] != null
          ? NotificationPreferences.fromJson(
              json['notification_preferences'] as Map<String, dynamic>)
          : null,
      locationLat: json['location_lat'] as double?,
      locationLng: json['location_lng'] as double?,
      jobsCompleted: json['jobs_completed'] as int? ?? 0,
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
      'location': location?.toJson(),
      'services': services.map((e) => e.toJson()).toList(),
      'payment_info': paymentInfo?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'rating': rating,
      'review_count': reviewCount,
      'specialties': specialties,
      'is_available': isAvailable,
      'profile': profile.toJson(),
      'phone': phone,
      'license_number': licenseNumber,
      'years_of_experience': yearsOfExperience,
      'notification_preferences': notificationPreferences?.toJson(),
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
    Location? location,
    List<Service>? services,
    PaymentInfo? paymentInfo,
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
    NotificationPreferences? notificationPreferences,
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
