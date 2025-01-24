
class NotificationPreferences {
  final String id;
  final String userId;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool smsNotifications;
  final bool jobUpdates;
  final bool messageNotifications;
  final bool paymentNotifications;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationPreferences({
    required this.id,
    required this.userId,
    required this.emailNotifications,
    required this.pushNotifications,
    required this.smsNotifications,
    required this.jobUpdates,
    required this.messageNotifications,
    required this.paymentNotifications,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      emailNotifications: json['email_notifications'] as bool,
      pushNotifications: json['push_notifications'] as bool,
      smsNotifications: json['sms_notifications'] as bool,
      jobUpdates: json['job_updates'] as bool,
      messageNotifications: json['message_notifications'] as bool,
      paymentNotifications: json['payment_notifications'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'sms_notifications': smsNotifications,
      'job_updates': jobUpdates,
      'message_notifications': messageNotifications,
      'payment_notifications': paymentNotifications,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  NotificationPreferences copyWith({
    String? id,
    String? userId,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? smsNotifications,
    bool? jobUpdates,
    bool? messageNotifications,
    bool? paymentNotifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      jobUpdates: jobUpdates ?? this.jobUpdates,
      messageNotifications: messageNotifications ?? this.messageNotifications,
      paymentNotifications: paymentNotifications ?? this.paymentNotifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NotificationPreferences &&
        other.id == id &&
        other.userId == userId &&
        other.emailNotifications == emailNotifications &&
        other.pushNotifications == pushNotifications &&
        other.smsNotifications == smsNotifications &&
        other.jobUpdates == jobUpdates &&
        other.messageNotifications == messageNotifications &&
        other.paymentNotifications == paymentNotifications &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        emailNotifications,
        pushNotifications,
        smsNotifications,
        jobUpdates,
        messageNotifications,
        paymentNotifications,
        createdAt,
        updatedAt,
      );
}
