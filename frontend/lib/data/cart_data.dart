import 'package:danentang/models/product.dart';
import 'package:danentang/models/CartItem.dart';

class CartData {
  static final List<Product> products = [
    Product(
      name: "Dell XPS 13",
      price: "45000",
      discount: "0",
      imageUrl: 'assets/images/laptop.jpg',
      rating: 4.8,
    ),
    Product(
      name: "LG UltraWide Monitor",
      price: "45000",
      discount: "0",
      imageUrl: 'assets/images/monitor.jpg',
      rating: 4.7,
    ),
    Product(
      name: "Logitech Mechanical Keyboard",
      price: "45000",
      discount: "0",
      imageUrl: 'assets/images/keyboard.jpg',
      rating: 4.6,
    ),
  ];

  static final List<CartItem> cartItems = products.map((product) {
    return CartItem(
      product: product,
      quantity: 2,
      size: product.name == "Dell XPS 13"
          ? "Screen: 13-inch"
          : product.name == "LG UltraWide Monitor"
          ? "Screen: 34-inch"
          : "Type: Mechanical",
      isSelected: true,
    );
  }).toList();
}