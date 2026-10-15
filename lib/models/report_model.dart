// lib/models/report_model.dart
class ReportModel {
  final String id;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final int totalCustomers;
  final int totalAppointments;
  final double totalRevenue;
  final double totalDiscount;
  final double totalTax;
  final double netRevenue;
  final int paidCount;
  final int pendingCount;
  final int partialCount;
  final Map<String, double> artistRevenue;
  final Map<String, int> servicePopularity;
  final Map<String, double> monthlyRevenue;
  final String? fileUrl;
  final DateTime generatedAt;

  ReportModel({
    required this.id,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    this.totalCustomers = 0,
    this.totalAppointments = 0,
    this.totalRevenue = 0.0,
    this.totalDiscount = 0.0,
    this.totalTax = 0.0,
    this.netRevenue = 0.0,
    this.paidCount = 0,
    this.pendingCount = 0,
    this.partialCount = 0,
    this.artistRevenue = const {},
    this.servicePopularity = const {},
    this.monthlyRevenue = const {},
    this.fileUrl,
    required this.generatedAt,
  });

  ReportModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    int? totalCustomers,
    int? totalAppointments,
    double? totalRevenue,
    double? totalDiscount,
    double? totalTax,
    double? netRevenue,
    int? paidCount,
    int? pendingCount,
    int? partialCount,
    Map<String, double>? artistRevenue,
    Map<String, int>? servicePopularity,
    Map<String, double>? monthlyRevenue,
    String? fileUrl,
    DateTime? generatedAt,
  }) {
    return ReportModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      totalAppointments: totalAppointments ?? this.totalAppointments,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalDiscount: totalDiscount ?? this.totalDiscount,
      totalTax: totalTax ?? this.totalTax,
      netRevenue: netRevenue ?? this.netRevenue,
      paidCount: paidCount ?? this.paidCount,
      pendingCount: pendingCount ?? this.pendingCount,
      partialCount: partialCount ?? this.partialCount,
      artistRevenue: artistRevenue ?? this.artistRevenue,
      servicePopularity: servicePopularity ?? this.servicePopularity,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      fileUrl: fileUrl ?? this.fileUrl,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalCustomers': totalCustomers,
      'totalAppointments': totalAppointments,
      'totalRevenue': totalRevenue,
      'totalDiscount': totalDiscount,
      'totalTax': totalTax,
      'netRevenue': netRevenue,
      'paidCount': paidCount,
      'pendingCount': pendingCount,
      'partialCount': partialCount,
      'artistRevenue': artistRevenue,
      'servicePopularity': servicePopularity,
      'monthlyRevenue': monthlyRevenue,
      'fileUrl': fileUrl,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      totalCustomers: json['totalCustomers'] ?? 0,
      totalAppointments: json['totalAppointments'] ?? 0,
      totalRevenue: json['totalRevenue']?.toDouble() ?? 0.0,
      totalDiscount: json['totalDiscount']?.toDouble() ?? 0.0,
      totalTax: json['totalTax']?.toDouble() ?? 0.0,
      netRevenue: json['netRevenue']?.toDouble() ?? 0.0,
      paidCount: json['paidCount'] ?? 0,
      pendingCount: json['pendingCount'] ?? 0,
      partialCount: json['partialCount'] ?? 0,
      artistRevenue: json['artistRevenue'] != null
          ? Map<String, double>.from(json['artistRevenue'])
          : {},
      servicePopularity: json['servicePopularity'] != null
          ? Map<String, int>.from(json['servicePopularity'])
          : {},
      monthlyRevenue: json['monthlyRevenue'] != null
          ? Map<String, double>.from(json['monthlyRevenue'])
          : {},
      fileUrl: json['fileUrl'],
      generatedAt: DateTime.parse(json['generatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}