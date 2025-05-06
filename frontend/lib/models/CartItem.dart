// lib/models/CartItem.dart

import 'dart:convert';

/// Represents an item in the shopping cart.
class CartItem {
  final String productId;
  final String? productVariantId;
  int quantity;

  /// Giá hiện tại (được fetch từ API trong widget)
  double currentPrice;

  /// Có được chọn (“tích”) để tính subtotal không
  bool isSelected;

  CartItem({
    required this.productId,
    this.productVariantId,
    required this.quantity,
    this.currentPrice = 0,
    this.isSelected = true,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    productId: json['productId'] as String,
    productVariantId: json['productVariantId'] as String?,
    quantity: json['quantity'] as int,
    // khi parse từ server, chưa biết price => giữ default 0
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'productId': productId,
      'quantity': quantity,
    };
    if (productVariantId != null) {
      map['productVariantId'] = productVariantId;
    }
    return map;
  }
}
