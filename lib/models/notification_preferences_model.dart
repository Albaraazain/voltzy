class NotificationPreferences {
  final bool jobUpdates;
  final bool messages;
  final bool payments;
  final bool promotions;
  final bool quietHoursEnabled;
  final int quietHoursStartHour;
  final int quietHoursStartMinute;
  final int quietHoursEndHour;
  final int quietHoursEndMinute;

  const NotificationPreferences({
    this.jobUpdates = true,
    this.messages = true,
    this.payments = true,
    this.promotions = false,
    this.quietHoursEnabled = false,
    this.quietHoursStartHour = 22,
    this.quietHoursStartMinute = 0,
    this.quietHoursEndHour = 7,
    this.quietHoursEndMinute = 0,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      jobUpdates: json['job_updates'] as bool? ?? true,
      messages: json['messages'] as bool? ?? true,
      payments: json['payments'] as bool? ?? true,
      promotions: json['promotions'] as bool? ?? false,
      quietHoursEnabled: json['quiet_hours_enabled'] as bool? ?? false,
      quietHoursStartHour: json['quiet_hours_start_hour'] as int? ?? 22,
      quietHoursStartMinute: json['quiet_hours_start_minute'] as int? ?? 0,
      quietHoursEndHour: json['quiet_hours_end_hour'] as int? ?? 7,
      quietHoursEndMinute: json['quiet_hours_end_minute'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'job_updates': jobUpdates,
        'messages': messages,
        'payments': payments,
        'promotions': promotions,
        'quiet_hours_enabled': quietHoursEnabled,
        'quiet_hours_start_hour': quietHoursStartHour,
        'quiet_hours_start_minute': quietHoursStartMinute,
        'quiet_hours_end_hour': quietHoursEndHour,
        'quiet_hours_end_minute': quietHoursEndMinute,
      };

  NotificationPreferences copyWith({
    bool? jobUpdates,
    bool? messages,
    bool? payments,
    bool? promotions,
    bool? quietHoursEnabled,
    int? quietHoursStartHour,
    int? quietHoursStartMinute,
    int? quietHoursEndHour,
    int? quietHoursEndMinute,
  }) {
    return NotificationPreferences(
      jobUpdates: jobUpdates ?? this.jobUpdates,
      messages: messages ?? this.messages,
      payments: payments ?? this.payments,
      promotions: promotions ?? this.promotions,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStartHour: quietHoursStartHour ?? this.quietHoursStartHour,
      quietHoursStartMinute:
          quietHoursStartMinute ?? this.quietHoursStartMinute,
      quietHoursEndHour: quietHoursEndHour ?? this.quietHoursEndHour,
      quietHoursEndMinute: quietHoursEndMinute ?? this.quietHoursEndMinute,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationPreferences &&
        other.jobUpdates == jobUpdates &&
        other.messages == messages &&
        other.payments == payments &&
        other.promotions == promotions &&
        other.quietHoursEnabled == quietHoursEnabled &&
        other.quietHoursStartHour == quietHoursStartHour &&
        other.quietHoursStartMinute == quietHoursStartMinute &&
        other.quietHoursEndHour == quietHoursEndHour &&
        other.quietHoursEndMinute == quietHoursEndMinute;
  }

  @override
  int get hashCode {
    return Object.hash(
      jobUpdates,
      messages,
      payments,
      promotions,
      quietHoursEnabled,
      quietHoursStartHour,
      quietHoursStartMinute,
      quietHoursEndHour,
      quietHoursEndMinute,
    );
  }
}
