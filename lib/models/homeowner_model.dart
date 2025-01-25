import 'profile_model.dart';

class Homeowner {
  final String id;
  final Profile profile;
  final String? phone;
  final String? address;
  final String preferredContactMethod;
  final String? emergencyContact;
  final DateTime createdAt;
  final bool notificationJobUpdates;
  final bool notificationMessages;
  final bool notificationPayments;
  final bool notificationPromotions;
  final double? locationLat;
  final double? locationLng;

  const Homeowner({
    required this.id,
    required this.profile,
    this.phone,
    this.address,
    required this.preferredContactMethod,
    this.emergencyContact,
    required this.createdAt,
    required this.notificationJobUpdates,
    required this.notificationMessages,
    required this.notificationPayments,
    required this.notificationPromotions,
    this.locationLat,
    this.locationLng,
  });

  factory Homeowner.fromJson(Map<String, dynamic> json,
      {required Profile profile}) {
    return Homeowner(
      id: json['id'] as String,
      profile: profile,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      preferredContactMethod: json['preferred_contact_method'] as String,
      emergencyContact: json['emergency_contact'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      notificationJobUpdates: json['notification_job_updates'] as bool? ?? true,
      notificationMessages: json['notification_messages'] as bool? ?? true,
      notificationPayments: json['notification_payments'] as bool? ?? true,
      notificationPromotions: json['notification_promotions'] as bool? ?? false,
      locationLat: json['location_lat'] as double?,
      locationLng: json['location_lng'] as double?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'profile_id': profile.id,
        'phone': phone,
        'address': address,
        'preferred_contact_method': preferredContactMethod,
        'emergency_contact': emergencyContact,
        'created_at': createdAt.toIso8601String(),
        'notification_job_updates': notificationJobUpdates,
        'notification_messages': notificationMessages,
        'notification_payments': notificationPayments,
        'notification_promotions': notificationPromotions,
        'location_lat': locationLat,
        'location_lng': locationLng,
      };

  Homeowner copyWith({
    String? id,
    Profile? profile,
    String? phone,
    String? address,
    String? preferredContactMethod,
    String? emergencyContact,
    DateTime? createdAt,
    bool? notificationJobUpdates,
    bool? notificationMessages,
    bool? notificationPayments,
    bool? notificationPromotions,
    double? locationLat,
    double? locationLng,
  }) {
    return Homeowner(
      id: id ?? this.id,
      profile: profile ?? this.profile,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      preferredContactMethod:
          preferredContactMethod ?? this.preferredContactMethod,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      createdAt: createdAt ?? this.createdAt,
      notificationJobUpdates:
          notificationJobUpdates ?? this.notificationJobUpdates,
      notificationMessages: notificationMessages ?? this.notificationMessages,
      notificationPayments: notificationPayments ?? this.notificationPayments,
      notificationPromotions:
          notificationPromotions ?? this.notificationPromotions,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
    );
  }
}
