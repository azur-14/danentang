// lib/services/product_service.dart

import 'dart:convert';
import 'package:bson/bson.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/category.dart';
import '../models/tag.dart';
import '../models/ProductRating.dart';
import '../models/Review.dart';

class ProductService {

  static const String _baseUrl         = 'http://localhost:5011/api';
  static const String _productItemsPath = '$_baseUrl/product-items';
  static const String _productsPath    = '$_baseUrl/products';
  static const String _categoriesPath  = '$_baseUrl/categories';
  static const String _tagsPath        = '$_baseUrl/Tag';
  static const String _productTagsPath = '$_baseUrl/product-tags';
  static Future<void> createProduct(Product product) async {
    // Bổ sung ID trước khi gửi
    final enrichedProduct = product.copyWith(
      images: product.images.map((img) {
        final id = (img.id == null || img.id.isEmpty) ? ObjectId().toHexString() : img.id;
        return ProductImage(
          id: id,
          url: img.url,
          sortOrder: img.sortOrder,
        );
      }).toList(),
      variants: product.variants.map((v) {
        final id = (v.id == null || v.id.isEmpty) ? ObjectId().toHexString() : v.id;
        return ProductVariant(
          id: id,
          variantName: v.variantName,
          additionalPrice: v.additionalPrice,
          inventory: v.inventory,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList(),
    );

    final response = await http.post(
      Uri.parse('$_productsPath'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(enrichedProduct.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Product created!");
    } else {
      throw Exception('Failed to create product (${response.statusCode}): ${response.body}');
    }
  }


  static Future<Product> updateProduct(Product p) async {
    // Tạo danh sách mới với id đảm bảo hợp lệ
    final newVariants = p.variants.map((v) {
      final id = (v.id == null || v.id!.isEmpty) ? ObjectId().toHexString() : v.id!;
      return ProductVariant(
        id: id,
        variantName: v.variantName,
        additionalPrice: v.additionalPrice,
        inventory: v.inventory,createdAt: v.createdAt ?? DateTime.now(), updatedAt: v.updatedAt ?? DateTime.now(),

      );
    }).toList();

    final updatedProduct = p.copyWith(variants: newVariants);

    final uri = Uri.parse('$_productsPath/${p.id}');
    final resp = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedProduct.toJson()),
    );

    if (resp.statusCode == 200) {
      return Product.fromJson(json.decode(resp.body) as Map<String, dynamic>);
    }

    if (resp.statusCode == 204) {
      return updatedProduct;
    }

    throw Exception('Failed to update product (${resp.statusCode}): ${resp.body}');
  }
  /// DELETE /api/products/{id}
  static Future<void> deleteProduct(String id) async {
    final uri = Uri.parse('$_productsPath/$id');
    final resp = await http.delete(uri);
    if (resp.statusCode != 204) {
      throw Exception('Failed to delete product (${resp.statusCode})');
    }
  }
  /// GET /api/products
  static Future<List<Product>> fetchAllProducts() async {
    final uri = Uri.parse(_productsPath);
    debugPrint('→ GET $uri');
    try {
      final resp = await http.get(uri);
      debugPrint('← ${resp.statusCode} ${resp.body}');
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as List<dynamic>;
        return data
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('‼️ fetchAllProducts API error ${resp.statusCode}');
      }
    } catch (e, st) {
      debugPrint('❌ fetchAllProducts exception: $e\n$st');
    }
    return [];
  }

  /// GET /api/categories
  static Future<List<Category>> fetchAllCategories() async {
    final uri = Uri.parse(_categoriesPath);
    debugPrint('→ GET $uri');
    try {
      final resp = await http.get(uri);
      debugPrint('← ${resp.statusCode} ${resp.body}');
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as List<dynamic>;
        return data
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('‼️ fetchAllCategories API error ${resp.statusCode}');
      }
    } catch (e, st) {
      debugPrint('❌ fetchAllCategories exception: $e\n$st');
    }
    return [];
  }
  static Future<void> createProductItemsForVariant({
    required String productId,
    required String variantId,
    required int quantity,
  }) async {
    final now = DateTime.now();
    for (int i = 0; i < quantity; i++) {
      final item = {
        'productId': productId,
        'variantId': variantId,
        'serialNumber': null,
        'status': 'available',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };

      final resp = await http.post(
        Uri.parse(_productItemsPath),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item),
      );

      if (resp.statusCode != 200) {
        throw Exception('Failed to create product item for variant $variantId');
      }
    }
  }

  /// GET /api/Tag
  static Future<List<Tag>> fetchAllTags() async {
    final uri = Uri.parse(_tagsPath);
    debugPrint('→ GET $uri');
    try {
      final resp = await http.get(uri);
      debugPrint('← ${resp.statusCode} ${resp.body}');
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as List<dynamic>;
        return data
            .map((e) => Tag.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('‼️ fetchAllTags API error ${resp.statusCode}');
      }
    } catch (e, st) {
      debugPrint('❌ fetchAllTags exception: $e\n$st');
    }
    return [];
  }

  /// GET /api/product-tags/by-tag/{tagId}
  static Future<List<Product>> fetchProductsByTag(String tagId) async {
    final uri = Uri.parse('$_productTagsPath/by-tag/$tagId');
    debugPrint('→ GET $uri');
    try {
      final resp = await http.get(uri);
      debugPrint('← ${resp.statusCode} ${resp.body}');
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as List<dynamic>;
        return data
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('‼️ fetchProductsByTag API error ${resp.statusCode}');
      }
    } catch (e, st) {
      debugPrint('❌ fetchProductsByTag exception: $e\n$st');
    }
    return [];
  }

  /// GET /api/products/category/{categoryId}
  static Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    final uri = Uri.parse('$_productsPath/category/$categoryId');
    debugPrint('→ GET $uri');
    try {
      final resp = await http.get(uri);
      debugPrint('← ${resp.statusCode} ${resp.body}');
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as List<dynamic>;
        return data
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('‼️ fetchProductsByCategory API error ${resp.statusCode}');
      }
    } catch (e, st) {
      debugPrint('❌ fetchProductsByCategory exception: $e\n$st');
    }
    return [];
  }

  // —— Các method cho Detail Screen —— //

  /// GET /api/products/{id}
  static Future<Product> getById(String id) async {
    final uri = Uri.parse('$_productsPath/$id');
    debugPrint('→ GET $uri');
    final resp = await http.get(uri);
    debugPrint('← ${resp.statusCode} ${resp.body}');
    if (resp.statusCode == 200) {
      return Product.fromJson(json.decode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load product $id (status ${resp.statusCode})');
  }

  /// GET /api/products/{id}/rating
  static Future<ProductRating> getRating(String productId) async {
    final uri = Uri.parse('$_productsPath/$productId/rating');
    debugPrint('→ GET $uri');
    final resp = await http.get(uri);
    debugPrint('← ${resp.statusCode} ${resp.body}');
    if (resp.statusCode == 200) {
      return ProductRating.fromJson(
          json.decode(resp.body) as Map<String, dynamic>);
    }
    // fallback nếu không có rating
    return const ProductRating(averageRating: 0, reviewCount: 0);
  }

  /// GET /api/products/{id}/reviews
  static Future<List<Review>> getReviews(String productId) async {
    final uri = Uri.parse('$_productsPath/$productId/reviews');
    debugPrint('→ GET $uri');
    try {
      final resp = await http.get(uri);
      debugPrint('← ${resp.statusCode} ${resp.body}');
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as List<dynamic>;
        return data
            .map((e) => Review.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('‼️ getReviews API error ${resp.statusCode}');
      }
    } catch (e, st) {
      debugPrint('❌ getReviews exception: $e\n$st');
    }
    return [];
  }

  /// GET /api/products/{id}/recommended
  static Future<List<Product>> getRecommended(String productId) async {
    final uri = Uri.parse('$_productsPath/$productId/recommended');
    debugPrint('→ GET $uri');
    try {
      final resp = await http.get(uri);
      debugPrint('← ${resp.statusCode} ${resp.body}');
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as List<dynamic>;
        return data
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint(
            '‼️ getRecommended API error ${resp.statusCode}');
      }
    } catch (e, st) {
      debugPrint('❌ getRecommended exception: $e\n$st');
    }
    return [];
  }


  /// GET /api/products/{id}
  Future<Product> getProductById(String id) async {
    final uri = Uri.parse('$_productsPath/$id');
    debugPrint('→ GET $uri');
    final resp = await http.get(uri);
    debugPrint('← ${resp.statusCode} ${resp.body}');
    if (resp.statusCode == 200) {
      return Product.fromJson(json.decode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to load product $id: ${resp.statusCode}');
  }

  /// GET /api/products/{productId}/variants
  static Future<List<ProductVariant>> fetchVariants(String productId) async {
    final uri = Uri.parse('$_productsPath/$productId/variants');
    debugPrint('→ GET $uri');
    final resp = await http.get(uri);
    debugPrint('← ${resp.statusCode} ${resp.body}');
    if (resp.statusCode == 200) {
      final List<dynamic> data = json.decode(resp.body) as List<dynamic>;
      return data
          .map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load variants for product $productId: ${resp.statusCode}');
  }

  /// GET /api/products/{productId}/variants/{variantId}
  Future<ProductVariant> getVariantById(String productId, String variantId) async {
    final variants = await fetchVariants(productId);
    try {
      return variants.firstWhere((v) => v.id == variantId);
    } catch (_) {
      throw Exception('Variant $variantId not found for product $productId');
    }
  }
  /// GET  /api/products/{productId}/images
  static Future<List<ProductImage>> fetchImages(String productId) async {
    final uri = Uri.parse('$_productsPath/$productId/images');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as List;
      return data.map((e) => ProductImage.fromJson(e)).toList();
    }
    throw Exception('fetchImages failed: ${resp.statusCode}');
  }

  /// POST /api/products/{productId}/images
  static Future<ProductImage> addImage(String productId, ProductImage img) async {
    final uri = Uri.parse('$_productsPath/$productId/images');
    final resp = await http.post(
      uri,
      headers: {'Content-Type':'application/json'},
      body: jsonEncode(img.toJson()),
    );
    if (resp.statusCode == 200) {
      return ProductImage.fromJson(json.decode(resp.body));
    }
    throw Exception('addImage failed: ${resp.statusCode}');
  }

  /// PUT  /api/products/{productId}/images/{imageId}
  static Future<void> updateImage(String productId, ProductImage img) async {
    final uri = Uri.parse('$_productsPath/$productId/images/${img.id}');
    final resp = await http.put(
      uri,
      headers: {'Content-Type':'application/json'},
      body: jsonEncode(img.toJson()),
    );
    if (resp.statusCode != 204) {
      throw Exception('updateImage failed: ${resp.statusCode}');
    }
  }

  /// DELETE /api/products/{productId}/images/{imageId}
  static Future<void> deleteImage(String productId, String imageId) async {
    final uri = Uri.parse('$_productsPath/$productId/images/$imageId');
    final resp = await http.delete(uri);
    if (resp.statusCode != 204) {
      throw Exception('deleteImage failed: ${resp.statusCode}');
    }
  }
  /// GET /api/product-tags/by-product/{productId}
  static Future<List<Tag>> fetchTagsOfProduct(String productId) async {
    final uri = Uri.parse('$_productTagsPath/by-product/$productId');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as List<dynamic>;
      return data.map((e) => Tag.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load tags for product $productId (${resp.statusCode})');
  }
  // —— Variant CRUD —— //

  static Future<ProductVariant> addVariant(String productId, ProductVariant v) async {
    final uri = Uri.parse('$_productsPath/$productId/variants');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(v.toJson()),
    );
    if (resp.statusCode == 200) {
      final variant = ProductVariant.fromJson(json.decode(resp.body));

      // ✅ Auto tạo ProductItem nếu inventory > 0
      if (variant.inventory > 0) {
        await createProductItemsForVariant(
          productId: productId,
          variantId: variant.id!,
          quantity: variant.inventory,
        );
      }

      return variant;
    }
    throw Exception('addVariant failed: ${resp.statusCode})');
  }

  /// PUT  /api/products/{productId}/variants/{variantId}
  static Future<void> updateVariant(String productId, ProductVariant v) async {
    // Lấy số lượng hiện có trên server
    final oldVariants = await fetchVariants(productId);
    final old = oldVariants.firstWhere((e) => e.id == v.id, orElse: () => v);
    final int oldInventory = old.inventory;

    // Gửi cập nhật variant lên server
    final uri = Uri.parse('$_productsPath/$productId/variants/${v.id}');
    final resp = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(v.toJson()),
    );

    if (resp.statusCode != 204) {
      throw Exception('updateVariant failed: ${resp.statusCode}');
    }

    // Nếu inventory tăng → tạo thêm ProductItem
    final int newInventory = v.inventory;
    final int diff = newInventory - oldInventory;
    if (diff > 0) {
      await createProductItemsForVariant(
        productId: productId,
        variantId: v.id!,
        quantity: diff,
      );
    }
  }


  /// DELETE /api/products/{productId}/variants/{variantId}
  static Future<void> deleteVariant(String productId, String variantId) async {
    final uri = Uri.parse('$_productsPath/$productId/variants/$variantId');
    final resp = await http.delete(uri);
    if (resp.statusCode != 204) {
      throw Exception('deleteVariant failed: ${resp.statusCode}');
    }
  }
}
