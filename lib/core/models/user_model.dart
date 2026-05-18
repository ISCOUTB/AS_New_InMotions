class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.role = 'student',
    required this.createdAt,
    this.lastLoginAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    String? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?,
      role: map['role'] as String? ?? 'student',
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastLoginAt: map['lastLoginAt'] == null ? null : DateTime.parse(map['lastLoginAt'] as String),
    );
  }
}
