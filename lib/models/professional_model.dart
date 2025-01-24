import 'package:flutter/foundation.dart';
import 'package:voltz/models/location_model.dart';
import 'package:voltz/models/payment_info_model.dart';
import 'package:voltz/models/profile_model.dart';
import 'package:voltz/models/service_model.dart';

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
  });

  factory Professional.fromJson(Map<String, dynamic> json) {
    return Professional(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      profileImage: json['profile_image'] as String?,
      bio: json['bio'] as String?,
      hourlyRate: (json['hourly_rate'] as num).toDouble(),
      isVerified: json['is_verified'] as bool? ?? false,
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => Service.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      paymentInfo: json['payment_info'] != null
          ? PaymentInfo.fromJson(json['payment_info'])
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isAvailable: json['is_available'] as bool? ?? true,
      profile: Profile.fromJson(json['profile'] as Map<String, dynamic>),
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
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Professional &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        other.profileImage == profileImage &&
        other.bio == bio &&
        other.hourlyRate == hourlyRate &&
        other.isVerified == isVerified &&
        other.location == location &&
        other.services == services &&
        other.paymentInfo == paymentInfo &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.rating == rating &&
        other.reviewCount == reviewCount &&
        other.specialties == specialties &&
        other.isAvailable == isAvailable &&
        other.profile == profile;
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        email,
        phoneNumber,
        profileImage,
        bio,
        hourlyRate,
        isVerified,
        location,
        services,
        paymentInfo,
        createdAt,
        updatedAt,
        rating,
        reviewCount,
        specialties,
        isAvailable,
        profile,
      );
}
