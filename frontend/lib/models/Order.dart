
import 'OrderItem.dart';
import 'OrderStatusHistory.dart';
import 'ShippingAddress.dart';

/// Represents a placed order.
class Order {
  final String id;
  final String userId;
  final String orderNumber;
  final ShippingAddress shippingAddress;
  final List<OrderItem> items;
  final double totalAmount;
  final double discountAmount;
  final String? couponCode;
  final int loyaltyPointsUsed;
  final String status;
  final List<OrderStatusHistory> statusHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.shippingAddress,
    required this.items,
    required this.totalAmount,
    this.discountAmount = 0,
    this.couponCode,
    this.loyaltyPointsUsed = 0,
    this.status = 'pending',
    required this.statusHistory,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['_id'] as String,
    userId: json['userId'] as String,
    orderNumber: json['orderNumber'] as String,
    shippingAddress:
    ShippingAddress.fromJson(json['shippingAddress'] as Map<String, dynamic>),
    items: (json['items'] as List<dynamic>)
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    totalAmount: (json['totalAmount'] as num).toDouble(),
    discountAmount: (json['discountAmount'] as num).toDouble(),
    couponCode: json['couponCode'] as String?,
    loyaltyPointsUsed: json['loyaltyPointsUsed'] as int,
    status: json['status'] as String,
    statusHistory: (json['statusHistory'] as List<dynamic>)
        .map((e) => OrderStatusHistory.fromJson(e as Map<String, dynamic>))
        .toList(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'userId': userId,
    'orderNumber': orderNumber,
    'shippingAddress': shippingAddress.toJson(),
    'items': items.map((e) => e.toJson()).toList(),
    'totalAmount': totalAmount,
    'discountAmount': discountAmount,
    if (couponCode != null) 'couponCode': couponCode,
    'loyaltyPointsUsed': loyaltyPointsUsed,
    'status': status,
    'statusHistory': statusHistory.map((e) => e.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}