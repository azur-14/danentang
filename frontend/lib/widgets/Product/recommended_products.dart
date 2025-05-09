import 'package:flutter/material.dart';
import 'package:danentang/models/product.dart';

class RecommendedProducts extends StatelessWidget {
  final List<Product> recommendedProducts;
  const RecommendedProducts({super.key, required this.recommendedProducts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sản phẩm đề xuất",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 150,
            child: recommendedProducts.isEmpty
                ? const Center(child: Text("Không có sản phẩm đề xuất."))
                : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recommendedProducts.length,
              itemBuilder: (context, index) {
                final recommendedProduct = recommendedProducts[index];
                final recommendedDiscountedPrice =
                    recommendedProduct.price * (1 - recommendedProduct.discountPercentage / 100);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Card(
                    child: Container(
                      width: 120,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          recommendedProduct.images.isNotEmpty
                              ? Image.network(
                            recommendedProduct.images[0].url,
                            height: 80,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 80,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            ),
                          )
                              : Container(
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recommendedProduct.name,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "₫${recommendedDiscountedPrice.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
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