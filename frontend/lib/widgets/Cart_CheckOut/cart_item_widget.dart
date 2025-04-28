import 'package:flutter/material.dart';
import 'package:danentang/models/CartItem.dart';
import 'package:danentang/constants/colors.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final bool isEditing;
  final VoidCallback onDelete;
  final Function(int) onQuantityChanged;
  final bool isMobile;

  const CartItemWidget({
    required this.item,
    required this.isEditing,
    required this.onDelete,
    required this.onQuantityChanged,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final discountedPrice = item.product.price * (1 - item.product.discountPercentage / 100);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: Colors.white,
        elevation: isMobile ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 0 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: isMobile ? 60 : 80,
                height: isMobile ? 60 : 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(item.product.images.isNotEmpty
                        ? item.product.images[0].url
                        : 'https://via.placeholder.com/150'), // Fallback nếu không có ảnh
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.product.name,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.size,
                                style: TextStyle(color: AppColors.hexToColor(AppColors.grey)),
                              ),
                            ],
                          ),
                        ),
                        if (isEditing)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: onDelete,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "₫${discountedPrice.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            if (item.product.discountPercentage > 0)
                              Text(
                                "₫${item.product.price.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle,
                                color: AppColors.hexToColor(AppColors.purple),
                              ),
                              onPressed: () {
                                if (item.quantity > 1) {
                                  onQuantityChanged(item.quantity - 1);
                                }
                              },
                            ),
                            Text(
                              item.quantity.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add_circle,
                                color: AppColors.hexToColor(AppColors.purple),
                              ),
                              onPressed: () {
                                onQuantityChanged(item.quantity + 1);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
