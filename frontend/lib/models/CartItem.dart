import 'package:danentang/models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  final String size;
  bool isSelected;
  final double? discountedPrice; // New field for discounted price

  CartItem({
    required this.product,
    required this.quantity,
    required this.size,
    this.isSelected = true,
    this.discountedPrice,
  });
}