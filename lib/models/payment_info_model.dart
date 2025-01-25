import 'package:flutter/foundation.dart';

@immutable
class PaymentInfo {
  final String? id;
  final String? userId;
  final String? accountName;
  final String? accountNumber;
  final String? bankName;
  final String? routingNumber;
  final String? accountType;
  final bool isVerified;
  final DateTime? lastVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PaymentInfo({
    this.id,
    this.userId,
    this.accountName,
    this.accountNumber,
    this.bankName,
    this.routingNumber,
    this.accountType,
    this.isVerified = false,
    this.lastVerified,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      accountName: json['account_name'] as String?,
      accountNumber: json['account_number'] as String?,
      bankName: json['bank_name'] as String?,
      routingNumber: json['routing_number'] as String?,
      accountType: json['account_type'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      lastVerified: json['last_verified'] != null
          ? DateTime.parse(json['last_verified'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'account_name': accountName,
      'account_number': accountNumber,
      'bank_name': bankName,
      'routing_number': routingNumber,
      'account_type': accountType,
      'is_verified': isVerified,
      'last_verified': lastVerified?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PaymentInfo copyWith({
    String? id,
    String? userId,
    String? accountName,
    String? accountNumber,
    String? bankName,
    String? routingNumber,
    String? accountType,
    bool? isVerified,
    DateTime? lastVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentInfo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      routingNumber: routingNumber ?? this.routingNumber,
      accountType: accountType ?? this.accountType,
      isVerified: isVerified ?? this.isVerified,
      lastVerified: lastVerified ?? this.lastVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentInfo &&
        other.id == id &&
        other.userId == userId &&
        other.accountName == accountName &&
        other.accountNumber == accountNumber &&
        other.bankName == bankName &&
        other.routingNumber == routingNumber &&
        other.accountType == accountType &&
        other.isVerified == isVerified &&
        other.lastVerified == lastVerified &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        userId,
        accountName,
        accountNumber,
        bankName,
        routingNumber,
        accountType,
        isVerified,
        lastVerified,
        createdAt,
        updatedAt,
      );
}
