// lib/models/payment_method_model.dart
import '../core/enums/payment_method.dart';

class PaymentMethodModel {
  final String id;
  final String name;
  final PaymentMethod type;
  final String? iconUrl;
  final bool isActive;
  final bool isDefault;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.type,
    this.iconUrl,
    this.isActive = true,
    this.isDefault = false,
    this.displayOrder = 0,
    required this.createdAt,
    this.updatedAt,
  });

  PaymentMethodModel copyWith({
    String? id,
    String? name,
    PaymentMethod? type,
    String? iconUrl,
    bool? isActive,
    bool? isDefault,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconUrl: iconUrl ?? this.iconUrl,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'iconUrl': iconUrl,
      'isActive': isActive,
      'isDefault': isDefault,
      'displayOrder': displayOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: PaymentMethod.values.firstWhere(
            (e) => e.name == json['type'],
        orElse: () => PaymentMethod.other,
      ),
      iconUrl: json['iconUrl'],
      isActive: json['isActive'] ?? true,
      isDefault: json['isDefault'] ?? false,
      displayOrder: json['displayOrder'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}