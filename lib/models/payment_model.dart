import 'package:flutter/foundation.dart';

@immutable
enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded,
  disputed,
  cancelled
}

enum PaymentMethod {
  creditCard,
  debitCard,
  bankTransfer,
  wallet,
  applePay,
  googlePay
}

class PaymentModel {
  final String id;
  final String jobId;
  final String userId;
  final String professionalId;
  final double amount;
  final double serviceFee;
  final double platformFee;
  final double tax;
  final double total;
  final DateTime timestamp;
  final PaymentStatus status;
  final PaymentMethod method;
  final String? transactionId;
  final String? failureReason;
  final String? receiptUrl;
  final Map<String, dynamic>? metadata;

  const PaymentModel({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.professionalId,
    required this.amount,
    required this.serviceFee,
    required this.platformFee,
    required this.tax,
    required this.total,
    required this.timestamp,
    required this.status,
    required this.method,
    this.transactionId,
    this.failureReason,
    this.receiptUrl,
    this.metadata,
  });

  PaymentModel copyWith({
    String? id,
    String? jobId,
    String? userId,
    String? professionalId,
    double? amount,
    double? serviceFee,
    double? platformFee,
    double? tax,
    double? total,
    DateTime? timestamp,
    PaymentStatus? status,
    PaymentMethod? method,
    String? transactionId,
    String? failureReason,
    String? receiptUrl,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      userId: userId ?? this.userId,
      professionalId: professionalId ?? this.professionalId,
      amount: amount ?? this.amount,
      serviceFee: serviceFee ?? this.serviceFee,
      platformFee: platformFee ?? this.platformFee,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      method: method ?? this.method,
      transactionId: transactionId ?? this.transactionId,
      failureReason: failureReason ?? this.failureReason,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_id': jobId,
      'user_id': userId,
      'professional_id': professionalId,
      'amount': amount,
      'service_fee': serviceFee,
      'platform_fee': platformFee,
      'tax': tax,
      'total': total,
      'timestamp': timestamp.toIso8601String(),
      'status': status.toString().split('.').last,
      'method': method.toString().split('.').last,
      'transaction_id': transactionId,
      'failure_reason': failureReason,
      'receipt_url': receiptUrl,
      'metadata': metadata,
    };
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      jobId: json['job_id'],
      userId: json['user_id'],
      professionalId: json['professional_id'],
      amount: json['amount'].toDouble(),
      serviceFee: json['service_fee'].toDouble(),
      platformFee: json['platform_fee'].toDouble(),
      tax: json['tax'].toDouble(),
      total: json['total'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['method'],
      ),
      transactionId: json['transaction_id'],
      failureReason: json['failure_reason'],
      receiptUrl: json['receipt_url'],
      metadata: json['metadata'],
    );
  }
}

class PaymentMethodModel {
  final String id;
  final String userId;
  final PaymentMethod type;
  final String last4;
  final String brand;
  final String? expiryMonth;
  final String? expiryYear;
  final bool isDefault;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? billingDetails;

  const PaymentMethodModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.last4,
    required this.brand,
    this.expiryMonth,
    this.expiryYear,
    this.isDefault = false,
    this.isEnabled = true,
    required this.createdAt,
    this.updatedAt,
    this.billingDetails,
  });

  PaymentMethodModel copyWith({
    String? id,
    String? userId,
    PaymentMethod? type,
    String? last4,
    String? brand,
    String? expiryMonth,
    String? expiryYear,
    bool? isDefault,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? billingDetails,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      last4: last4 ?? this.last4,
      brand: brand ?? this.brand,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      isDefault: isDefault ?? this.isDefault,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      billingDetails: billingDetails ?? this.billingDetails,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.toString().split('.').last,
      'last4': last4,
      'brand': brand,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'is_default': isDefault,
      'is_enabled': isEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'billing_details': billingDetails,
    };
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'],
      userId: json['user_id'],
      type: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      last4: json['last4'],
      brand: json['brand'],
      expiryMonth: json['expiry_month'],
      expiryYear: json['expiry_year'],
      isDefault: json['is_default'] ?? false,
      isEnabled: json['is_enabled'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      billingDetails: json['billing_details'],
    );
  }

  bool get isExpired {
    if (expiryMonth == null || expiryYear == null) return false;
    final now = DateTime.now();
    final expiry = DateTime(
      int.parse(expiryYear!),
      int.parse(expiryMonth!),
      1,
    );
    return now.isAfter(expiry);
  }

  bool get isValid => isEnabled && !isExpired;

  String get maskedNumber => '**** **** **** $last4';

  String get expiryDate => expiryMonth != null && expiryYear != null
      ? '$expiryMonth/$expiryYear'
      : '';
}

// TODO: Implement split payment support
// TODO: Add multiple currency support
// TODO: Implement automatic recurring payments
// TODO: Add payment dispute handling
// TODO: Implement partial refund functionality
// TODO: Add invoice generation system
// TODO: Implement service fee calculation
// TODO: Add tax calculation and reporting
// TODO: Implement payment gateway integration (Stripe, PayPal)
// TODO: Add payment analytics and reporting
