// Represents a single order item (product + optional variant).
class OrderItem {
  final String productId;
  final String? productVariantId;
  final String productName;
  final String variantName;
  final int quantity;
  final double price;
  final String? imageUrl; // Added field for the product image

  OrderItem({
    required this.productId,
    this.productVariantId,
    required this.productName,
    required this.variantName,
    required this.quantity,
    required this.price,
    this.imageUrl, // Make it optional in the constructor
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    productId: json['productId'] as String,
    productVariantId: json['productVariantId'] as String?,
    productName: json['productName'] as String,
    variantName: json['variantName'] as String,
    quantity: json['quantity'] as int,
    price: (json['price'] as num).toDouble(),
    imageUrl: json['imageUrl'] as String?, // Parse imageUrl from JSON
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'productId': productId,
      'productName': productName,
      'variantName': variantName,
      'quantity': quantity,
      'price': price,
    };
    if (productVariantId != null) {
      map['productVariantId'] = productVariantId;
    }
    if (imageUrl != null) {
      map['imageUrl'] = imageUrl; // Include imageUrl in JSON serialization
    }
    return map;
  }
}