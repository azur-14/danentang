// lib/models/CartItem.dart

/// Represents one line in the cart.
class CartItem {
  final String productId;
  final String? productVariantId;
  int quantity;

  /// Fetched on the fly in the UI (not part of JSON).
  double currentPrice;

  /// Has the user checked this item for subtotal?
  bool isSelected;

  CartItem({
    required this.productId,
    this.productVariantId,
    required this.quantity,
    this.currentPrice = 0.0,
    this.isSelected = false,    // default to false
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] as String,
      productVariantId: json['productVariantId'] as String?,
      quantity: json['quantity'] as int,
      // currentPrice & isSelected keep their defaults
    );
  }

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
