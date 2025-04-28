import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:danentang/models/CartItem.dart';
import 'package:danentang/data/cart_data.dart';
import 'package:danentang/widgets/Cart_CheckOut/cart_item_widget.dart';
import 'package:danentang/widgets/Cart_CheckOut/order_summary_widget.dart';
import 'package:danentang/widgets/Header/web_header.dart';
import 'package:danentang/widgets/Search/web_search_bar.dart';
import 'package:danentang/constants/colors.dart';

class CartScreenCheckOut extends StatefulWidget {
  final bool isLoggedIn;

  const CartScreenCheckOut({required this.isLoggedIn});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreenCheckOut> {
  late List<CartItem> cartItems;
  bool isEditing = false;
  bool applyPoints = false;
  final _discountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cartItems = CartData.cartItems; // Load initial cart data
  }

  double get subtotal => cartItems
      .where((item) => item.isSelected)
      .fold(0, (sum, item) {
    final discountedPrice = item.product.price * (1 - item.product.discountPercentage / 100);
    return sum + (discountedPrice * item.quantity);
  });

  double get discount => applyPoints ? 60000 : 0;
  double get shipping => 50000;
  double get vat => 0;
  double get total => subtotal + vat + shipping - discount;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 800 ? _buildWebLayout(context) : _buildMobileLayout(context);
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My cart"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
            child: Text(
              isEditing ? "Xong" : "Chỉnh sửa",
              style: TextStyle(color: AppColors.hexToColor(AppColors.black)),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.hexToColor(AppColors.grey),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return CartItemWidget(
                  item: item,
                  isEditing: isEditing,
                  onDelete: () {
                    setState(() {
                      cartItems.removeAt(index);
                    });
                  },
                  onQuantityChanged: (newQuantity) {
                    setState(() {
                      item.quantity = newQuantity;
                    });
                  },
                  isMobile: true,
                );
              },
            ),
          ),
          OrderSummaryWidget(
            subtotal: subtotal,
            vat: vat,
            shipping: shipping,
            discount: discount,
            total: total,
            applyPoints: applyPoints,
            discountController: _discountController,
            onApplyPointsChanged: (value) {
              setState(() {
                applyPoints = value;
              });
            },
            onCheckout: () {
              context.go('/checkout', extra: widget.isLoggedIn);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const WebHeader(),
          WebSearchBar(isLoggedIn: widget.isLoggedIn),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "YOUR CART",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isEditing = !isEditing;
                        });
                      },
                      child: Text(
                        isEditing ? "Xong" : "Chỉnh sửa",
                        style: TextStyle(color: AppColors.hexToColor(AppColors.black)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return CartItemWidget(
                            item: item,
                            isEditing: isEditing,
                            onDelete: () {
                              setState(() {
                                cartItems.removeAt(index);
                              });
                            },
                            onQuantityChanged: (newQuantity) {
                              setState(() {
                                item.quantity = newQuantity;
                              });
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
                        vat: vat,
                        shipping: shipping,
                        discount: discount,
                        total: total,
                        applyPoints: applyPoints,
                        discountController: _discountController,
                        onApplyPointsChanged: (value) {
                          setState(() {
                            applyPoints = value;
                          });
                        },
                        onCheckout: () {
                          context.go('/checkout', extra: widget.isLoggedIn);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}