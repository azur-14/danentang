import 'package:flutter/material.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/widgets/Product_Catalog/product_card.dart';

import '../../models/Review.dart';
class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final bool isLoading;
  final ScrollController scrollController;
  final Map<String, List<Review>> productReviews;

  const ProductGrid({
    super.key,
    required this.products,
    required this.isLoading,
    required this.scrollController,
    required this.productReviews,
  });

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 14);
        } else if (index < rating) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 14);
        } else {
          return const Icon(Icons.star_border, color: Colors.amber, size: 14);
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final imageUrl = product.images.isNotEmpty ? product.images[0].url : '';
        final reviews = productReviews[product.id] ?? [];
        final valid = reviews.where((r) => r.rating != null).toList();
        final avgRating = valid.isNotEmpty
            ? valid.map((r) => r.rating!).reduce((a, b) => a + b) / valid.length
            : 0.0;
        final latestComment = valid.isNotEmpty ? valid.first.comment : '';

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  child: imageUrl.startsWith('http')
                      ? Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity)
                      : const Icon(Icons.image, size: 100),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      product.minPrice == product.maxPrice
                          ? '${product.minPrice.toStringAsFixed(0)}đ'
                          : '${product.minPrice.toStringAsFixed(0)} - ${product.maxPrice.toStringAsFixed(0)}đ',
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildRatingStars(avgRating),
                        const SizedBox(width: 4),
                        Text('(${valid.length})', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    if (latestComment.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('"$latestComment"',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 12, color: Colors.grey)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
