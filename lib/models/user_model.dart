// lib/models/user_model.dart
import '../core/enums/user_role.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final UserRole role;
  final String? photoUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final String? fcmToken;
  final bool? emailVerified; // ← ADD THIS

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.role,
    this.photoUrl,
    this.isActive = true,
    required this.createdAt,
    this.lastLogin,
    this.fcmToken,
    this.emailVerified,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? mobile,
    UserRole? role,
    String? photoUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLogin,
    String? fcmToken,
    bool? emailVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      fcmToken: fcmToken ?? this.fcmToken,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'role': role.name,
      'photoUrl': photoUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'fcmToken': fcmToken,
      'emailVerified': emailVerified,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      role: UserRole.values.firstWhere(
            (e) => e.name == json['role'],
        orElse: () => UserRole.customer,
      ),
      photoUrl: json['photoUrl'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'])
          : null,
      fcmToken: json['fcmToken'],
      emailVerified: json['emailVerified'],
    );
  }
}