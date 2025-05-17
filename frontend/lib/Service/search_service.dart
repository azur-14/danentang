import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/product.dart';
import '../models/category.dart';

class SearchService {
  // Dữ liệu tĩnh cho sản phẩm laptop
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'MacBook Pro 14"',
      price: 1999.99,
      brand: 'Apple',
      categoryId: 'high-end-laptop',
      description: 'Laptop cao cấp với chip M1 Max',
      images: [ProductImage(id: '1', url: 'https://via.placeholder.com/150?text=MacBook+Pro', sortOrder: 1)],
      discountPercentage: 5,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 5, 1),
      variants: [
        ProductVariant(
          id: 'v1-1',
          variantName: '16GB RAM, 1TB SSD',
          additionalPrice: 0.0, // Giá cơ bản
          inventory: 15,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 5, 1),
        ),
        ProductVariant(
          id: 'v1-2',
          variantName: '32GB RAM, 1TB SSD',
          additionalPrice: 400.0, // Tăng 400 USD so với giá cơ bản
          inventory: 10,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 5, 1),
        ),
      ],
    ),
    Product(
      id: '2',
      name: 'Dell XPS 13',
      price: 1299.99,
      brand: 'Dell',
      categoryId: 'high-end-laptop',
      description: 'Laptop mỏng nhẹ, Intel Core i7',
      images: [ProductImage(id: '2', url: 'https://via.placeholder.com/150?text=Dell+XPS+13', sortOrder: 1)],
      discountPercentage: 10,
      createdAt: DateTime(2025, 2, 1),
      updatedAt: DateTime(2025, 5, 10),
      variants: [
        ProductVariant(
          id: 'v2-1',
          variantName: '16GB RAM, 512GB SSD',
          additionalPrice: 0.0, // Giá cơ bản
          inventory: 20,
          createdAt: DateTime(2025, 2, 1),
          updatedAt: DateTime(2025, 5, 10),
        ),
        ProductVariant(
          id: 'v2-2',
          variantName: '8GB RAM, 256GB SSD',
          additionalPrice: -200.0, // Giảm 200 USD so với giá cơ bản
          inventory: 25,
          createdAt: DateTime(2025, 2, 1),
          updatedAt: DateTime(2025, 5, 10),
        ),
      ],
    ),
    Product(
      id: '3',
      name: 'Lenovo ThinkPad X1 Carbon',
      price: 1499.99,
      brand: 'Lenovo',
      categoryId: 'office-laptop',
      description: 'Laptop văn phòng bền bỉ, Intel Core i5',
      images: [ProductImage(id: '3', url: 'https://via.placeholder.com/150?text=ThinkPad+X1', sortOrder: 1)],
      discountPercentage: 0,
      createdAt: DateTime(2025, 3, 1),
      updatedAt: DateTime(2025, 5, 15),
      variants: [
        ProductVariant(
          id: 'v3-1',
          variantName: '8GB RAM, 256GB SSD',
          additionalPrice: 0.0, // Giá cơ bản
          inventory: 30,
          createdAt: DateTime(2025, 3, 1),
          updatedAt: DateTime(2025, 5, 15),
        ),
        ProductVariant(
          id: 'v3-2',
          variantName: '16GB RAM, 512GB SSD',
          additionalPrice: 200.0, // Tăng 200 USD so với giá cơ bản
          inventory: 12,
          createdAt: DateTime(2025, 3, 1),
          updatedAt: DateTime(2025, 5, 15),
        ),
      ],
    ),
    Product(
      id: '4',
      name: 'HP Spectre x360',
      price: 1599.99,
      brand: 'HP',
      categoryId: 'high-end-laptop',
      description: 'Laptop 2-trong-1, Intel Core i7',
      images: [ProductImage(id: '4', url: 'https://via.placeholder.com/150?text=HP+Spectre', sortOrder: 1)],
      discountPercentage: 8,
      createdAt: DateTime(2025, 4, 1),
      updatedAt: DateTime(2025, 5, 12),
      variants: [
        ProductVariant(
          id: 'v4-1',
          variantName: '16GB RAM, 1TB SSD',
          additionalPrice: 0.0, // Giá cơ bản
          inventory: 18,
          createdAt: DateTime(2025, 4, 1),
          updatedAt: DateTime(2025, 5, 12),
        ),
        ProductVariant(
          id: 'v4-2',
          variantName: '16GB RAM, 512GB SSD',
          additionalPrice: -200.0,
          inventory: 22,
          createdAt: DateTime(2025, 4, 1),
          updatedAt: DateTime(2025, 5, 12),
        ),
      ],
    ),
  ];

  // Danh mục chỉ liên quan đến laptop
  final List<Category> _categories = [
    Category(id: 'high-end-laptop', name: 'Laptop Cao Cấp', createdAt: DateTime.now()),
    Category(id: 'office-laptop', name: 'Laptop Văn Phòng', createdAt: DateTime.now()),
  ];

  List<String> _searchHistory = [];

  // Chuẩn hóa chuỗi tiếng Việt (loại bỏ dấu)
  String _normalizeString(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[àáảãạăắằẳẵặâấầẩẫậ]'), 'a')
        .replaceAll(RegExp(r'[èéẻẽẹêếềểễệ]'), 'e')
        .replaceAll(RegExp(r'[ìíỉĩị]'), 'i')
        .replaceAll(RegExp(r'[òóỏõọôốồổỗộơớờởỡợ]'), 'o')
        .replaceAll(RegExp(r'[ùúủũụưứừửữự]'), 'u')
        .replaceAll(RegExp(r'[ỳýỷỹỵ]'), 'y')
        .replaceAll(RegExp(r'[đ]'), 'd');
  }

  List<String> getSearchHistory() => _searchHistory;

  void clearSearchHistory() => _searchHistory.clear();

  void removeFromSearchHistory(String query) => _searchHistory.remove(query);

  // Tìm kiếm sản phẩm
  Future<List<Product>> searchProducts(
      String query, {
        List<String> brands = const [],
        double? minPrice,
        double? maxPrice,
        String? category,
      }) async {
    try {
      List<Product> results = _products;

      // Kiểm tra minPrice <= maxPrice
      if (minPrice != null && maxPrice != null && minPrice > maxPrice) {
        return [];
      }

      // Lưu lịch sử tìm kiếm
      if (query.isNotEmpty && !_searchHistory.contains(query)) {
        _searchHistory.add(query);
      }

      // Lọc theo từ khóa
      if (query.isNotEmpty) {
        final normalizedQuery = _normalizeString(query);
        results = results.where((product) {
          final normalizedName = _normalizeString(product.name);
          final normalizedDescription = _normalizeString(product.description ?? '');
          return normalizedName.contains(normalizedQuery) ||
              normalizedDescription.contains(normalizedQuery);
        }).toList();
      }

      // Lọc theo thương hiệu
      if (brands.isNotEmpty) {
        results = results.where((product) => brands.contains(product.brand)).toList();
      }

      // Lọc theo giá
      if (minPrice != null) {
        results = results.where((product) => product.price >= minPrice).toList();
      }
      if (maxPrice != null) {
        results = results.where((product) => product.price <= maxPrice).toList();
      }

      // Lọc theo danh mục
      if (category != null && category.isNotEmpty) {
        results = results.where((product) => product.categoryId == category).toList();
      }

      debugPrint('Kết quả lọc: ${results.length} sản phẩm');
      return results;
    } catch (e) {
      debugPrint('Lỗi tìm kiếm: $e');
      throw Exception('Không thể tìm kiếm sản phẩm: $e');
    }
  }

  // Gợi ý tự động
  Future<List<String>> autocomplete(String query) async {
    if (query.isEmpty) return [];
    try {
      final normalizedQuery = _normalizeString(query);
      return _products
          .where((product) => _normalizeString(product.name).contains(normalizedQuery))
          .map((product) => product.name)
          .take(5) // Giới hạn 5 gợi ý
          .toList();
    } catch (e) {
      debugPrint('Lỗi gợi ý: $e');
      return [];
    }
  }

  // Lấy danh sách thương hiệu
  Future<List<String?>> getBrands() async {
    try {
      return _products.map((product) => product.brand).toSet().toList();
    } catch (e) {
      debugPrint('Lỗi lấy thương hiệu: $e');
      return [];
    }
  }

  // Lấy danh sách danh mục
  Future<List<String?>> getCategories() async {
    try {
      return _categories.map((category) => category.id).toList();
    } catch (e) {
      debugPrint('Lỗi lấy danh mục: $e');
      return [];
    }
  }

  // Lấy tên danh mục theo ID
  Future<String> getCategoryName(String categoryId) async {
    try {
      final category = _categories.firstWhere((cat) => cat.id == categoryId, orElse: () => Category(id: '', name: 'Không xác định', createdAt: DateTime.now()));
      return category.name;
    } catch (e) {
      debugPrint('Lỗi lấy tên danh mục: $e');
      return 'Không xác định';
    }
  }
}