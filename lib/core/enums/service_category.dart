// lib/core/enums/service_category.dart
enum ServiceCategory {
  tattoo,
  piercing,
  temporary,
  removal,
  other,
}

extension ServiceCategoryExtension on ServiceCategory {
  String get label {
    switch (this) {
      case ServiceCategory.tattoo:
        return 'Tattoo';
      case ServiceCategory.piercing:
        return 'Piercing';
      case ServiceCategory.temporary:
        return 'Temporary Tattoo';
      case ServiceCategory.removal:
        return 'Tattoo Removal';
      case ServiceCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case ServiceCategory.tattoo:
        return '🎨';
      case ServiceCategory.piercing:
        return '💍';
      case ServiceCategory.temporary:
        return '🖌️';
      case ServiceCategory.removal:
        return '🧹';
      case ServiceCategory.other:
        return '📌';
    }
  }
}