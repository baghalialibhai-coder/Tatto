// lib/models/branch_model.dart
class BranchModel {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String? email;
  final String? latitude;
  final String? longitude;
  final String? imageUrl;
  final List<String>? workingHours;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? managerName;
  final String? managerPhone;

  BranchModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.email,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.workingHours,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.managerName,
    this.managerPhone,
  });

  // ============================================================
  // CopyWith Method
  // ============================================================

  BranchModel copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    String? latitude,
    String? longitude,
    String? imageUrl,
    List<String>? workingHours,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? managerName,
    String? managerPhone,
  }) {
    return BranchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      workingHours: workingHours ?? this.workingHours,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      managerName: managerName ?? this.managerName,
      managerPhone: managerPhone ?? this.managerPhone,
    );
  }

  // ============================================================
  // To JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'workingHours': workingHours,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'managerName': managerName,
      'managerPhone': managerPhone,
    };
  }

  // ============================================================
  // From JSON
  // ============================================================

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      imageUrl: json['imageUrl'],
      workingHours: json['workingHours'] != null
          ? List<String>.from(json['workingHours'])
          : null,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      managerName: json['managerName'],
      managerPhone: json['managerPhone'],
    );
  }

  // ============================================================
  // Helper Methods
  // ============================================================

  /// Get formatted address with name
  String get displayAddress => '$name\n$address';

  /// Get full contact info
  String get contactInfo => 'Phone: $phone${email != null ? '\nEmail: $email' : ''}';

  /// Check if branch has manager
  bool get hasManager => managerName != null && managerName!.isNotEmpty;

  /// Check if branch has email
  bool get hasEmail => email != null && email!.isNotEmpty;

  /// Get working hours as string
  String get workingHoursString {
    if (workingHours == null || workingHours!.isEmpty) {
      return 'Not specified';
    }
    return workingHours!.join('\n');
  }
}