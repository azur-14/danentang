import 'package:flutter/material.dart';
import 'package:danentang/models/CartItem.dart';
import 'package:danentang/models/product.dart'; // Thêm để dùng ProductVariant
import 'package:danentang/constants/colors.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final bool isEditing;
  final VoidCallback onDelete;
  final Function(int) onQuantityChanged;
  final bool isMobile;

  // Thêm 2 prop mới:
  final List<ProductVariant> variants;
  final Function(String?)? onVariantChanged;

  const CartItemWidget({
    Key? key,
    required this.item,
    required this.isEditing,
    required this.onDelete,
    required this.onQuantityChanged,
    required this.isMobile,
    required this.variants,
    this.onVariantChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy variant hiện tại
    final currentVariant = variants.firstWhere(
          (v) => v.id == item.productVariantId,
      orElse: () => variants.isNotEmpty ? variants.first : ProductVariant(
        id: '', variantName: 'Không có', additionalPrice: 0, inventory: 0,
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
    );
    final imageUrl = ''; // Lấy ảnh theo product nếu cần

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
              // (Bổ sung lấy imageUrl nếu muốn)
              Container(
                width: isMobile ? 60 : 80,
                height: isMobile ? 60 : 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.image),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên & delete
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            currentVariant.variantName, // Chỉnh theo tên sản phẩm hoặc variant
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
                    // Nếu có nhiều variant thì dropdown chọn
                    if (variants.length > 1)
                      DropdownButton<String>(
                        value: item.productVariantId,
                        items: variants.map((v) => DropdownMenuItem(
                          value: v.id,
                          child: Text('${v.variantName} (+₫${v.additionalPrice.toStringAsFixed(0)})'),
                        )).toList(),
                        onChanged: onVariantChanged,
                        isExpanded: true,
                        underline: Container(height: 1, color: Colors.grey.shade300),
                      )
                    else
                      Text(
                        currentVariant.variantName,
                        style: TextStyle(color: AppColors.hexToColor(AppColors.grey)),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Giá
                        Text(
                          "₫${currentVariant.additionalPrice.toStringAsFixed(0)}",
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

