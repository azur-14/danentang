import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danentang/models/CartItem.dart';
import 'package:danentang/models/Cart.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/models/User.dart';
import 'package:danentang/models/Coupon.dart';
import 'package:danentang/Service/order_service.dart';
import 'package:danentang/Service/product_service.dart';
import 'package:danentang/Service/user_service.dart';
import 'package:danentang/widgets/Cart_CheckOut/cart_item_widget.dart';
import 'package:danentang/widgets/Cart_CheckOut/order_summary_widget.dart';
import 'package:danentang/widgets/Header/web_header.dart';
import 'package:danentang/widgets/Search/web_search_bar.dart';
import 'package:danentang/constants/colors.dart';

import '../Payment/payment_screen.dart';

class CartScreenCheckOut extends StatefulWidget {
  const CartScreenCheckOut({Key? key}) : super(key: key);

  @override
  _CartScreenCheckOutState createState() => _CartScreenCheckOutState();
}

class _CartScreenCheckOutState extends State<CartScreenCheckOut> {
  final OrderService _api = OrderService.instance;
  Future<Cart>? _cartFuture;
  late String _effectiveCartId;
  bool isEditing = false;

  // Coupon & loyalty logic
  Coupon? _appliedCoupon;
  String? _errorCoupon;
  int _couponDiscountAmount = 0;
  bool _applyingCoupon = false;
  int _loyaltyPointsToUse = 0;
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _loyaltyController = TextEditingController();

  User? _currentUser;
  Map<String, Product> _productsById = {};

  @override
  void initState() {
    super.initState();
    _loadUserAndCart();
  }


  Future<void> _loadUserAndCart() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final email = prefs.getString('email');

    Cart cart;

    try {
      if (email != null && token != null) {
        // ✅ Đã đăng nhập
        final user = await UserService().fetchUserByEmail(email);
        setState(() => _currentUser = user);

        cart = await _api.fetchCartByUserId(user.id!);  // ⚠️ dùng hàm này
        _effectiveCartId = cart.id;

        // Lưu cartId lại phòng trường hợp logout
        await prefs.setString('cartId', cart.id);
      } else {
        // ✅ Guest
        String? cartId = prefs.getString('cartId');
        if (cartId == null) {
          final newCart = await _api.createCart('');
          cartId = newCart.id;
          await prefs.setString('cartId', cartId);
        }

        _effectiveCartId = cartId!;
        cart = await _api.fetchCart(_effectiveCartId);  // ⚠️ dùng cartId
        setState(() => _currentUser = null);
      }

      // ✅ Tải trước thông tin sản phẩm
      final ids = cart.items.map((i) => i.productId).toSet().toList();
      final products = await Future.wait(ids.map((id) => ProductService.getById(id)));
      _productsById = {for (var p in products) p.id: p};

      setState(() {
        _cartFuture = Future.value(cart);
      });
    } catch (e) {
      debugPrint('❌ Lỗi khi load giỏ hàng: $e');
      setState(() {
        _cartFuture = Future.error('Không thể tải giỏ hàng');
      });
    }
  }


  Future<void> _refresh() async {
    await _loadUserAndCart();
  }

  Future<double> _calculateSubtotal(List<CartItem> items) async {
    double subtotal = 0.0;
    for (final item in items) {
      final product = _productsById[item.productId];
      final variant = product?.variants.firstWhere(
            (v) => v.id == item.productVariantId,
        orElse: () => product!.variants.first,
      );
      subtotal += (variant?.additionalPrice ?? 0) * item.quantity;
    }
    return subtotal;
  }

  Future<void> _applyCoupon() async {
    final code = _discountController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _applyingCoupon = true;
      _errorCoupon = null;
    });
    try {
      final coupon = await OrderService.instance.validateCoupon(code);
      final cart = await _cartFuture!;
      final subtotal = await _calculateSubtotal(cart.items);

      // CHECK: chỉ áp dụng coupon nếu discountValue <= subtotal
      if (coupon.discountValue > subtotal) {
        setState(() {
          _appliedCoupon = null;
          _couponDiscountAmount = 0;
          _errorCoupon = "Giá trị giảm giá lớn hơn giá trị đơn hàng. Không thể áp dụng!";
        });
      } else {
        setState(() {
          _appliedCoupon = coupon;
          _couponDiscountAmount = coupon.discountValue;
          _errorCoupon = null;
        });
      }
    } catch (e) {
      setState(() {
        _appliedCoupon = null;
        _couponDiscountAmount = 0;
        _errorCoupon = "Mã giảm giá không hợp lệ hoặc đã hết lượt sử dụng";
      });
    } finally {
      setState(() => _applyingCoupon = false);
    }
  }


  void _onLoyaltyChanged(String v) {
    final maxPoints = _currentUser?.loyaltyPoints ?? 0;
    final pts = int.tryParse(v) ?? 0;
    setState(() {
      _loyaltyPointsToUse = (pts > maxPoints) ? maxPoints : pts;
      _loyaltyController.text = _loyaltyPointsToUse.toString();
    });
  }

  double get _discount {
    // Loyalty points quy đổi 1 point = 1000đ (tùy hệ thống bạn)
    return (_couponDiscountAmount) + (_loyaltyPointsToUse * 1000);
  }

  double get _shipping => 30000; // phí ship mặc định
  double get _vat => 0;

  void _onCheckout(Cart cart) async {
    final List<Map<String, dynamic>> products = cart.items.map((item) {
      final product = _productsById[item.productId];
      final variant = product?.variants.firstWhere(
            (v) => v.id == item.productVariantId,
        orElse: () => product!.variants.first,
      );
      return {
        'product': product!,
        'quantity': item.quantity,
        'variant': variant,
      };
    }).toList();

    // Gọi sang màn hình thanh toán và truyền loyalty points đang dùng
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PaymentScreen(
              products: products,
              voucher: _appliedCoupon,
              loyaltyPointsToUse: _loyaltyPointsToUse, // <- TRUYỀN VÀO ĐÂY
              // Có thể truyền thêm address/user nếu cần
            ),
      ),
    );
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
                        final product = _productsById[item.productId];
                        final variants = product?.variants ?? [];

                        return CartItemWidget(
                          item: item,
                          product: product!,
                          // <-- FIX: thêm dòng này
                          isEditing: isEditing,
                          variants: variants,
                          onVariantChanged: (String? newVariantId) async {
                            if (newVariantId == null) return;
                            await _api.upsertCartItem(
                              cart.id,
                              CartItem(
                                productId: item.productId,
                                productVariantId: newVariantId,
                                quantity: item.quantity,
                              ),
                            );
                            await _refresh();
                          },
                          onDelete: () async {
                            final idToRemove = item.productVariantId ??
                                item.productId;
                            await _api.removeCartItem(cart.id, idToRemove);
                            await _refresh();
                          },
                          onQuantityChanged: (qty) async {
                            await _api.upsertCartItem(
                              cart.id,
                              CartItem(
                                productId: item.productId,
                                productVariantId: item.productVariantId,
                                quantity: qty,
                              ),
                            );
                            await _refresh();
                          },
                          isMobile: true, // hoặc false ở web
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
                    discountController: _discountController,
                    onApplyCoupon: _applyCoupon,
                    applyingCoupon: _applyingCoupon,
                    errorCoupon: _errorCoupon,
                    loyaltyPointsAvailable: _currentUser?.loyaltyPoints ?? 0,
                    loyaltyPointsToUse: _loyaltyPointsToUse,
                    loyaltyController: _loyaltyController,
                    onLoyaltyChanged: _onLoyaltyChanged,
                    onCheckout: () => _onCheckout(cart),
                    couponDiscountValue: _couponDiscountAmount,
                    couponApplied: _appliedCoupon != null,
                    onRemoveCoupon: () {
                      setState(() {
                        _appliedCoupon = null;
                        _couponDiscountAmount = 0;
                        _discountController.clear();
                      });
                    },
                  )

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: WebHeader(isLoggedIn: _currentUser != null),
      ),
      body: Column(
        children: [
          WebSearchBar(isLoggedIn: _currentUser != null),
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
                                final product = _productsById[item.productId];
                                final variants = product?.variants ?? [];
                                return CartItemWidget(
                                  item: item,
                                  product: product!,
                                  // <-- FIX: thêm dòng này
                                  isEditing: isEditing,
                                  variants: variants,
                                  onVariantChanged: (
                                      String? newVariantId) async {
                                    if (newVariantId == null) return;
                                    await _api.upsertCartItem(
                                      cart.id,
                                      CartItem(
                                        productId: item.productId,
                                        productVariantId: newVariantId,
                                        quantity: item.quantity,
                                      ),
                                    );
                                    await _refresh();
                                  },
                                  onDelete: () async {
                                    final idToRemove = item.productVariantId ??
                                        item.productId;
                                    await _api.removeCartItem(
                                        cart.id, idToRemove);
                                    await _refresh();
                                  },
                                  onQuantityChanged: (qty) async {
                                    await _api.upsertCartItem(
                                      cart.id,
                                      CartItem(
                                        productId: item.productId,
                                        productVariantId: item.productVariantId,
                                        quantity: qty,
                                      ),
                                    );
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
                              discountController: _discountController,
                              onApplyCoupon: _applyCoupon,
                              applyingCoupon: _applyingCoupon,
                              errorCoupon: _errorCoupon,
                              loyaltyPointsAvailable: _currentUser?.loyaltyPoints ?? 0,
                              loyaltyPointsToUse: _loyaltyPointsToUse,
                              loyaltyController: _loyaltyController,
                              onLoyaltyChanged: _onLoyaltyChanged,
                              onCheckout: () => _onCheckout(cart),
                              couponDiscountValue: _couponDiscountAmount,
                              couponApplied: _appliedCoupon != null,
                              onRemoveCoupon: () {
                                setState(() {
                                  _appliedCoupon = null;
                                  _couponDiscountAmount = 0;
                                  _discountController.clear();
                                });
                              },
                            )
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