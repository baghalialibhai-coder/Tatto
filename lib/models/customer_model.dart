// lib/models/customer_model.dart
class CustomerModel {
  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String? instagramId;
  final String? photoUrl;
  final String? address;
  final DateTime? dateOfBirth;
  final String? gender;
  final List<String>? allergies;
  final List<String>? medicalConditions;
  final int totalVisits;
  final double totalSpent;
  final DateTime createdAt;
  final DateTime? lastVisit;

  CustomerModel({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    this.instagramId,
    this.photoUrl,
    this.address,
    this.dateOfBirth,
    this.gender,
    this.allergies,
    this.medicalConditions,
    this.totalVisits = 0,
    this.totalSpent = 0.0,
    required this.createdAt,
    this.lastVisit,
  });

  CustomerModel copyWith({
    String? id,
    String? name,
    String? mobile,
    String? email,
    String? instagramId,
    String? photoUrl,
    String? address,
    DateTime? dateOfBirth,
    String? gender,
    List<String>? allergies,
    List<String>? medicalConditions,
    int? totalVisits,
    double? totalSpent,
    DateTime? createdAt,
    DateTime? lastVisit,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      instagramId: instagramId ?? this.instagramId,
      photoUrl: photoUrl ?? this.photoUrl,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      totalVisits: totalVisits ?? this.totalVisits,
      totalSpent: totalSpent ?? this.totalSpent,
      createdAt: createdAt ?? this.createdAt,
      lastVisit: lastVisit ?? this.lastVisit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'email': email,
      'instagramId': instagramId,
      'photoUrl': photoUrl,
      'address': address,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
      'totalVisits': totalVisits,
      'totalSpent': totalSpent,
      'createdAt': createdAt.toIso8601String(),
      'lastVisit': lastVisit?.toIso8601String(),
    };
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'],
      instagramId: json['instagramId'],
      photoUrl: json['photoUrl'],
      address: json['address'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      gender: json['gender'],
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'])
          : null,
      medicalConditions: json['medicalConditions'] != null
          ? List<String>.from(json['medicalConditions'])
          : null,
      totalVisits: json['totalVisits'] ?? 0,
      totalSpent: json['totalSpent']?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastVisit: json['lastVisit'] != null
          ? DateTime.parse(json['lastVisit'])
          : null,
    );
  }
}