// lib/models/payment_model.dart
import '../core/enums/payment_status.dart';
import '../core/enums/payment_method.dart';

class PaymentModel {
  final String id;
  final String consentFormId;
  final double totalAmount;
  final double discount;
  final double finalAmount;
  final List<PaymentMethod> methods;
  final List<PaymentTransaction> transactions;
  final PaymentStatus status;
  final DateTime paymentDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String transactionId; // ✅ Added missing field

  PaymentModel({
    required this.id,
    required this.consentFormId,
    required this.totalAmount,
    this.discount = 0,
    required this.finalAmount,
    this.methods = const [],
    this.transactions = const [],
    this.status = PaymentStatus.pending,
    required this.paymentDate,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.transactionId = '', // ✅ Default value
  });

  PaymentModel copyWith({
    String? id,
    String? consentFormId,
    double? totalAmount,
    double? discount,
    double? finalAmount,
    List<PaymentMethod>? methods,
    List<PaymentTransaction>? transactions,
    PaymentStatus? status,
    DateTime? paymentDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? transactionId,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      consentFormId: consentFormId ?? this.consentFormId,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      finalAmount: finalAmount ?? this.finalAmount,
      methods: methods ?? this.methods,
      transactions: transactions ?? this.transactions,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  // ============================================================
  // Helper Getters
  // ============================================================

  double get paidAmount {
    return transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  double get remainingAmount => finalAmount - paidAmount;

  bool get isFullyPaid => remainingAmount <= 0;

  bool get hasTransactionId => transactionId.isNotEmpty;

  // ============================================================
  // To JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consentFormId': consentFormId,
      'totalAmount': totalAmount,
      'discount': discount,
      'finalAmount': finalAmount,
      'methods': methods.map((m) => m.name).toList(),
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'status': status.name,
      'paymentDate': paymentDate.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'transactionId': transactionId, // ✅ Added
    };
  }

  // ============================================================
  // From JSON
  // ============================================================

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? '',
      consentFormId: json['consentFormId'] ?? '',
      totalAmount: json['totalAmount']?.toDouble() ?? 0.0,
      discount: json['discount']?.toDouble() ?? 0.0,
      finalAmount: json['finalAmount']?.toDouble() ?? 0.0,
      methods: json['methods'] != null
          ? (json['methods'] as List)
          .map((e) => PaymentMethod.values.firstWhere(
            (m) => m.name == e,
        orElse: () => PaymentMethod.other,
      ))
          .toList()
          : [],
      transactions: json['transactions'] != null
          ? (json['transactions'] as List)
          .map((e) => PaymentTransaction.fromJson(e))
          .toList()
          : [],
      status: PaymentStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      paymentDate: DateTime.parse(json['paymentDate'] ?? DateTime.now().toIso8601String()),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      transactionId: json['transactionId'] ?? '', // ✅ Added
    );
  }
}

// ============================================================
// PaymentTransaction Model
// ============================================================

class PaymentTransaction {
  final String id;
  final PaymentMethod method;
  final double amount;
  final String? referenceId;
  final String? transactionId;
  final DateTime timestamp;
  final String? notes;

  PaymentTransaction({
    required this.id,
    required this.method,
    required this.amount,
    this.referenceId,
    this.transactionId,
    required this.timestamp,
    this.notes,
  });

  PaymentTransaction copyWith({
    String? id,
    PaymentMethod? method,
    double? amount,
    String? referenceId,
    String? transactionId,
    DateTime? timestamp,
    String? notes,
  }) {
    return PaymentTransaction(
      id: id ?? this.id,
      method: method ?? this.method,
      amount: amount ?? this.amount,
      referenceId: referenceId ?? this.referenceId,
      transactionId: transactionId ?? this.transactionId,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method': method.name,
      'amount': amount,
      'referenceId': referenceId,
      'transactionId': transactionId,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] ?? '',
      method: PaymentMethod.values.firstWhere(
            (e) => e.name == json['method'],
        orElse: () => PaymentMethod.other,
      ),
      amount: json['amount']?.toDouble() ?? 0.0,
      referenceId: json['referenceId'],
      transactionId: json['transactionId'],
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      notes: json['notes'],
    );
  }
}