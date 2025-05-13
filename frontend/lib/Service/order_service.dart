import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:danentang/models/Cart.dart';
import 'package:danentang/models/CartItem.dart';
import 'package:danentang/models/Coupon.dart';
import 'package:danentang/models/Order.dart';
import 'package:danentang/models/OrderStatusHistory.dart';

class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();

  static const String _baseUrl = 'http://localhost:5005/api';
  final http.Client _http = http.Client();
  final Uuid _uuid = Uuid();

  // ───────────────────────────────────────────────
  // CART
  // ───────────────────────────────────────────────

  Future<Cart> fetchCart(String userId) async {
    final uri = Uri.parse('$_baseUrl/carts/$userId');
    debugPrint('→ GET $uri');
    final resp = await _http.get(uri);
    debugPrint('← ${resp.statusCode} ${resp.body}');

    if (resp.statusCode == 200) {
      return Cart.fromJson(json.decode(resp.body));
    }
    if (resp.statusCode == 404) {
      return createCart(userId);
    }
    throw Exception('fetchCart failed (${resp.statusCode})');
  }

  Future<Cart> createCart(String userId) async {
    final uri = Uri.parse('$_baseUrl/carts');
    final now = DateTime.now().toUtc().toIso8601String();
    final generatedId = _uuid.v4();

    final payload = {
      'id': generatedId,
      'userId': userId,
      'items': <dynamic>[],
      'createdAt': now,
      'updatedAt': now,
    };

    debugPrint('→ POST $uri  body=$payload');
    final resp = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );
    debugPrint('← ${resp.statusCode} ${resp.body}');

    if (resp.statusCode == 201) {
      return Cart.fromJson(json.decode(resp.body));
    }
    throw Exception('createCart failed (${resp.statusCode})');
  }

  Future<void> upsertCartItemSmart(Cart cart, CartItem newItem) async {
    final existing = cart.items.firstWhere(
          (i) => i.productVariantId == newItem.productVariantId,
      orElse: () => CartItem.empty(),
    );
    if (existing.productId != null) {
      existing.quantity += newItem.quantity;
      await replaceCartItems(cart.id, cart.items);
    } else {
      await upsertCartItem(cart.id, newItem);
    }
  }

  Future<void> replaceCartItems(String cartId, List<CartItem> items) async {
    final uri = Uri.parse('$_baseUrl/carts/$cartId');
    final payload = json.encode(items.map((e) => e.toJson()).toList());
    final resp = await _http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: payload,
    );
    if (resp.statusCode != 204) {
      throw Exception('replaceCartItems failed (${resp.statusCode})');
    }
  }

  Future<void> clearCart(String cartId) async {
    await replaceCartItems(cartId, []);
  }

  Future<void> upsertCartItem(String cartId, CartItem item) async {
    final uri = Uri.parse('$_baseUrl/carts/$cartId/items');
    final body = json.encode(item.toJson());
    debugPrint('→ PATCH $uri  body=$body');
    final resp = await _http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    debugPrint('← ${resp.statusCode}');
    if (resp.statusCode != 204) {
      throw Exception('upsertCartItem failed (${resp.statusCode})');
    }
  }

  Future<void> removeCartItem(String cartId, String variantOrProductId) async {
    final uri = Uri.parse('$_baseUrl/carts/$cartId/items/$variantOrProductId');
    debugPrint('→ DELETE $uri');
    final resp = await _http.delete(uri);
    debugPrint('← ${resp.statusCode}');
    if (resp.statusCode != 204) {
      throw Exception('removeCartItem failed (${resp.statusCode})');
    }
  }

  // ───────────────────────────────────────────────
  // COUPONS
  // ───────────────────────────────────────────────

  Future<List<Coupon>> fetchAllCoupons() async {
    final uri = Uri.parse('$_baseUrl/coupons');
    debugPrint('→ GET $uri');
    final resp = await _http.get(uri);
    debugPrint('← ${resp.statusCode} ${resp.body}');
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as List<dynamic>;
      return data.map((e) => Coupon.fromJson(e)).toList();
    }
    throw Exception('fetchAllCoupons failed (${resp.statusCode})');
  }

  Future<Coupon> getCouponById(String id) async {
    final uri = Uri.parse('$_baseUrl/coupons/$id');
    debugPrint('→ GET $uri');
    final resp = await _http.get(uri);
    debugPrint('← ${resp.statusCode} ${resp.body}');
    if (resp.statusCode == 200) {
      return Coupon.fromJson(json.decode(resp.body));
    }
    throw Exception('getCouponById failed (${resp.statusCode})');
  }

  Future<Coupon> validateCoupon(String code) async {
    final uri = Uri.parse('$_baseUrl/coupons/validate/$code');
    final resp = await _http.get(uri);
    if (resp.statusCode == 200) {
      return Coupon.fromJson(json.decode(resp.body));
    }
    throw Exception('Coupon không hợp lệ (${resp.statusCode})');
  }

  Future<Coupon> createCoupon(Coupon coupon) async {
    final uri = Uri.parse('$_baseUrl/coupons');
    final body = json.encode(coupon.toJson());
    debugPrint('→ POST $uri  body=$body');
    final resp = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    debugPrint('← ${resp.statusCode} ${resp.body}');
    if (resp.statusCode == 201) {
      return Coupon.fromJson(json.decode(resp.body));
    }
    throw Exception('createCoupon failed (${resp.statusCode})');
  }

  Future<void> updateCoupon(Coupon coupon) async {
    final uri = Uri.parse('$_baseUrl/coupons/${coupon.id}');
    final body = json.encode(coupon.toJson());
    debugPrint('→ PUT $uri  body=$body');
    final resp = await _http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    debugPrint('← ${resp.statusCode}');
    if (resp.statusCode != 204) {
      throw Exception('updateCoupon failed (${resp.statusCode})');
    }
  }

  Future<void> deleteCoupon(String id) async {
    final uri = Uri.parse('$_baseUrl/coupons/$id');
    debugPrint('→ DELETE $uri');
    final resp = await _http.delete(uri);
    debugPrint('← ${resp.statusCode}');
    if (resp.statusCode != 204) {
      throw Exception('deleteCoupon failed (${resp.statusCode})');
    }
  }
  Future<Coupon> applyCoupon(String code, String orderId) async {
    final uri = Uri.parse('$_baseUrl/coupons/apply/$code?orderId=$orderId');
    final resp = await _http.post(uri);
    debugPrint('← ${resp.statusCode} ${resp.body}');
    if (resp.statusCode == 200) {
      return Coupon.fromJson(json.decode(resp.body));
    }
    throw Exception('applyCoupon failed (${resp.statusCode})');
  }

  // ───────────────────────────────────────────────
  // ORDERS
  // ───────────────────────────────────────────────

  Future<List<Order>> fetchAllOrders() async {
    final uri = Uri.parse('$_baseUrl/orders');
    debugPrint('→ GET $uri');
    final resp = await _http.get(uri);
    debugPrint('← ${resp.statusCode} ${resp.body}');
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as List<dynamic>;
      return data.map((e) => Order.fromJson(e)).toList();
    }
    throw Exception('fetchAllOrders failed (${resp.statusCode})');
  }

  Future<Order> getOrderById(String id) async {
    final uri = Uri.parse('$_baseUrl/orders/$id');
    debugPrint('→ GET $uri');
    final resp = await _http.get(uri);
    debugPrint('← ${resp.statusCode} ${resp.body}');
    if (resp.statusCode == 200) {
      return Order.fromJson(json.decode(resp.body));
    }
    throw Exception('getOrderById failed (${resp.statusCode})');
  }

  Future<Order> createOrder(Order order) async {
    final uri = Uri.parse('$_baseUrl/orders');
    final body = json.encode(order.toJson());
    debugPrint('→ POST $uri  body=$body');
    final resp = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    debugPrint('← ${resp.statusCode} ${resp.body}');
    if (resp.statusCode == 201) {
      return Order.fromJson(json.decode(resp.body));
    }
    throw Exception('createOrder failed (${resp.statusCode})');
  }

  Future<void> updateOrder(Order order) async {
    final uri = Uri.parse('$_baseUrl/orders/${order.id}');
    final body = json.encode(order.toJson());
    debugPrint('→ PUT $uri  body=$body');
    final resp = await _http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    debugPrint('← ${resp.statusCode}');
    if (resp.statusCode != 204) {
      throw Exception('updateOrder failed (${resp.statusCode})');
    }
  }

  Future<void> deleteOrder(String id) async {
    final uri = Uri.parse('$_baseUrl/orders/$id');
    debugPrint('→ DELETE $uri');
    final resp = await _http.delete(uri);
    debugPrint('← ${resp.statusCode}');
    if (resp.statusCode != 204) {
      throw Exception('deleteOrder failed (${resp.statusCode})');
    }
  }

  Future<void> updateOrderStatus(String id, OrderStatusHistory history) async {
    final uri = Uri.parse('$_baseUrl/orders/$id/status');
    final body = json.encode(history.toJson());
    debugPrint('→ PATCH $uri  body=$body');
    final resp = await _http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    debugPrint('← ${resp.statusCode}');
    if (resp.statusCode != 204) {
      throw Exception('updateOrderStatus failed (${resp.statusCode})');
    }
  }
}
