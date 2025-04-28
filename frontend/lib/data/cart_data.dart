import 'package:danentang/models/product.dart';
import 'package:danentang/models/CartItem.dart';

class CartData {
  static final List<Product> products = [
    Product(
      id: '1',
      name: "Dell XPS 13",
      brand: "Dell",
      description: "Powerful ultrabook",
      price: 45000.0, // Price in VND
      discountPercentage: 10, // Discount percentage
      categoryId: 'laptop',
      images: [
        ProductImage(url: 'assets/images/laptop.jpg', sortOrder: 1),
      ],
      variants: [
        ProductVariant(variantName: "13-inch", additionalPrice: 0.0, inventory: 5),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '2',
      name: "LG UltraWide Monitor",
      brand: "LG",
      description: "34-inch ultrawide monitor",
      price: 45000.0,
      discountPercentage: 5,
      categoryId: 'monitor',
      images: [
        ProductImage(url: 'assets/images/monitor.jpg', sortOrder: 1),
      ],
      variants: [
        ProductVariant(variantName: "34-inch", additionalPrice: 0.0, inventory: 8),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '3',
      name: "Logitech Mechanical Keyboard",
      brand: "Logitech",
      description: "Mechanical keyboard for gamers",
      price: 45000.0,
      discountPercentage: 0,
      categoryId: 'keyboard',
      images: [
        ProductImage(url: 'assets/images/keyboard.jpg', sortOrder: 1),
      ],
      variants: [
        ProductVariant(variantName: "Mechanical", additionalPrice: 0.0, inventory: 10),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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
