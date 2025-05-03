import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../models/ProductRating.dart';
import '../models/Review.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final ProductRating? productRating;
  final List<Review>? reviews;
  final List<Product>? recommendedProducts;

  const ProductCard({
    Key? key,
    required this.product,
    this.productRating,
    this.reviews,
    this.recommendedProducts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 180;
    const double cardHeight = 250;

    final discountedPrice = product.price * (1 - product.discountPercentage / 100);

    return GestureDetector(
      onTap: () {
        // Debug: Log the product ID
        print('Navigating to Product ID: ${product.id}');

        // Navigate to ProductDetailsScreen
        GoRouter.of(context).go(
          '/product/${product.id}',
          extra: {
            'product': product,
            'productRating': productRating,
            'reviews': reviews,
            'recommendedProducts': recommendedProducts,
          },
        );
      },
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                        image: DecorationImage(
                          image: NetworkImage(
                            product.images.isNotEmpty
                                ? product.images[0].url
                                : 'https://via.placeholder.com/150',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (product.discountPercentage > 0)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '-${product.discountPercentage}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(Icons.favorite_border, color: Colors.grey),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₫${discountedPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (product.discountPercentage > 0)
                              Text(
                                '₫${product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}