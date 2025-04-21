import 'package:danentang/models/product.dart';

class ProductData {
  static final List<Product> laptops = [
    Product(
      name: "Dell XPS 13",
      price: "1299",
      discount: "10%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.5,
    ),
    Product(
      name: "MacBook Air M2",
      price: "1199",
      discount: "5%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.8,
    ),
    Product(
      name: "HP Spectre x360",
      price: "1399",
      discount: "15%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.7,
    ),
    Product(
      name: "Asus ZenBook 14",
      price: "999",
      discount: "8%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.3,
    ),
  ];

  static final List<Product> budgetLaptops = [
    Product(
      name: "Acer Aspire 5",
      price: "499",
      discount: "12%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.0,
    ),
    Product(
      name: "Lenovo IdeaPad 3",
      price: "449",
      discount: "10%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.1,
    ),
    Product(
      name: "HP 14",
      price: "399",
      discount: "5%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 3.9,
    ),
  ];

  static final List<Product> promotionalProducts = [
    Product(
      name: "Lenovo Legion 5",
      price: "1099",
      discount: "20%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.6,
    ),
    Product(
      name: "Asus TUF Gaming F15",
      price: "999",
      discount: "25%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.4,
    ),
    Product(
      name: "MSI Katana GF66",
      price: "1199",
      discount: "22%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.5,
    ),
  ];

  static final List<Product> newProducts = [
    Product(
      name: "MacBook Pro M3",
      price: "1999",
      discount: "5%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.9,
    ),
    Product(
      name: "HP Envy 14 2025",
      price: "1249",
      discount: "10%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.7,
    ),
    Product(
      name: "Dell Inspiron 16",
      price: "899",
      discount: "8%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.4,
    ),
  ];

  static final List<Product> bestSellers = [
    Product(
      name: "Dell Inspiron 15",
      price: "749",
      discount: "15%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.3,
    ),
    Product(
      name: "Acer Swift 3",
      price: "699",
      discount: "12%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.2,
    ),
    Product(
      name: "Lenovo ThinkPad E14",
      price: "799",
      discount: "10%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.5,
    ),
  ];
}