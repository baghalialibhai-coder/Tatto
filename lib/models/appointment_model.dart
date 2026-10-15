// lib/models/appointment_model.dart
enum AppointmentStatus {
  scheduled,
  confirmed,
  inProgress,
  completed,
  cancelled,
  rescheduled,
  noShow,
}

class AppointmentModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String artistId;
  final String artistName;
  final String serviceId;
  final String serviceName;
  final DateTime date;
  final String time;
  final int duration;
  final AppointmentStatus status;
  final double amount;
  final double? discount;
  final double finalAmount;
  final String? notes;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // ✅ ADD BRANCH FIELDS
  final String branchId;
  final String branchName;

  AppointmentModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.artistId,
    required this.artistName,
    required this.serviceId,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.duration,
    this.status = AppointmentStatus.scheduled,
    required this.amount,
    this.discount,
    required this.finalAmount,
    this.notes,
    this.cancellationReason,
    required this.createdAt,
    this.updatedAt,
    this.branchId = '', // ✅ DEFAULT VALUE
    this.branchName = '', // ✅ DEFAULT VALUE
  });

  AppointmentModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? artistId,
    String? artistName,
    String? serviceId,
    String? serviceName,
    DateTime? date,
    String? time,
    int? duration,
    AppointmentStatus? status,
    double? amount,
    double? discount,
    double? finalAmount,
    String? notes,
    String? cancellationReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? branchId,
    String? branchName,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      artistId: artistId ?? this.artistId,
      artistName: artistName ?? this.artistName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      date: date ?? this.date,
      time: time ?? this.time,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      discount: discount ?? this.discount,
      finalAmount: finalAmount ?? this.finalAmount,
      notes: notes ?? this.notes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
    );
  }

  bool get isUpcoming => date.isAfter(DateTime.now()) ||
      (date.isAtSameMomentAs(DateTime.now()) &&
          _timeToMinutes(time) > _timeToMinutes(DateTime.now().toString().split(' ')[1]));

  bool get isPast => date.isBefore(DateTime.now()) ||
      (date.isAtSameMomentAs(DateTime.now()) &&
          _timeToMinutes(time) < _timeToMinutes(DateTime.now().toString().split(' ')[1]));

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1].split(' ')[0]);
    if (time.contains('PM') && hour != 12) hour += 12;
    if (time.contains('AM') && hour == 12) hour = 0;
    return hour * 60 + minute;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'artistId': artistId,
      'artistName': artistName,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'date': date.toIso8601String(),
      'time': time,
      'duration': duration,
      'status': status.name,
      'amount': amount,
      'discount': discount,
      'finalAmount': finalAmount,
      'notes': notes,
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'branchId': branchId, // ✅ ADDED
      'branchName': branchName, // ✅ ADDED
    };
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      artistId: json['artistId'] ?? '',
      artistName: json['artistName'] ?? '',
      serviceId: json['serviceId'] ?? '',
      serviceName: json['serviceName'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      time: json['time'] ?? '',
      duration: json['duration'] ?? 0,
      status: AppointmentStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => AppointmentStatus.scheduled,
      ),
      amount: json['amount']?.toDouble() ?? 0.0,
      discount: json['discount']?.toDouble(),
      finalAmount: json['finalAmount']?.toDouble() ?? 0.0,
      notes: json['notes'],
      cancellationReason: json['cancellationReason'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      branchId: json['branchId'] ?? '', // ✅ ADDED
      branchName: json['branchName'] ?? '', // ✅ ADDED
    );
  }
}