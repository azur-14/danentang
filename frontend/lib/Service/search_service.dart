import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/product.dart';
import '../models/category.dart';
import '../models/review.dart';

class SearchService {
  // Danh sách sản phẩm mẫu (tĩnh)
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'MacBook Pro 14"',
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
          additionalPrice: 2200.0,
          inventory: 15,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 5, 1),
        ),
        ProductVariant(
          id: 'v1-2',
          variantName: '32GB RAM, 1TB SSD',
          additionalPrice: 2600.0,
          inventory: 10,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 5, 1),
        ),
      ],
    ),
    Product(
      id: '2',
      name: 'Dell XPS 13',
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
          additionalPrice: 1600.0,
          inventory: 20,
          createdAt: DateTime(2025, 2, 1),
          updatedAt: DateTime(2025, 5, 10),
        ),
        ProductVariant(
          id: 'v2-2',
          variantName: '8GB RAM, 256GB SSD',
          additionalPrice: 1400.0,
          inventory: 25,
          createdAt: DateTime(2025, 2, 1),
          updatedAt: DateTime(2025, 5, 10),
        ),
      ],
    ),
    Product(
      id: '3',
      name: 'Lenovo ThinkPad X1 Carbon',
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
          additionalPrice: 1200.0,
          inventory: 30,
          createdAt: DateTime(2025, 3, 1),
          updatedAt: DateTime(2025, 5, 15),
        ),
        ProductVariant(
          id: 'v3-2',
          variantName: '16GB RAM, 512GB SSD',
          additionalPrice: 1400.0,
          inventory: 12,
          createdAt: DateTime(2025, 3, 1),
          updatedAt: DateTime(2025, 5, 15),
        ),
      ],
    ),
    Product(
      id: '4',
      name: 'HP Spectre x360',
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
          additionalPrice: 2000.0,
          inventory: 18,
          createdAt: DateTime(2025, 4, 1),
          updatedAt: DateTime(2025, 5, 12),
        ),
        ProductVariant(
          id: 'v4-2',
          variantName: '16GB RAM, 512GB SSD',
          additionalPrice: 1800.0,
          inventory: 22,
          createdAt: DateTime(2025, 4, 1),
          updatedAt: DateTime(2025, 5, 12),
        ),
      ],
    ),
  ];

  // Danh sách đánh giá mẫu (tĩnh)
  final List<Review> _reviews = [
    Review(
      id: 'r1',
      productId: '1',
      userId: 'user1',
      comment: 'Hiệu năng tuyệt vời, pin lâu.',
      rating: 5,
      createdAt: DateTime(2025, 5, 1),
    ),
    Review(
      id: 'r2',
      productId: '1',
      guestName: 'Khách',
      comment: 'Màn hình đẹp, nhưng giá hơi cao.',
      rating: 4,
      createdAt: DateTime(2025, 5, 2),
    ),
    Review(
      id: 'r3',
      productId: '2',
      userId: 'user2',
      comment: 'Thiết kế mỏng nhẹ, rất tiện dụng.',
      rating: 4,
      createdAt: DateTime(2025, 5, 5),
    ),
    Review(
      id: 'r4',
      productId: '2',
      guestName: 'Khách',
      comment: 'Hiệu năng ổn, nhưng loa hơi nhỏ.',
      rating: 3,
      createdAt: DateTime(2025, 5, 6),
    ),
    Review(
      id: 'r5',
      productId: '3',
      userId: 'user3',
      comment: 'Bền bỉ, phù hợp công việc văn phòng.',
      rating: 4,
      createdAt: DateTime(2025, 5, 10),
    ),
    Review(
      id: 'r6',
      productId: '4',
      guestName: 'Khách',
      comment: 'Máy đẹp, cảm ứng mượt.',
      rating: 5,
      createdAt: DateTime(2025, 5, 12),
    ),
  ];

  // Danh mục mẫu
  final List<Category> _categories = [
    Category(id: 'high-end-laptop', name: 'Laptop Cao Cấp', createdAt: DateTime.now()),
    Category(id: 'office-laptop', name: 'Laptop Văn Phòng', createdAt: DateTime.now()),
  ];

  List<String> _searchHistory = [];

  /// Chuẩn hóa tiếng Việt
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

  /// Lấy lịch sử tìm kiếm
  List<String> getSearchHistory() => _searchHistory;

  void clearSearchHistory() => _searchHistory.clear();

  void removeFromSearchHistory(String query) => _searchHistory.remove(query);

  /// Lấy danh sách đánh giá theo productId
  Future<List<Review>> getReviewsByProductId(String productId) async {
    try {
      return _reviews.where((review) => review.productId == productId).toList();
    } catch (e) {
      debugPrint('Lỗi lấy đánh giá: $e');
      return [];
    }
  }

  /// Tính rating trung bình của sản phẩm
  Future<double> _getAverageRating(String productId) async {
    final reviews = await getReviewsByProductId(productId);
    final validReviews = reviews.where((r) => r.rating != null).toList();
    if (validReviews.isEmpty) return 0.0;
    return validReviews.map((r) => r.rating!.toDouble()).reduce((a, b) => a + b) / validReviews.length;
  }

  /// Tìm kiếm sản phẩm
  Future<List<Product>> searchProducts(
      String query, {
        List<String> brands = const [],
        double? minPrice,
        double? maxPrice,
        String? category,
        double? minRating,
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

      // Lọc theo giá dựa trên minPrice (giá variant thấp nhất)
      if (minPrice != null) {
        results = results.where((product) => product.minPrice >= minPrice).toList();
      }
      if (maxPrice != null) {
        results = results.where((product) => product.minPrice <= maxPrice).toList();
      }

      // Lọc theo danh mục
      if (category != null && category.isNotEmpty) {
        results = results.where((product) => product.categoryId == category).toList();
      }

      // Lọc theo rating trung bình
      if (minRating != null) {
        results = (await Future.wait(results.map((product) async {
          final avgRating = await _getAverageRating(product.id);
          return avgRating >= minRating ? product : null;
        }))).whereType<Product>().toList();
      }

      debugPrint('Kết quả lọc: ${results.length} sản phẩm');
      return results;
    } catch (e) {
      debugPrint('Lỗi tìm kiếm: $e');
      throw Exception('Không thể tìm kiếm sản phẩm: $e');
    }
  }

  /// Gợi ý autocomplete
  Future<List<String>> autocomplete(String query) async {
    if (query.isEmpty) return [];
    try {
      final normalizedQuery = _normalizeString(query);
      return _products
          .where((product) => _normalizeString(product.name).contains(normalizedQuery))
          .map((product) => product.name)
          .take(5)
          .toList();
    } catch (e) {
      debugPrint('Lỗi gợi ý: $e');
      return [];
    }
  }

  /// Lấy danh sách thương hiệu
  Future<List<String?>> getBrands() async {
    try {
      return _products.map((product) => product.brand).toSet().toList();
    } catch (e) {
      debugPrint('Lỗi lấy thương hiệu: $e');
      return [];
    }
  }

  /// Lấy danh sách danh mục
  Future<List<String?>> getCategories() async {
    try {
      return _categories.map((category) => category.id).toList();
    } catch (e) {
      debugPrint('Lỗi lấy danh mục: $e');
      return [];
    }
  }

  /// Lấy tên danh mục theo ID
  Future<String> getCategoryName(String categoryId) async {
    try {
      final category = _categories.firstWhere(
            (cat) => cat.id == categoryId,
        orElse: () => Category(id: '', name: 'Không xác định', createdAt: DateTime.now()),
      );
      return category.name;
    } catch (e) {
      debugPrint('Lỗi lấy tên danh mục: $e');
      return 'Không xác định';
    }
  }

  /// Lấy sản phẩm có rating cao
  Future<List<Product>> getHighRatedProducts({required double minRating}) async {
    try {
      final results = (await Future.wait(_products.map((product) async {
        final avgRating = await _getAverageRating(product.id);
        return avgRating >= minRating ? product : null;
      }))).whereType<Product>().toList();
      debugPrint('Sản phẩm rating cao: ${results.length} sản phẩm');
      return results;
    } catch (e) {
      debugPrint('Lỗi lấy sản phẩm rating cao: $e');
      return [];
    }
  }
}