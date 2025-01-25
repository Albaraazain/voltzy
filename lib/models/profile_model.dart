import 'package:flutter/foundation.dart';

enum UserType {
  professional,
  homeowner;

  String get value => toString().split('.').last;
}

@immutable
class Profile {
  final String id;
  final String email;
  final UserType userType;
  final String name;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const Profile({
    required this.id,
    required this.email,
    required this.userType,
    required this.name,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      email: json['email'] as String,
      userType: UserType.values.firstWhere(
        (e) => e.value == (json['user_type'] as String).toLowerCase(),
        orElse: () => UserType.homeowner,
      ),
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_type': userType.value,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  Profile copyWith({
    String? id,
    String? email,
    UserType? userType,
    String? name,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Profile &&
        other.id == id &&
        other.email == email &&
        other.userType == userType &&
        other.name == name &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        email,
        userType,
        name,
        createdAt,
        lastLoginAt,
      );

  factory Profile.empty() {
    return Profile(
      id: '',
      email: '',
      userType: UserType.homeowner,
      name: '',
      createdAt: DateTime.now(),
    );
  }
}
