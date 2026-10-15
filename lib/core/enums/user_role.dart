// lib/core/enums/user_role.dart
enum UserRole {
  admin,
  artist,
  customer,
}

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.artist:
        return 'Artist';
      case UserRole.customer:
        return 'Customer';
    }
  }

  String get icon {
    switch (this) {
      case UserRole.admin:
        return '🛡️';
      case UserRole.artist:
        return '🎨';
      case UserRole.customer:
        return '👤';
    }
  }
}