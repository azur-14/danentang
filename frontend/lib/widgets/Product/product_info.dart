import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';

import 'package:danentang/models/product.dart';
import 'package:danentang/models/ProductRating.dart';
import 'package:danentang/models/CartItem.dart';
import 'package:danentang/Service/order_service.dart';

import 'package:danentang/widgets/Product/buy_now_dialog.dart';
import 'package:danentang/widgets/Product/AddToCartDialog.dart';

class ProductInfo extends StatefulWidget {
  final Product product;
  final ProductRating productRating;

  const ProductInfo({
    super.key,
    required this.product,
    required this.productRating,
  });

  @override
  _ProductInfoState createState() => _ProductInfoState();
}

class _ProductInfoState extends State<ProductInfo> {
  late final double _discountedBasePrice;

  @override
  void initState() {
    super.initState();
    // Tính giá base và giá đã giảm
    final cheapest = widget.product.variants.isNotEmpty
        ? widget.product.variants.reduce((a, b) =>
    a.additionalPrice < b.additionalPrice ? a : b)
        : null;
    final base = cheapest?.additionalPrice ?? 0.0;
    _discountedBasePrice =
        base * (1 - widget.product.discountPercentage / 100);
  }

  Future<void> _onAddToCart() async {
    // Mở dialog chọn variant & quantity, dialog trả về CartItem
    final CartItem? item = await showDialog<CartItem>(
      context: context,
      builder: (_) => AddToCartDialog(
        product: widget.product,
        discountedPrice: _discountedBasePrice,
      ),
    );
    if (item == null) return; // user hủy

    try {
      // Gọi service để thêm vào giỏ
      await OrderService.instance.addToCart(item);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã thêm ${item.quantity} x ${widget.product.name} vào giỏ',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi thêm giỏ: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tên sản phẩm
        Text(
          widget.product.name,
          style: TextStyle(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Rating
        Row(
          children: [
            RatingBarIndicator(
              rating: widget.productRating.averageRating,
              itemBuilder: (_, __) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              itemCount: 5,
              itemSize: 20,
            ),
            const SizedBox(width: 8),
            Text("(${widget.productRating.reviewCount} đánh giá)"),
          ],
        ),
        const SizedBox(height: 8),

        // Giá
        Row(
          children: [
            Text(
              "₫${_discountedBasePrice.toStringAsFixed(0)}",
              style: TextStyle(
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            if (widget.product.discountPercentage > 0)
              Text(
                "₫${(_discountedBasePrice / (1 - widget.product.discountPercentage / 100)).toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 8),

        // Biến thể
        const Text(
          "Biến thể:",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        ...widget.product.variants.map((variant) {
          final variantPrice = variant.additionalPrice *
              (1 - widget.product.discountPercentage / 100);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text("${variant.variantName}: "),
                Text(
                  "₫${variantPrice.toStringAsFixed(0)} (Kho: ${variant.inventory})",
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          );
        }).toList(),

        // Nút hành động
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => BuyNowDialog(
                      product: widget.product,
                      discountedPrice: _discountedBasePrice,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 16 : 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Mua ngay",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Add to Cart
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.shopping_bag_outlined, size: 24, color: Colors.grey[600]),
                onPressed: _onAddToCart,
              ),
            ),
            const SizedBox(width: 8),
            // Chat
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.chat_bubble_outline, size: 24, color: Colors.grey[600]),
                onPressed: () => GoRouter.of(context).go('/chat'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
