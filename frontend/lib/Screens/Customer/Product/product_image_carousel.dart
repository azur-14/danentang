// lib/widgets/Product/product_image_carousel.dart
import 'package:flutter/material.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/ultis/image_helper.dart'; // Import imageFromBase64String

class ProductImageCarousel extends StatelessWidget {
  final Product product;

  const ProductImageCarousel({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sắp xếp ảnh theo sortOrder
    final sortedImages = product.images..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (sortedImages.isEmpty) {
      return const Center(child: Text('Không có ảnh sản phẩm'));
    }

    return Container(
      height: 400,
      child: PageView.builder(
        itemCount: sortedImages.length,
        itemBuilder: (context, index) {
          final image = sortedImages[index];
          // Debug log to check url
          print('Image $index - url: ${image.url}');

          // Sử dụng url trực tiếp (giả định là base64)
          return imageFromBase64String(
            image.url,
            width: double.infinity,
            height: 400,
            fit: BoxFit.cover,
            placeholder: const AssetImage('assets/images/default_product.jpg'),
          );
        },
      ),
    );
  }
}