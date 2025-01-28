import 'package:flutter/foundation.dart';

@immutable
class ClientServiceHistory {
  final String id;
  final String homeownerId;
  final String professionalId;
  final String serviceName;
  final double amount;
  final String status;
  final DateTime serviceDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClientServiceHistory({
    required this.id,
    required this.homeownerId,
    required this.professionalId,
    required this.serviceName,
    required this.amount,
    required this.status,
    required this.serviceDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClientServiceHistory.fromJson(Map<String, dynamic> json) {
    return ClientServiceHistory(
      id: json['id'] as String,
      homeownerId: json['homeowner_id'] as String,
      professionalId: json['professional_id'] as String,
      serviceName: json['service_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      serviceDate: DateTime.parse(json['service_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'homeowner_id': homeownerId,
        'professional_id': professionalId,
        'service_name': serviceName,
        'amount': amount,
        'status': status,
        'service_date': serviceDate.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  ClientServiceHistory copyWith({
    String? id,
    String? homeownerId,
    String? professionalId,
    String? serviceName,
    double? amount,
    String? status,
    DateTime? serviceDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClientServiceHistory(
      id: id ?? this.id,
      homeownerId: homeownerId ?? this.homeownerId,
      professionalId: professionalId ?? this.professionalId,
      serviceName: serviceName ?? this.serviceName,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      serviceDate: serviceDate ?? this.serviceDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
