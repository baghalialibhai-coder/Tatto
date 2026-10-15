// lib/models/consent_form_model.dart
import 'customer_model.dart';
import 'service_model.dart';
import 'appointment_model.dart';
import 'payment_model.dart';
import 'artist_model.dart';

class ConsentFormModel {
  final String id;
  final CustomerModel customer;
  final ServiceModel service;
  final AppointmentModel appointment;
  final PaymentModel payment;
  final String artistId;
  final String artistName;
  final List<String> healthConditions;
  final bool consentConfirmed;
  final String? signatureUrl;
  final String? customerPhotoUrl;
  final bool aftercareReceived;
  final String? aftercarePdfUrl;
  final String? notes;
  final String? internalNotes;
  final bool isDraft;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? submittedAt;

  ConsentFormModel({
    required this.id,
    required this.customer,
    required this.service,
    required this.appointment,
    required this.payment,
    required this.artistId,
    required this.artistName,
    this.healthConditions = const [],
    this.consentConfirmed = false,
    this.signatureUrl,
    this.customerPhotoUrl,
    this.aftercareReceived = false,
    this.aftercarePdfUrl,
    this.notes,
    this.internalNotes,
    this.isDraft = true,
    this.status = 'draft',
    required this.createdAt,
    this.updatedAt,
    this.submittedAt,
  });

  ConsentFormModel copyWith({
    String? id,
    CustomerModel? customer,
    ServiceModel? service,
    AppointmentModel? appointment,
    PaymentModel? payment,
    String? artistId,
    String? artistName,
    List<String>? healthConditions,
    bool? consentConfirmed,
    String? signatureUrl,
    String? customerPhotoUrl,
    bool? aftercareReceived,
    String? aftercarePdfUrl,
    String? notes,
    String? internalNotes,
    bool? isDraft,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? submittedAt,
  }) {
    return ConsentFormModel(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      service: service ?? this.service,
      appointment: appointment ?? this.appointment,
      payment: payment ?? this.payment,
      artistId: artistId ?? this.artistId,
      artistName: artistName ?? this.artistName,
      healthConditions: healthConditions ?? this.healthConditions,
      consentConfirmed: consentConfirmed ?? this.consentConfirmed,
      signatureUrl: signatureUrl ?? this.signatureUrl,
      customerPhotoUrl: customerPhotoUrl ?? this.customerPhotoUrl,
      aftercareReceived: aftercareReceived ?? this.aftercareReceived,
      aftercarePdfUrl: aftercarePdfUrl ?? this.aftercarePdfUrl,
      notes: notes ?? this.notes,
      internalNotes: internalNotes ?? this.internalNotes,
      isDraft: isDraft ?? this.isDraft,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }

  bool get isSubmitted => status == 'submitted';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer': customer.toJson(),
      'service': service.toJson(),
      'appointment': appointment.toJson(),
      'payment': payment.toJson(),
      'artistId': artistId,
      'artistName': artistName,
      'healthConditions': healthConditions,
      'consentConfirmed': consentConfirmed,
      'signatureUrl': signatureUrl,
      'customerPhotoUrl': customerPhotoUrl,
      'aftercareReceived': aftercareReceived,
      'aftercarePdfUrl': aftercarePdfUrl,
      'notes': notes,
      'internalNotes': internalNotes,
      'isDraft': isDraft,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'submittedAt': submittedAt?.toIso8601String(),
    };
  }

  factory ConsentFormModel.fromJson(Map<String, dynamic> json) {
    return ConsentFormModel(
      id: json['id'] ?? '',
      customer: CustomerModel.fromJson(json['customer'] ?? {}),
      service: ServiceModel.fromJson(json['service'] ?? {}),
      appointment: AppointmentModel.fromJson(json['appointment'] ?? {}),
      payment: PaymentModel.fromJson(json['payment'] ?? {}),
      artistId: json['artistId'] ?? '',
      artistName: json['artistName'] ?? '',
      healthConditions: json['healthConditions'] != null
          ? List<String>.from(json['healthConditions'])
          : [],
      consentConfirmed: json['consentConfirmed'] ?? false,
      signatureUrl: json['signatureUrl'],
      customerPhotoUrl: json['customerPhotoUrl'],
      aftercareReceived: json['aftercareReceived'] ?? false,
      aftercarePdfUrl: json['aftercarePdfUrl'],
      notes: json['notes'],
      internalNotes: json['internalNotes'],
      isDraft: json['isDraft'] ?? true,
      status: json['status'] ?? 'draft',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : null,
    );
  }
}