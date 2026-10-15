// lib/core/enums/artist_payment_type.dart
enum ArtistPaymentType {
  fixed,              // Fixed Salary
  percentage,         // Percentage Commission
  fixedPlusPercentage, // Fixed + Percentage
  profitShare,        // Profit Share
}

extension ArtistPaymentTypeExtension on ArtistPaymentType {
  String get label {
    switch (this) {
      case ArtistPaymentType.fixed:
        return 'Fixed Salary';
      case ArtistPaymentType.percentage:
        return 'Percentage';
      case ArtistPaymentType.fixedPlusPercentage:
        return 'Fixed + Percentage';
      case ArtistPaymentType.profitShare:
        return 'Profit Share';
    }
  }

  String get shortLabel {
    switch (this) {
      case ArtistPaymentType.fixed:
        return 'Fixed';
      case ArtistPaymentType.percentage:
        return '%';
      case ArtistPaymentType.fixedPlusPercentage:
        return 'Fixed + %';
      case ArtistPaymentType.profitShare:
        return 'Profit Share';
    }
  }
}