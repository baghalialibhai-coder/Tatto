// lib/models/service_model.dart
import '../core/enums/service_category.dart';

class ServiceModel {
  final String id;
  final ServiceCategory category;
  final String name;
  final String description;
  final double basePrice;
  final double? estimatedDuration;
  final String? imageUrl;
  final List<String>? tags;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ServiceModel({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.basePrice,
    this.estimatedDuration,
    this.imageUrl,
    this.tags,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  ServiceModel copyWith({
    String? id,
    ServiceCategory? category,
    String? name,
    String? description,
    double? basePrice,
    double? estimatedDuration,
    String? imageUrl,
    List<String>? tags,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'estimatedDuration': estimatedDuration,
      'imageUrl': imageUrl,
      'tags': tags,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] ?? '',
      category: ServiceCategory.values.firstWhere(
            (e) => e.name == json['category'],
        orElse: () => ServiceCategory.other,
      ),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      basePrice: json['basePrice']?.toDouble() ?? 0.0,
      estimatedDuration: json['estimatedDuration']?.toDouble(),
      imageUrl: json['imageUrl'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}