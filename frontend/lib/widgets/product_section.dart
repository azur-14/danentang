import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product.dart';
import '../../../Screens/Customer/Home/product_list_screen.dart';
import 'product_card.dart';

class ProductSection extends StatelessWidget {
  final String title;
  final List<Product> products;
  final bool isWeb;
  final double screenWidth;

  const ProductSection({
    required this.title,
    required this.products,
    required this.isWeb,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    const int crossAxisCount = 5; // For web
    const int mobileCrossAxisCount = 2; // For mobile
    const double productSpacing = 10;
    const double productHorizontalPadding = 16;

    int itemsPerRow = isWeb ? crossAxisCount : mobileCrossAxisCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  context.go(
                    '/products/$title',
                    extra: {
                      'products': products,
                      'isWeb': isWeb,
                    },
                  );
                },
                child: Text("See all", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
        GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16),
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: itemsPerRow,
            mainAxisSpacing: 10,
            crossAxisSpacing: productSpacing,
            childAspectRatio: 0.75,
          ),
          itemCount: products.length > itemsPerRow ? itemsPerRow : products.length,
          itemBuilder: (context, index) {
            return ProductCard(product: products[index]);
          },
        ),
      ],
    );
  }
}
