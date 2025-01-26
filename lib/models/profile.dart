class Profile {
  final String id;
  final String email;
  final String userType;
  final String name;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  Profile({
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
      userType: json['user_type'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
    );
  }
}
