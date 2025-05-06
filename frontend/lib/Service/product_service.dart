// lib/services/product_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/category.dart';
import '../models/tag.dart';

class ProductService {
  static const String _baseUrl      = 'http://localhost:5011/api';
  static const String _productsPath = '$_baseUrl/products';
  static const String _categories   = '$_baseUrl/categories';
  static const String _tags         = '$_baseUrl/Tag';
  static const String _productTags  = '$_baseUrl/product-tags';

  /// GET /api/products
  static Future<List<Product>> fetchAllProducts() async {
    final uri = Uri.parse(_productsPath);
    debugPrint('→ GET $uri');
    try {
      final resp = await http.get(uri);
      debugPrint('← ${resp.statusCode} ${resp.body}');
      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body) as List<dynamic>;
        return data
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('‼️ fetchAllProducts API error ${resp.statusCode}');
        return [];
      }
    } catch (e, st) {
      debugPrint('❌ fetchAllProducts exception: $e\n$st');
      return [];
    }
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
  Future<List<ProductVariant>> fetchVariants(String productId) async {
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

  /// GET /api/products/category/{categoryId}
  static Future<List<Product>> fetchProductsByCategory(String categoryId) async {
    final uri = Uri.parse('$_productsPath/category/$categoryId');
    debugPrint('→ GET $uri');
    try {
      final resp = await http.get(uri);
      debugPrint('← ${resp.statusCode} ${resp.body}');
      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body) as List<dynamic>;
        return data
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('‼️ fetchProductsByCategory API error ${resp.statusCode}');
        return [];
      }
    } catch (e, st) {
      debugPrint('❌ fetchProductsByCategory exception: $e\n$st');
      return [];
    }
  }

  /// GET /api/product-tags/by-tag/{tagId}
  static Future<List<Product>> fetchProductsByTag(String tagId) async {
    final uri = Uri.parse('$_productTags/by-tag/$tagId');
    debugPrint('→ GET $uri');
    try {
      final resp = await http.get(uri);
      debugPrint('← ${resp.statusCode} ${resp.body}');
      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body) as List<dynamic>;
        return data
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('‼️ fetchProductsByTag API error ${resp.statusCode}');
        return [];
      }
    } catch (e, st) {
      debugPrint('❌ fetchProductsByTag exception: $e\n$st');
      return [];
    }
  }

  /// GET /api/categories
  static Future<List<Category>> fetchAllCategories() async {
    final uri = Uri.parse(_categories);
    debugPrint('→ GET $uri');
    try {
      final resp = await http.get(uri);
      debugPrint('← ${resp.statusCode} ${resp.body}');
      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body) as List<dynamic>;
        return data
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('‼️ fetchAllCategories API error ${resp.statusCode}');
        return [];
      }
    } catch (e, st) {
      debugPrint('❌ fetchAllCategories exception: $e\n$st');
      return [];
    }
  }

  /// GET /api/Tag
  static Future<List<Tag>> fetchAllTags() async {
    final uri = Uri.parse(_tags);
    debugPrint('→ GET $uri');
    try {
      final resp = await http.get(uri);
      debugPrint('← ${resp.statusCode} ${resp.body}');
      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body) as List<dynamic>;
        return data
            .map((e) => Tag.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('‼️ fetchAllTags API error ${resp.statusCode}');
        return [];
      }
    } catch (e, st) {
      debugPrint('❌ fetchAllTags exception: $e\n$st');
      return [];
    }
  }
}
