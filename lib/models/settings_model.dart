// lib/models/settings_model.dart
class SettingsModel {
  final String id;
  final String studioId;
  final String currency;
  final double taxRate;
  final bool enableGST;
  final double cgstRate;
  final double sgstRate;
  final double igstRate;
  final bool applyTaxOnDiscount;
  final String invoicePrefix;
  final String invoiceSuffix;
  final int invoiceStartNumber;
  final bool includeTaxBreakdown;
  final bool includeQRCode;
  final String invoiceFooter;
  final String whatsappGreeting;
  final String whatsappAftercare;
  final String whatsappClosing;
  final bool autoSendWhatsApp;
  final String tattooAftercare;
  final String piercingAftercare;
  final bool enableEmailNotifications;
  final bool enablePushNotifications;
  final bool enableSMSNotifications;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SettingsModel({
    required this.id,
    required this.studioId,
    this.currency = 'INR',
    this.taxRate = 18.0,
    this.enableGST = true,
    this.cgstRate = 9.0,
    this.sgstRate = 9.0,
    this.igstRate = 18.0,
    this.applyTaxOnDiscount = false,
    this.invoicePrefix = 'INV-',
    this.invoiceSuffix = '',
    this.invoiceStartNumber = 1001,
    this.includeTaxBreakdown = true,
    this.includeQRCode = true,
    this.invoiceFooter = 'Thank you for choosing The Temple of Tattooz!',
    this.whatsappGreeting = 'Hi {{customer_name}},\n\nThank you for choosing The Temple of Tattooz!',
    this.whatsappAftercare = 'Please follow the aftercare instructions carefully for best results.\n\nAftercare Guide: {{aftercare_link}}',
    this.whatsappClosing = 'Thank you!\nThe Temple of Tattooz',
    this.autoSendWhatsApp = true,
    this.tattooAftercare = '',
    this.piercingAftercare = '',
    this.enableEmailNotifications = true,
    this.enablePushNotifications = true,
    this.enableSMSNotifications = false,
    required this.createdAt,
    this.updatedAt,
  });

  SettingsModel copyWith({
    String? id,
    String? studioId,
    String? currency,
    double? taxRate,
    bool? enableGST,
    double? cgstRate,
    double? sgstRate,
    double? igstRate,
    bool? applyTaxOnDiscount,
    String? invoicePrefix,
    String? invoiceSuffix,
    int? invoiceStartNumber,
    bool? includeTaxBreakdown,
    bool? includeQRCode,
    String? invoiceFooter,
    String? whatsappGreeting,
    String? whatsappAftercare,
    String? whatsappClosing,
    bool? autoSendWhatsApp,
    String? tattooAftercare,
    String? piercingAftercare,
    bool? enableEmailNotifications,
    bool? enablePushNotifications,
    bool? enableSMSNotifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SettingsModel(
      id: id ?? this.id,
      studioId: studioId ?? this.studioId,
      currency: currency ?? this.currency,
      taxRate: taxRate ?? this.taxRate,
      enableGST: enableGST ?? this.enableGST,
      cgstRate: cgstRate ?? this.cgstRate,
      sgstRate: sgstRate ?? this.sgstRate,
      igstRate: igstRate ?? this.igstRate,
      applyTaxOnDiscount: applyTaxOnDiscount ?? this.applyTaxOnDiscount,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      invoiceSuffix: invoiceSuffix ?? this.invoiceSuffix,
      invoiceStartNumber: invoiceStartNumber ?? this.invoiceStartNumber,
      includeTaxBreakdown: includeTaxBreakdown ?? this.includeTaxBreakdown,
      includeQRCode: includeQRCode ?? this.includeQRCode,
      invoiceFooter: invoiceFooter ?? this.invoiceFooter,
      whatsappGreeting: whatsappGreeting ?? this.whatsappGreeting,
      whatsappAftercare: whatsappAftercare ?? this.whatsappAftercare,
      whatsappClosing: whatsappClosing ?? this.whatsappClosing,
      autoSendWhatsApp: autoSendWhatsApp ?? this.autoSendWhatsApp,
      tattooAftercare: tattooAftercare ?? this.tattooAftercare,
      piercingAftercare: piercingAftercare ?? this.piercingAftercare,
      enableEmailNotifications: enableEmailNotifications ?? this.enableEmailNotifications,
      enablePushNotifications: enablePushNotifications ?? this.enablePushNotifications,
      enableSMSNotifications: enableSMSNotifications ?? this.enableSMSNotifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studioId': studioId,
      'currency': currency,
      'taxRate': taxRate,
      'enableGST': enableGST,
      'cgstRate': cgstRate,
      'sgstRate': sgstRate,
      'igstRate': igstRate,
      'applyTaxOnDiscount': applyTaxOnDiscount,
      'invoicePrefix': invoicePrefix,
      'invoiceSuffix': invoiceSuffix,
      'invoiceStartNumber': invoiceStartNumber,
      'includeTaxBreakdown': includeTaxBreakdown,
      'includeQRCode': includeQRCode,
      'invoiceFooter': invoiceFooter,
      'whatsappGreeting': whatsappGreeting,
      'whatsappAftercare': whatsappAftercare,
      'whatsappClosing': whatsappClosing,
      'autoSendWhatsApp': autoSendWhatsApp,
      'tattooAftercare': tattooAftercare,
      'piercingAftercare': piercingAftercare,
      'enableEmailNotifications': enableEmailNotifications,
      'enablePushNotifications': enablePushNotifications,
      'enableSMSNotifications': enableSMSNotifications,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      id: json['id'] ?? '',
      studioId: json['studioId'] ?? '',
      currency: json['currency'] ?? 'INR',
      taxRate: json['taxRate']?.toDouble() ?? 18.0,
      enableGST: json['enableGST'] ?? true,
      cgstRate: json['cgstRate']?.toDouble() ?? 9.0,
      sgstRate: json['sgstRate']?.toDouble() ?? 9.0,
      igstRate: json['igstRate']?.toDouble() ?? 18.0,
      applyTaxOnDiscount: json['applyTaxOnDiscount'] ?? false,
      invoicePrefix: json['invoicePrefix'] ?? 'INV-',
      invoiceSuffix: json['invoiceSuffix'] ?? '',
      invoiceStartNumber: json['invoiceStartNumber'] ?? 1001,
      includeTaxBreakdown: json['includeTaxBreakdown'] ?? true,
      includeQRCode: json['includeQRCode'] ?? true,
      invoiceFooter: json['invoiceFooter'] ?? 'Thank you for choosing The Temple of Tattooz!',
      whatsappGreeting: json['whatsappGreeting'] ?? '',
      whatsappAftercare: json['whatsappAftercare'] ?? '',
      whatsappClosing: json['whatsappClosing'] ?? '',
      autoSendWhatsApp: json['autoSendWhatsApp'] ?? true,
      tattooAftercare: json['tattooAftercare'] ?? '',
      piercingAftercare: json['piercingAftercare'] ?? '',
      enableEmailNotifications: json['enableEmailNotifications'] ?? true,
      enablePushNotifications: json['enablePushNotifications'] ?? true,
      enableSMSNotifications: json['enableSMSNotifications'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}