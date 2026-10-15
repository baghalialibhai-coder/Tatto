// lib/core/enums/payment_status.dart
enum PaymentStatus {
  paid,
  partial,
  pending,
}

extension PaymentStatusExtension on PaymentStatus {
  String get label {
    switch (this) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.partial:
        return 'Partial';
      case PaymentStatus.pending:
        return 'Pending';
    }
  }

  String get color {
    switch (this) {
      case PaymentStatus.paid:
        return 'green';
      case PaymentStatus.partial:
        return 'orange';
      case PaymentStatus.pending:
        return 'red';
    }
  }
}