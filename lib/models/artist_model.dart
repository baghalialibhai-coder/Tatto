// lib/models/artist_model.dart
import '../core/enums/artist_payment_type.dart';
import '../core/enums/user_role.dart';

class ArtistModel {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final UserRole role;
  final ArtistPaymentType paymentType;
  final double? fixedSalary;
  final double? percentage;
  final double? fixedAmount;
  final double? profitSharePercentage;
  final String? specialty;
  final String? bio;
  final String? profileImage;
  final List<String>? portfolioImages;
  final bool isActive;
  final DateTime joiningDate;
  final DateTime? leavingDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // ✅ ADD THESE FIELDS
  final String branchId;      // ← ADD THIS
  final String branchName;    // ← ADD THIS

  ArtistModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.role = UserRole.artist,
    required this.paymentType,
    this.fixedSalary,
    this.percentage,
    this.fixedAmount,
    this.profitSharePercentage,
    this.specialty,
    this.bio,
    this.profileImage,
    this.portfolioImages,
    this.isActive = true,
    required this.joiningDate,
    this.leavingDate,
    required this.createdAt,
    this.updatedAt,
    this.branchId = '',      // ← ADD DEFAULT
    this.branchName = '',    // ← ADD DEFAULT
  });

  ArtistModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    ArtistPaymentType? paymentType,
    double? fixedSalary,
    double? percentage,
    double? fixedAmount,
    double? profitSharePercentage,
    String? specialty,
    String? bio,
    String? profileImage,
    List<String>? portfolioImages,
    bool? isActive,
    DateTime? joiningDate,
    DateTime? leavingDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? branchId,
    String? branchName,
  }) {
    return ArtistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      paymentType: paymentType ?? this.paymentType,
      fixedSalary: fixedSalary ?? this.fixedSalary,
      percentage: percentage ?? this.percentage,
      fixedAmount: fixedAmount ?? this.fixedAmount,
      profitSharePercentage: profitSharePercentage ?? this.profitSharePercentage,
      specialty: specialty ?? this.specialty,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      isActive: isActive ?? this.isActive,
      joiningDate: joiningDate ?? this.joiningDate,
      leavingDate: leavingDate ?? this.leavingDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
    );
  }

  // ... rest of the code (calculatePayment, getPaymentDescription, etc.)
  // Make sure toJson and fromJson also include branchId and branchName

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'paymentType': paymentType.name,
      'fixedSalary': fixedSalary,
      'percentage': percentage,
      'fixedAmount': fixedAmount,
      'profitSharePercentage': profitSharePercentage,
      'specialty': specialty,
      'bio': bio,
      'profileImage': profileImage,
      'portfolioImages': portfolioImages,
      'isActive': isActive,
      'joiningDate': joiningDate.toIso8601String(),
      'leavingDate': leavingDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'branchId': branchId,      // ← ADD
      'branchName': branchName,  // ← ADD
    };
  }

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      role: UserRole.values.firstWhere(
            (e) => e.name == json['role'],
        orElse: () => UserRole.artist,
      ),
      paymentType: ArtistPaymentType.values.firstWhere(
            (e) => e.name == json['paymentType'],
        orElse: () => ArtistPaymentType.percentage,
      ),
      fixedSalary: json['fixedSalary']?.toDouble(),
      percentage: json['percentage']?.toDouble(),
      fixedAmount: json['fixedAmount']?.toDouble(),
      profitSharePercentage: json['profitSharePercentage']?.toDouble(),
      specialty: json['specialty'],
      bio: json['bio'],
      profileImage: json['profileImage'],
      portfolioImages: json['portfolioImages'] != null
          ? List<String>.from(json['portfolioImages'])
          : null,
      isActive: json['isActive'] ?? true,
      joiningDate: DateTime.parse(json['joiningDate'] ?? DateTime.now().toIso8601String()),
      leavingDate: json['leavingDate'] != null
          ? DateTime.parse(json['leavingDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      branchId: json['branchId'] ?? '',      // ← ADD
      branchName: json['branchName'] ?? '',  // ← ADD
    );
  }
}