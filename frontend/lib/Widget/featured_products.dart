import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_card.dart';

class FeaturedProducts extends StatelessWidget {
  const FeaturedProducts({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, this would come from an API or database
    final List<Product> featuredProducts = [
      Product(name: 'Redmi Note 4', price: 45000, originalPrice: 55000, image: 'assets/placeholder.png'),
      Product(name: 'Redmi Note 4', price: 45000, originalPrice: 55000, image: 'assets/placeholder.png'),
      Product(name: 'Redmi Note 4', price: 45000, originalPrice: 55000, image: 'assets/placeholder.png'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured products',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'See all',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: featuredProducts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return ProductCard(product: featuredProducts[index]);
            },
          ),
        ),
      ],
    );
  }
}