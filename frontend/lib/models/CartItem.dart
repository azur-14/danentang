import 'package:danentang/models/product.dart';

class CartItem {
  final Product product;
  int quantity;
  String size;
  bool isSelected;

  CartItem({
    required this.product,
    required this.quantity,
    required this.size,
    this.isSelected = false,
  });
}