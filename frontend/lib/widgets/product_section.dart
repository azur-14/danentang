import 'package:flutter/material.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/widgets/product_card.dart';

class ProductSection extends StatelessWidget {
  final String title;
  final List<Product> products;
  final bool isWeb;
  final double screenWidth;

  const ProductSection({
    Key? key,
    required this.title,
    required this.products,
    required this.isWeb,
    required this.screenWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tính số lượng thẻ trên mỗi hàng dựa trên kích thước màn hình
    final double cardWidth = 180; // Chiều rộng của ProductCard
    final double padding = isWeb ? 32 : 16; // Padding hai bên
    final int itemsPerRow = ((screenWidth - 2 * padding) / (cardWidth + 8)).floor();
    final int crossAxisCount = itemsPerRow > 0 ? itemsPerRow : 1; // Đảm bảo ít nhất 1 thẻ

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isWeb ? 32 : 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: isWeb ? 32 : 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount, // Số lượng thẻ trên mỗi hàng
              crossAxisSpacing: 16, // Khoảng cách ngang giữa các thẻ
              mainAxisSpacing: 16, // Khoảng cách dọc giữa các thẻ
              childAspectRatio: 180 / 250, // Tỷ lệ khung hình của ProductCard
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
          ),
        ),
      ],
    );
  }
}