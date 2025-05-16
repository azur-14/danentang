import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/models/ProductRating.dart';
import 'package:danentang/widgets/Product/buy_now_dialog.dart';
import 'package:danentang/widgets/Product/AddToCartDialog.dart'; // Import AddToCartDialog

class ProductInfo extends StatelessWidget {
  final Product product;
  final ProductRating productRating;
  const ProductInfo({super.key, required this.product, required this.productRating});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    // 1. Tìm variant có giá thấp nhất
    final cheapestVariant = product.variants.isNotEmpty
        ? product.variants.reduce((a, b) =>
    a.additionalPrice < b.additionalPrice ? a : b)
        : null;
    final basePrice = cheapestVariant?.additionalPrice ?? 0.0;

    // 2. Áp discount trên giá mặc định
    final discountedBasePrice =
        basePrice * (1 - product.discountPercentage / 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product name
        Text(
          product.name,
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
              rating: productRating.averageRating,
              itemBuilder: (context, index) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              itemCount: 5,
              itemSize: 20,
            ),
            const SizedBox(width: 8),
            Text(
              "(${productRating.reviewCount} đánh giá)",
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Price row
        Row(
          children: [
            Text(
              "₫${discountedBasePrice.toStringAsFixed(0)}",
              style: TextStyle(
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            if (product.discountPercentage > 0)
              Text(
                "₫${basePrice.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: isDesktop ? 18 : 16,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            const Spacer(),
            const Text(
              "Đã bán: 200K",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Variants list
        const Text(
          "Biến thể:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        ...product.variants.map((variant) {
          final variantPrice =
              variant.additionalPrice * (1 - product.discountPercentage / 100);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(
                  "${variant.variantName}: ",
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  "₫${variantPrice.toStringAsFixed(0)} (Kho: ${variant.inventory})",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 16),

        // Description
        const Text(
          "Mô tả:",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          product.description ?? "Không có mô tả.",
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => BuyNowDialog(
                      product: product,
                      discountedPrice: discountedBasePrice,
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
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.grey[600],
                  size: 24,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AddToCartDialog(
                      product: product,
                      discountedPrice: discountedBasePrice,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.grey[600],
                  size: 24,
                ),
                onPressed: () {
                  GoRouter.of(context).go('/chat');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}