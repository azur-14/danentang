// lib/services/cart_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Cart.dart';
import '../models/CartItem.dart';
import 'product_service.dart';

class CartService {
  final _cartUrl    = 'http://localhost:5005/api/carts';
  final _productSvc = ProductService();

  Future<Cart> fetchCart(String userId) async {
    final resp = await http.get(Uri.parse('$_cartUrl/$userId'));
    if (resp.statusCode != 200) {
      throw Exception('Failed to load cart');
    }

    final cart = Cart.fromJson(json.decode(resp.body));

    // Fetch lại product cho mỗi CartItem
    for (var item in cart.items) {
      final prod = await _productSvc.getById(item.productId);
      final variant = prod.variants.firstWhere(
              (v) => v.variantName == item.variantName,
          orElse: () => prod.variants.first
      );
      item.currentPrice = prod.price + variant.additionalPrice;
      item.discountPercentage = prod.discountPercentage as double?;
      item.imageUrl = prod.images.isNotEmpty ? prod.images.first.url : null;
    }

    return cart;
  }

  Future<void> addOrUpdateItem(String cartId, CartItem item) async {
    final resp = await http.patch(
      Uri.parse('$_cartUrl/$cartId/items'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(item.toJson()),
    );
    if (resp.statusCode != 204) {
      throw Exception('Failed to upsert item');
    }
  }

  Future<void> removeItem(String cartId, String variantId) async {
    final resp = await http.delete(
      Uri.parse('$_cartUrl/$cartId/items/$variantId'),
    );
    if (resp.statusCode != 204) {
      throw Exception('Failed to delete item');
    }
  }
}
