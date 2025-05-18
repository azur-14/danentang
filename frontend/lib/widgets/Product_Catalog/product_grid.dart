import 'package:flutter/material.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/widgets/Product_Catalog/product_card.dart';

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
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                if (index >= products.length) return null;
                return ProductCard(product: products[index], index: index);
              },
              childCount: products.length,
            ),
          ),
        ),
        if (isLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}