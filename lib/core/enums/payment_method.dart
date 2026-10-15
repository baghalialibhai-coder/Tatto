// lib/core/enums/payment_method.dart
enum PaymentMethod {
  cash,
  upi,
  gpay,
  card,
  netBanking,
  online,
  other,
}

extension PaymentMethodExtension on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.gpay:
        return 'GPay / UPI';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.netBanking:
        return 'Net Banking';
      case PaymentMethod.online:
        return 'Online';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethod.cash:
        return '💰';
      case PaymentMethod.upi:
        return '📱';
      case PaymentMethod.gpay:
        return '💳';
      case PaymentMethod.card:
        return '💳';
      case PaymentMethod.netBanking:
        return '🏦';
      case PaymentMethod.online:
        return '🌐';
      case PaymentMethod.other:
        return '📌';
    }
  }
}