// lib/models/studio_model.dart
import 'branch_model.dart';

class StudioModel {
  final String id;
  final String name;
  final String logoUrl;
  final String address;
  final String phone;
  final String email;
  final String? gstNumber;
  final String currency;
  final double taxRate;
  final List<BranchModel> branches;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? userId; // Admin who created this studio
  final String? website;
  final String? description;
  final List<String>? socialLinks;

  StudioModel({
    required this.id,
    required this.name,
    this.logoUrl = '',
    required this.address,
    required this.phone,
    required this.email,
    this.gstNumber,
    this.currency = 'INR',
    this.taxRate = 18.0,
    this.branches = const [],
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.userId,
    this.website,
    this.description,
    this.socialLinks,
  });

  // ============================================================
  // CopyWith Method
  // ============================================================

  StudioModel copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? address,
    String? phone,
    String? email,
    String? gstNumber,
    String? currency,
    double? taxRate,
    List<BranchModel>? branches,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    String? website,
    String? description,
    List<String>? socialLinks,
  }) {
    return StudioModel(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gstNumber: gstNumber ?? this.gstNumber,
      currency: currency ?? this.currency,
      taxRate: taxRate ?? this.taxRate,
      branches: branches ?? this.branches,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      website: website ?? this.website,
      description: description ?? this.description,
      socialLinks: socialLinks ?? this.socialLinks,
    );
  }

  // ============================================================
  // To JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'address': address,
      'phone': phone,
      'email': email,
      'gstNumber': gstNumber,
      'currency': currency,
      'taxRate': taxRate,
      'branches': branches.map((b) => b.toJson()).toList(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'userId': userId,
      'website': website,
      'description': description,
      'socialLinks': socialLinks,
    };
  }

  // ============================================================
  // From JSON
  // ============================================================

  factory StudioModel.fromJson(Map<String, dynamic> json) {
    return StudioModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      gstNumber: json['gstNumber'],
      currency: json['currency'] ?? 'INR',
      taxRate: (json['taxRate'] ?? 18.0).toDouble(),
      branches: json['branches'] != null
          ? (json['branches'] as List)
          .map((e) => BranchModel.fromJson(e))
          .toList()
          : [],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      userId: json['userId'],
      website: json['website'],
      description: json['description'],
      socialLinks: json['socialLinks'] != null
          ? List<String>.from(json['socialLinks'])
          : null,
    );
  }

  // ============================================================
  // Helper Methods
  // ============================================================

  /// Get primary branch (first branch)
  BranchModel? get primaryBranch => branches.isNotEmpty ? branches.first : null;

  /// Get active branches only
  List<BranchModel> get activeBranches => branches.where((b) => b.isActive).toList();

  /// Get branch by ID
  BranchModel? getBranchById(String id) {
    try {
      return branches.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get branch by name
  BranchModel? getBranchByName(String name) {
    try {
      return branches.firstWhere((b) => b.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  /// Check if studio has any branches
  bool get hasBranches => branches.isNotEmpty;

  /// Get total number of branches
  int get branchCount => branches.length;

  /// Get studio display name with location
  String get displayName => '$name${branches.isNotEmpty ? ' (${branches.length} branches)' : ''}';

  /// Get formatted address
  String get formattedAddress => '$name\n$address\nPhone: $phone\nEmail: $email';

  /// Check if studio has GST
  bool get hasGST => gstNumber != null && gstNumber!.isNotEmpty;

  /// Get tax rate as percentage string
  String get taxRateString => '$taxRate%';
}