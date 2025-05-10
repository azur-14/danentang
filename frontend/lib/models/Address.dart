// lib/models/address.dart

class Address{
  final String addressLine;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? country;
  final bool isDefault;
  final DateTime createdAt;

  Address({
    required this.addressLine,
    this.city,
    this.state,
    this.zipCode,
    this.country,
    this.isDefault = false,
    required this.createdAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    addressLine: json['addressLine'] as String,
    city: json['city'] as String?,
    state: json['state'] as String?,
    zipCode: json['zipCode'] as String?,
    country: json['country'] as String?,
    isDefault: json['isDefault'] as bool? ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'addressLine': addressLine,
    if (city != null) 'city': city,
    if (state != null) 'state': state,
    if (zipCode != null) 'zipCode': zipCode,
    if (country != null) 'country': country,
    'isDefault': isDefault,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };
}
