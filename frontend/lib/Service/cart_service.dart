// lib/services/cart_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Cart.dart';
import '../models/CartItem.dart';

/// Service to interact with cart-related API endpoints.
class CartService {
  final String _baseUrl = 'http://localhost:5005/api/carts';

  /// GET /api/carts/{userId}
  /// Nếu chưa có cart, tạo mới.
  Future<Cart> fetchCart(String userId) async {
    final uri = Uri.parse('$_baseUrl/$userId');
    final resp = await http.get(uri);

    if (resp.statusCode == 200) {
      return Cart.fromJson(json.decode(resp.body) as Map<String, dynamic>);
    } else if (resp.statusCode == 404) {
      return createCart(userId);
    }

    throw Exception('Failed to fetch cart (status: ${resp.statusCode})');
  }

  /// POST /api/carts
  Future<Cart> createCart(String userId) async {
    final uri = Uri.parse(_baseUrl);
    final body = json.encode({
      'userId': userId,
      'items': [],
    });
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (resp.statusCode == 201) {
      return Cart.fromJson(json.decode(resp.body) as Map<String, dynamic>);
    }
    throw Exception('Failed to create cart (status: ${resp.statusCode})');
  }

  /// PATCH /api/carts/{cartId}/items
  Future<void> addOrUpdateItem(String cartId, CartItem item) async {
    final uri = Uri.parse('$_baseUrl/$cartId/items');
    final resp = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(item.toJson()),
    );
    if (resp.statusCode != 204) {
      throw Exception('Failed to upsert item (status: ${resp.statusCode})');
    }
  }

  /// DELETE /api/carts/{cartId}/items/{itemId}
  Future<void> removeItem(String cartId, String itemId) async {
    final uri = Uri.parse('$_baseUrl/$cartId/items/$itemId');
    final resp = await http.delete(uri);
    if (resp.statusCode != 204) {
      throw Exception('Failed to remove item (status: ${resp.statusCode})');
    }
  }

  /// Helper method: fetchCart + addOrUpdateItem + re-fetch
  Future<Cart> addToCart({
    required String userId,
    required String productId,
    String? productVariantId,
    int quantity = 1,
  }) async {
    final cart = await fetchCart(userId);
    final item = CartItem(
      productId: productId,
      productVariantId: productVariantId,
      quantity: quantity,
    );
    await addOrUpdateItem(cart.id, item);
    return fetchCart(userId);
  }
}
