import 'package:flutter/foundation.dart';
import 'profile.dart';
import 'service.dart';

class Professional {
  final Profile profile;
  final double rating;
  final int jobsCompleted;
  final double hourlyRate;
  final String? profileImage;
  final bool isAvailable;
  final List<String> specialties;
  final String? licenseNumber;
  final int yearsOfExperience;
  final bool isVerified;
  final String? phone;
  final List<Service> services;

  Professional({
    required this.profile,
    required this.rating,
    required this.jobsCompleted,
    required this.hourlyRate,
    this.profileImage,
    required this.isAvailable,
    required this.specialties,
    this.licenseNumber,
    required this.yearsOfExperience,
    required this.isVerified,
    this.phone,
    required this.services,
  });

  factory Professional.fromJson(
      Map<String, dynamic> json, Profile profile, List<Service> services) {
    return Professional(
      profile: profile,
      rating: (json['rating'] as num).toDouble(),
      jobsCompleted: json['jobs_completed'] as int,
      hourlyRate: (json['hourly_rate'] as num).toDouble(),
      profileImage: json['profile_image'] as String?,
      isAvailable: json['is_available'] as bool,
      specialties: List<String>.from(json['specialties'] as List),
      licenseNumber: json['license_number'] as String?,
      yearsOfExperience: json['years_of_experience'] as int,
      isVerified: json['is_verified'] as bool,
      phone: json['phone'] as String?,
      services: services,
    );
  }
}
