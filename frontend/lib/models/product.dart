class Product {
  final String name;
  final String price;
  final String discount;
  final String imageUrl;
  final double rating; // Add this field

  Product({
    required this.name,
    required this.price,
    required this.discount,
    required this.imageUrl,
    required this.rating,
  });
}