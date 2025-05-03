import 'package:uuid/uuid.dart'; // Add uuid package for generating IDs

class Product {
  final String id;
  final String name;
  final String? brand;
  final String? description;
  final double price;
  final int discountPercentage;
  final String categoryId;
  final List<ProductImage> images;
  final List<ProductVariant> variants;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    this.brand,
    this.description,
    required this.price,
    required this.discountPercentage,
    required this.categoryId,
    required this.images,
    required this.variants,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Generate a fallback ID if _id is missing or empty
    final String jsonId = json['_id']?.toString() ?? '';
    final String id = jsonId.isNotEmpty ? jsonId : const Uuid().v4();

    return Product(
      id: id,
      name: json['name'] ?? '',
      brand: json['brand'],
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: json['discountPercentage'] ?? 0,
      categoryId: json['categoryId'] ?? '',
      images: (json['images'] as List<dynamic>?)
          ?.map((img) => ProductImage.fromJson(img))
          .toList() ??
          [],
      variants: (json['variants'] as List<dynamic>?)
          ?.map((v) => ProductVariant.fromJson(v))
          .toList() ??
          [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class ProductImage {
  final String url;
  final int sortOrder;

  const ProductImage({
    required this.url,
    required this.sortOrder,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      url: json['url'] ?? '',
      sortOrder: json['sortOrder'] ?? 1,
    );
  }
}

class ProductVariant {
  final String variantName;
  final double additionalPrice;
  final int inventory;

  const ProductVariant({
    required this.variantName,
    required this.additionalPrice,
    required this.inventory,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      variantName: json['variantName'] ?? '',
      additionalPrice: (json['additionalPrice'] as num?)?.toDouble() ?? 0.0,
      inventory: json['inventory'] ?? 0,
    );
  }
}