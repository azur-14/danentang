
/// Represents a discount coupon.
class Coupon {
  final String id;
  final String code;
  final double discountValue;
  final int usageLimit;
  final int usageCount;
  final DateTime createdAt;

  Coupon({
    required this.id,
    required this.code,
    required this.discountValue,
    this.usageLimit = 10,
    this.usageCount = 0,
    required this.createdAt,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
    id: json['_id'] as String,
    code: json['code'] as String,
    discountValue: (json['discountValue'] as num).toDouble(),
    usageLimit: json['usageLimit'] as int,
    usageCount: json['usageCount'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'code': code,
    'discountValue': discountValue,
    'usageLimit': usageLimit,
    'usageCount': usageCount,
    'createdAt': createdAt.toIso8601String(),
  };
}