// lib/models/product.dart

class Product {
  final String id;
  final String name;
  final String? brand;
  final String? description;
  final double price;
  final int discountPercentage;
  final String categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProductImage> images;
  final List<ProductVariant> variants;

  Product({
    required this.id,
    required this.name,
    this.brand,
    this.description,
    required this.price,
    required this.discountPercentage,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
    required this.variants,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    brand: json['brand'] as String?,
    description: json['description'] as String?,
    price: (json['price'] as num).toDouble(),
    discountPercentage: json['discountPercentage'] as int,
    categoryId: json['categoryId'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    images: (json['images'] as List<dynamic>)
        .map((e) => ProductImage.fromJson(e as Map<String, dynamic>))
        .toList(),
    variants: (json['variants'] as List<dynamic>)
        .map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class ProductImage {
  final String? id;      // cho phép null
  final String url;
  final int sortOrder;

  ProductImage({
    this.id,
    required this.url,
    required this.sortOrder,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
    id: json['id'] as String?,         // parse nullable
    url: json['url'] as String,
    sortOrder: json['sortOrder'] as int,
  );
}

class ProductVariant {
  final String? id;      // cho phép null
  final String variantName;
  final double additionalPrice;
  final int inventory;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductVariant({
    this.id,
    required this.variantName,
    required this.additionalPrice,
    required this.inventory,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) =>
      ProductVariant(
        id: json['id'] as String?,
        variantName: json['variantName'] as String,
        additionalPrice: (json['additionalPrice'] as num).toDouble(),
        inventory: json['inventory'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

