// lib/widgets/Cart_CheckOut/cart_item_widget.dart

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
    Key? key,
    required this.item,
    required this.isEditing,
    required this.onDelete,
    required this.onQuantityChanged,
    required this.isMobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Giá đơn giản, không tính discount
    final price = item.price;

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
              // Ảnh placeholder
              Container(
                width: isMobile ? 60 : 80,
                height: isMobile ? 60 : 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://via.placeholder.com/150',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên sản phẩm + nút delete
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.productName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isEditing)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: onDelete,
                          ),
                      ],
                    ),

                    // Biến thể
                    const SizedBox(height: 4),
                    Text(
                      item.variantName,
                      style: TextStyle(color: AppColors.hexToColor(AppColors.grey)),
                    ),

                    // Giá và số lượng
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Giá
                        Text(
                          "₫${price.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),

                        // Controls thay đổi số lượng
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
