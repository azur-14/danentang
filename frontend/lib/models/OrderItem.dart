class OrderItem {
  final String productId;
  final String? productVariantId;
  final String productName;
  final String variantName;
  final int quantity;
  final double price;
<<<<<<< HEAD
  final String? imageUrl; // Added field for the product image
=======
  final List<String> productItemIds;
>>>>>>> bf92b695419ac74d1dad522fe935bf06c8b4599c

  OrderItem({
    required this.productId,
    this.productVariantId,
    required this.productName,
    required this.variantName,
    required this.quantity,
    required this.price,
<<<<<<< HEAD
    this.imageUrl, // Make it optional in the constructor
=======
    this.productItemIds = const [],
>>>>>>> bf92b695419ac74d1dad522fe935bf06c8b4599c
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    productId: json['productId'],
    productVariantId: json['productVariantId'],
    productName: json['productName'],
    variantName: json['variantName'],
    quantity: json['quantity'],
    price: (json['price'] as num).toDouble(),
<<<<<<< HEAD
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
=======
    productItemIds: List<String>.from(json['productItemIds'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'productId': productId,
    if (productVariantId != null) 'productVariantId': productVariantId,
    'productName': productName,
    'variantName': variantName,
    'quantity': quantity,
    'price': price,
    'productItemIds': productItemIds,
  };
}
>>>>>>> bf92b695419ac74d1dad522fe935bf06c8b4599c
