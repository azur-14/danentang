// lib/models/User.dart

import 'Address.dart';

class User {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String status;
  final int loyaltyPoints;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? phoneNumber;
  final String? avatarUrl;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Address> addresses;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.status,
    required this.loyaltyPoints,
    this.gender,
    this.dateOfBirth,
    this.phoneNumber,
    this.avatarUrl,
    required this.isEmailVerified,
    required this.createdAt,
    required this.updatedAt,
    required this.addresses,
  });

  factory User.fromJson(Map<String, dynamic> j) {
    // lấy id từ '_id' (UserController) hoặc 'id' (AuthController)
    final rawId = j['_id'] ?? j['id'];
    if (rawId == null) {
      throw FormatException('Missing id field in User JSON: $j');
    }
    final id = rawId.toString();

    return User(
      id: id,
      email: j['email'] as String? ?? '',
      fullName: j['fullName'] as String? ?? '',
      role: j['role'] as String? ?? '',
      status: j['status'] as String? ?? '',
      loyaltyPoints: j['loyaltyPoints'] as int? ?? 0,
      gender: j['gender'] as String?,
      dateOfBirth: j['dateOfBirth'] != null
          ? DateTime.tryParse(j['dateOfBirth'] as String)
          : null,
      phoneNumber: j['phoneNumber'] as String?,
      avatarUrl: j['avatarUrl'] as String?,
      isEmailVerified: j['isEmailVerified'] as bool? ?? false,
      createdAt: DateTime.parse(j['createdAt'] as String),
      updatedAt: DateTime.parse(j['updatedAt'] as String),
      addresses: (j['addresses'] as List? ?? [])
          .map((e) => Address.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    // khi update, backend sẽ ignore createdAt/updatedAt
    'email': email,
    'fullName': fullName,
    'role': role,
    'status': status,
    'loyaltyPoints': loyaltyPoints,
    'gender': gender,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'phoneNumber': phoneNumber,
    'avatarUrl': avatarUrl,
    'isEmailVerified': isEmailVerified,
    'addresses': addresses.map((a) => a.toJson()).toList(),
  };
  User copyWith({
    String? fullName,
    String? role,
    String? status,
    String? gender,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? avatarUrl,
    List<Address>? addresses,
  }) {
    return User(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      status: status ?? this.status,
      loyaltyPoints: loyaltyPoints,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      addresses: addresses ?? this.addresses,
    );
  }
}

