// lib/screens/cart_screen_checkout.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:danentang/models/CartItem.dart';
import 'package:danentang/models/Cart.dart';
import 'package:danentang/Service/cart_service.dart';
import 'package:danentang/widgets/Cart_CheckOut/cart_item_widget.dart';
import 'package:danentang/widgets/Cart_CheckOut/order_summary_widget.dart';
import 'package:danentang/widgets/Header/web_header.dart';
import 'package:danentang/widgets/Search/web_search_bar.dart';
import 'package:danentang/constants/colors.dart';

class CartScreenCheckOut extends StatefulWidget {
  final bool isLoggedIn;
  final String userId;

  const CartScreenCheckOut({
    Key? key,
    required this.isLoggedIn,
    required this.userId,
  }) : super(key: key);

  @override
  _CartScreenCheckOutState createState() => _CartScreenCheckOutState();
}

class _CartScreenCheckOutState extends State<CartScreenCheckOut> {
  final CartService _service = CartService();
  late Future<Cart> _cartFuture;
  bool isEditing = false;
  bool applyPoints = false;
  final TextEditingController _discountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cartFuture = _service.fetchCart(widget.userId);
  }

  Future<void> _refresh() async {
    setState(() {
      _cartFuture = _service.fetchCart(widget.userId);
    });
  }

  // Chỉ dùng price * quantity, bỏ discountPercentage
  double _subtotal(List<CartItem> items) =>
      items.where((i) => i.isSelected).fold<double>(
          0, (sum, i) => sum + i.price * i.quantity);

  double get _discount => applyPoints ? 60000 : 0;
  double get _shipping => 50000;
  double get _vat => 0;

  @override
  Widget build(BuildContext context) {
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
                        await _service.removeItem(
                            cart.id, item.productVariantId);
                        await _refresh();
                      },
                      onQuantityChanged: (newQty) async {
                        item.quantity = newQty;
                        await _service.addOrUpdateItem(cart.id, item);
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
                    'userId': widget.userId,
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
                      // Danh sách sản phẩm
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
                                await _service.removeItem(
                                    cart.id, item.productVariantId);
                                await _refresh();
                              },
                              onQuantityChanged: (newQty) async {
                                item.quantity = newQty;
                                await _service.addOrUpdateItem(
                                    cart.id, item);
                                await _refresh();
                              },
                              isMobile: false,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Order summary
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
                              'userId': widget.userId,
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
