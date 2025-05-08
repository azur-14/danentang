// lib/screens/cart_screen_checkout.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:danentang/models/CartItem.dart';
import 'package:danentang/models/Cart.dart';
import 'package:danentang/Service/cart_service.dart';
import 'package:danentang/widgets/Cart_CheckOut/cart_item_widget.dart';
import 'package:danentang/widgets/Cart_CheckOut/order_summary_widget.dart';
import 'package:danentang/widgets/Header/web_header.dart';
import 'package:danentang/widgets/Search/web_search_bar.dart';
import 'package:danentang/constants/colors.dart';
import 'package:uuid/uuid.dart';

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
  final CartService _service = CartService();

  Future<Cart>? _cartFuture;              // made nullable
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
        guestId = const Uuid().v4();
        await prefs.setString('guestId', guestId);
      }
      _effectiveUserId = guestId;
    }
    setState(() {
      _cartFuture = _service.fetchCart(_effectiveUserId);
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _cartFuture = _service.fetchCart(_effectiveUserId);
    });
  }

  double _subtotal(List<CartItem> items) =>
      items.fold<double>(0, (sum, i) => sum + i.currentPrice * i.quantity);

  double get _discount => applyPoints ? 60000 : 0;
  double get _shipping => 50000;
  double get _vat => 0;

  @override
  Widget build(BuildContext context) {
    // If _cartFuture hasn't been set yet, show a loader
    if (_cartFuture == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 800
        ? _buildWebLayout(context)
        : _buildMobileLayout(context);
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => isEditing = !isEditing),
            child: Text(
              isEditing ? 'Xong' : 'Chỉnh sửa',
              style: TextStyle(color: AppColors.hexToColor(AppColors.black)),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.hexToColor(AppColors.grey),
      body: FutureBuilder<Cart>(
        future: _cartFuture,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final cart = snap.data!;
          final items = cart.items;
          final subtotal = _subtotal(items);
          final total = subtotal + _shipping + _vat - _discount;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final item = items[i];
                    return CartItemWidget(
                      item: item,
                      isEditing: isEditing,
                      onDelete: () async {
                        final idToRemove =
                            item.productVariantId ?? item.productId;
                        await _service.removeItem(cart.id, idToRemove);
                        await _refresh();
                      },
                      onQuantityChanged: (newQty) async {
                        final updatedItem = CartItem(
                          productId: item.productId,
                          productVariantId: item.productVariantId,
                          quantity: newQty,
                        );
                        await _service.addOrUpdateItem(
                            cart.id, updatedItem);
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
                onCheckout: () => context.go(
                  '/checkout',
                  extra: {
                    'isLoggedIn': widget.isLoggedIn,
                    'userId': _effectiveUserId,
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const WebHeader(),
          WebSearchBar(isLoggedIn: widget.isLoggedIn),
          Expanded(
            child: FutureBuilder<Cart>(
              future: _cartFuture,
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final cart = snap.data!;
                final items = cart.items;
                final subtotal = _subtotal(items);
                final total = subtotal + _shipping + _vat - _discount;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (_, i) {
                            final item = items[i];
                            return CartItemWidget(
                              item: item,
                              isEditing: isEditing,
                              onDelete: () async {
                                final idToRemove =
                                    item.productVariantId ??
                                        item.productId;
                                await _service.removeItem(
                                    cart.id, idToRemove);
                                await _refresh();
                              },
                              onQuantityChanged: (newQty) async {
                                final updatedItem = CartItem(
                                  productId: item.productId,
                                  productVariantId:
                                  item.productVariantId,
                                  quantity: newQty,
                                );
                                await _service.addOrUpdateItem(
                                    cart.id, updatedItem);
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
                          onCheckout: () => context.go(
                            '/checkout',
                            extra: {
                              'isLoggedIn': widget.isLoggedIn,
                              'userId': _effectiveUserId,
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
