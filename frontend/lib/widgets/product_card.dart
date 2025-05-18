import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'dart:typed_data';

import '../models/product.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false;

  // Hàm định dạng số với dấu chấm sau mỗi 3 số
  String formatPrice(double price) {
    String priceStr = price.toInt().toString(); // Convert to int to avoid decimals
    String result = '';
    int count = 0;

    // Đọc từ phải sang trái, thêm dấu chấm sau mỗi 3 số
    for (int i = priceStr.length - 1; i >= 0; i--) {
      count++;
      result = priceStr[i] + result;
      if (count % 3 == 0 && i != 0) {
        result = '.' + result;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 180;
    const double cardHeight = 280;

    // 1. Tìm biến thể có giá thấp nhất
    final cheapestVariant = widget.product.variants.isNotEmpty
        ? widget.product.variants.reduce(
            (a, b) => a.additionalPrice < b.additionalPrice ? a : b)
        : null;
    final basePrice = cheapestVariant?.additionalPrice ?? 0.0;

    // 2. Tính giá sau khi giảm, đảm bảo làm tròn để tránh thập phân không mong muốn
    final discountedPrice = (basePrice * (1 - widget.product.discountPercentage / 100)).roundToDouble();

    // 3. Định dạng giá với dấu chấm sau mỗi 3 số
    final formattedBasePrice = formatPrice(basePrice);
    final formattedDiscountedPrice = formatPrice(discountedPrice);

    // Decode base64 image if available, fallback to placeholder
    Uint8List? imageBytes;
    try {
      if (widget.product.images.isNotEmpty && widget.product.images[0].url.isNotEmpty) {
        imageBytes = base64Decode(widget.product.images[0].url);
        if (imageBytes != null) {
          print('Image bytes type: ${imageBytes.runtimeType}');
        }
      }
    } catch (e) {
      print('Error decoding base64 image: $e');
    }

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.go('/product/${widget.product.id}');
        },
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh & badge discount
              Stack(
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageBytes != null
                            ? MemoryImage(imageBytes as Uint8List)
                            : const NetworkImage('https://via.placeholder.com/150'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                  ),
                  if (widget.product.discountPercentage > 0)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '-${widget.product.discountPercentage}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      },

                    ),
                  ),
                ],
              ),

              // Tên & giá
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tên sản phẩm
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Giá
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₫$formattedDiscountedPrice',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.product.discountPercentage > 0)
                            Text(
                              '₫$formattedBasePrice',
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
    );
  }
}