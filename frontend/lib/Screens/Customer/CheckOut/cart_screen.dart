// lib/screens/cart_screen_checkout.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:danentang/models/CartItem.dart';
import 'package:danentang/models/Cart.dart';
import 'package:danentang/models/Order.dart';
import 'package:danentang/models/OrderItem.dart';
import 'package:danentang/models/OrderStatusHistory.dart';
import 'package:danentang/models/ShippingAddress.dart';

import 'package:danentang/Service/order_service.dart';

import 'package:danentang/widgets/Cart_CheckOut/cart_item_widget.dart';
import 'package:danentang/widgets/Cart_CheckOut/order_summary_widget.dart';
import 'package:danentang/widgets/Header/web_header.dart';
import 'package:danentang/widgets/Search/web_search_bar.dart';
import 'package:danentang/constants/colors.dart';

class CartScreenCheckOut extends StatefulWidget {
  final bool isLoggedIn;
  final String? userId;

  const CartScreenCheckOut({
    Key? key,
    required this.isLoggedIn,
    this.userId,
  }) : super(key: key);

  @override
  _CartScreenCheckOutState createState() => _CartScreenCheckOutState();
}

class _CartScreenCheckOutState extends State<CartScreenCheckOut> {
  final OrderService _api = OrderService.instance;
  Future<Cart>? _cartFuture;
  late String _effectiveUserId;

  bool isEditing = false;
  bool applyPoints = false;
  final TextEditingController _discountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initUserIdAndFetchCart();
  }

  Future<void> _initUserIdAndFetchCart() async {
    if (widget.isLoggedIn && widget.userId != null) {
      _effectiveUserId = widget.userId!;
    } else {
      final prefs = await SharedPreferences.getInstance();
      String? guestId = prefs.getString('guestId');
      if (guestId == null) {
        guestId = Uuid().v4();
        await prefs.setString('guestId', guestId);
      }
      _effectiveUserId = guestId;
    }
    setState(() {
      _cartFuture = _api.fetchCart(_effectiveUserId);
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _cartFuture = _api.fetchCart(_effectiveUserId);
    });
  }

  Future<double> _calculateSubtotal(List<CartItem> items) async {
    double subtotal = 0.0;
    for (final item in items) {
      final info = await _api.fetchProductInfo(
          item.productId, item.productVariantId);
      subtotal += info['price'] * item.quantity;
    }
    return subtotal;
  }

  double get _discount => applyPoints ? 60000 : 0;

  double get _shipping => 50000;

  double get _vat => 0;

  Future<void> _onCheckout(Cart cart) async {
    final shipping = ShippingAddress(
      receiverName: 'Nguyễn Văn A',
      phoneNumber: '0912345678',
      addressLine: '123 Trần Hưng Đạo',
      ward: 'Phường 5',
      district: 'Quận 1',
      city: 'TP.HCM',
    );


    try {
      final created = await _api.createOrderFromCart(
        cart: cart,
        shippingAddress: shipping,
        appliedCoupon: null,
        applyPoints: applyPoints,
      );
      context.go('/order-confirmation', extra: created);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout failed: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_cartFuture == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final width = MediaQuery
        .of(context)
        .size
        .width;
    return width > 800 ? _buildWeb(context) : _buildMobile(context);
  }
  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        leading: BackButton(onPressed: () => context.go('/homepage')),
        actions: [
          TextButton(
            onPressed: () => setState(() => isEditing = !isEditing),
            child: Text(
              isEditing ? 'Done' : 'Edit',
              style: TextStyle(color: AppColors.hexToColor(AppColors.black)),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.hexToColor(AppColors.grey),
      body: FutureBuilder<Cart>(
        future: _cartFuture!,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final cart = snap.data!;

          return FutureBuilder<double>(
            future: _calculateSubtotal(cart.items),
            builder: (context, subSnap) {
              if (!subSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final subtotal = subSnap.data!;
              final total = subtotal + _shipping + _vat - _discount;

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (_, i) {
                        final item = cart.items[i];
                        final idToRemove = item.productVariantId ?? item.productId;
                        return CartItemWidget(
                          item: item,
                          isEditing: isEditing,
                          onDelete: () async {
                            await _api.removeCartItem(cart.id, idToRemove);
                            await _refresh();
                          },
                          onQuantityChanged: (qty) async {
                            final updated = CartItem(
                              productId: item.productId,
                              productVariantId: item.productVariantId,
                              quantity: qty,
                            );
                            await _api.upsertCartItem(cart.id, updated);
                            await _refresh();
                          },
                          isMobile: true,
                        );
                      },
                    ),
                  ),
                  OrderSummaryWidget(
                    subtotal: subtotal,
                    vat: _vat,
                    shipping: _shipping,
                    discount: _discount,
                    total: total,
                    applyPoints: applyPoints,
                    discountController: _discountController,
                    onApplyPointsChanged: (v) =>
                        setState(() => applyPoints = v),
                    onCheckout: () => _onCheckout(cart),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
  Widget _buildWeb(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const WebHeader(userData: {}),
          WebSearchBar(isLoggedIn: widget.isLoggedIn),
          Expanded(
            child: FutureBuilder<Cart>(
              future: _cartFuture!,
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }

                final cart = snap.data!;

                return FutureBuilder<double>(
                  future: _calculateSubtotal(cart.items),
                  builder: (context, subSnap) {
                    if (!subSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final subtotal = subSnap.data!;
                    final total = subtotal + _shipping + _vat - _discount;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ListView.builder(
                              itemCount: cart.items.length,
                              itemBuilder: (_, i) {
                                final item = cart.items[i];
                                final idToRemove = item.productVariantId ??
                                    item.productId;
                                return CartItemWidget(
                                  item: item,
                                  isEditing: isEditing,
                                  onDelete: () async {
                                    await _api.removeCartItem(
                                        cart.id, idToRemove);
                                    await _refresh();
                                  },
                                  onQuantityChanged: (qty) async {
                                    final updated = CartItem(
                                      productId: item.productId,
                                      productVariantId: item.productVariantId,
                                      quantity: qty,
                                    );
                                    await _api.upsertCartItem(cart.id, updated);
                                    await _refresh();
                                  },
                                  isMobile: false,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 2,
                            child: OrderSummaryWidget(
                              subtotal: subtotal,
                              vat: _vat,
                              shipping: _shipping,
                              discount: _discount,
                              total: total,
                              applyPoints: applyPoints,
                              discountController: _discountController,
                              onApplyPointsChanged: (v) =>
                                  setState(() => applyPoints = v),
                              onCheckout: () => _onCheckout(cart),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}