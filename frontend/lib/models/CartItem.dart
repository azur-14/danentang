// lib/models/CartItem.dart

import 'Product.dart'; // chứa class Product, ProductVariant

class CartItem {
  final String productId;        // ← Mã product gốc
  final String variantName;      // ← Tên biến thể
  int quantity;
  bool isSelected;

  // Thêm các trường để lưu giá và thông tin hiển thị
  double? currentPrice;
  double? discountPercentage;
  String? imageUrl;

  CartItem({
    required this.productId,
    required this.variantName,
    required this.quantity,
    this.isSelected = true,
    this.currentPrice,
    this.discountPercentage,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'variantName': variantName,
    'quantity': quantity,
    'isSelected': isSelected,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    productId: json['productId'],
    variantName: json['variantName'],
    quantity: json['quantity'],
    isSelected: json['isSelected'] ?? true,
    // currentPrice, discountPercentage, imageUrl tính toán sau khi từ server
  );
}
