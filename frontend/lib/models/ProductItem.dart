class CartItem {
  final String productId;
  final String? productVariantId;
  int quantity;

  /// Fetched on the fly in the UI (not part of backend JSON)
  double currentPrice;

  /// Indicates if user has selected this item
  bool isSelected;

  CartItem({
    required this.productId,
    this.productVariantId,
    required this.quantity,
    this.currentPrice = 0.0,
    this.isSelected = false,
  });

  /// Tạo object rỗng cho logic xử lý smart add/update
  factory CartItem.empty() => CartItem(productId: '', quantity: 0);

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] as String,
      productVariantId: json['productVariantId'] as String?,
      quantity: json['quantity'] as int,
      currentPrice: (json['currentPrice'] ?? 0.0).toDouble(),
      isSelected: json['isSelected'] ?? false,
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
