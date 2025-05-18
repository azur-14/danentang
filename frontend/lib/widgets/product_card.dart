import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert'; // Import for base64Decode
import 'dart:typed_data'; // Explicitly import typed_data to resolve Uint8List
import 'package:intl/intl.dart'; // For number formatting

import '../models/product.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isFavorite = false; // Track favorite state

  @override
  Widget build(BuildContext context) {
    const double cardWidth = 180;
    const double cardHeight = 280; // Increased height for better spacing

    // 1. Tìm biến thể có giá thấp nhất
    final cheapestVariant = widget.product.variants.isNotEmpty
        ? widget.product.variants.reduce(
            (a, b) => a.additionalPrice < b.additionalPrice ? a : b)
        : null;
    final basePrice = cheapestVariant?.additionalPrice ?? 0.0;

    // 2. Tính giá sau khi giảm
    final discountedPrice = basePrice * (1 - widget.product.discountPercentage / 100);

    // 3. Định dạng giá với dấu phẩy và ký hiệu tiền tệ
    final numberFormat = NumberFormat.decimalPattern('vi_VN'); // Dùng định dạng tiếng Việt
    final formattedBasePrice = numberFormat.format(basePrice);
    final formattedDiscountedPrice = numberFormat.format(discountedPrice);

    // Decode base64 image if available, fallback to placeholder
    Uint8List? imageBytes;
    try {
      if (widget.product.images.isNotEmpty && widget.product.images[0].url.isNotEmpty) {
        imageBytes = base64Decode(widget.product.images[0].url); // Decode base64 string
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
          // Chuyển sang detail page
          context.go('/product/${widget.product.id}');
        },
        child: Card(
          elevation: 4, // Increased elevation for a modern shadow effect
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh & badge discount
              Stack(
                children: [
                  Container(
                    height: 160, // Slightly increased height for better image display
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageBytes != null
                            ? MemoryImage(imageBytes as Uint8List) // Explicit cast to resolve type
                            : const NetworkImage('https://via.placeholder.com/150'), // Fallback to placeholder
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
                          border: Border.all(color: Colors.white, width: 1), // Added white border
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
                          isFavorite = !isFavorite; // Toggle favorite state
                        });
                      },
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),

              // Tên & giá
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10), // Consistent padding
                  decoration: BoxDecoration(
                    color: Colors.grey[50], // Subtle background color for price section
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
                          fontSize: 15, // Slightly larger for readability
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
                            '$formattedDiscountedPriceđ',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (widget.product.discountPercentage > 0)
                            Text(
                              '$formattedBasePriceđ',
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