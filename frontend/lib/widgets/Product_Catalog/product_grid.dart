import 'package:flutter/material.dart';

import '../../../models/product.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final bool isLoading;
  final ScrollController scrollController;

  const ProductGrid({
    super.key,
    required this.products,
    required this.isLoading,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Product List', style: TextStyle(fontSize: 18)),
              Row(
                children: [
                  const Text('Sort by:'),
                  DropdownButton<String>(
                    value: 'All Products',
                    items: const [
                      DropdownMenuItem(value: 'All Products', child: Text('All Products')),
                      DropdownMenuItem(value: 'Price: Low to High', child: Text('Price: Low to High')),
                      DropdownMenuItem(value: 'Price: High to Low', child: Text('Price: High to Low')),
                    ],
                    onChanged: (_) {},
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: products.isEmpty && !isLoading
              ? const Center(child: Text('No products to display'))
              : GridView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 4,
              childAspectRatio: isMobile ? 0.65 : 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length + (isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= products.length) {
                return const Center(child: CircularProgressIndicator());
              }
              return ProductCard(
                product: products[index],
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }
}