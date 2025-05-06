// lib/widgets/Cart_CheckOut/cart_item_widget.dart

import 'package:flutter/material.dart';
import 'package:danentang/models/CartItem.dart';
import 'package:danentang/constants/colors.dart';
import 'package:danentang/Service/product_service.dart';

class CartItemWidget extends StatefulWidget {
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
  _CartItemWidgetState createState() => _CartItemWidgetState();
}

class _CartItemWidgetState extends State<CartItemWidget> {
  String productName = '';
  String variantName = '';
  double price = 0;
  String imageUrl = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    try {
      // 1. Lấy product chính
      final product = await ProductService().getProductById(widget.item.productId);
      // Giá mặc định là giá product
      double fetchedPrice = product.price;
      // Ảnh mặc định: lấy ảnh đầu trong list, hoặc placeholder
      String fetchedImage = product.images.isNotEmpty
          ? product.images.first.url
          : 'https://via.placeholder.com/150';
      String fetchedVariantName = '';

      // 2. Nếu có variant, lấy thêm và tính giá
      if (widget.item.productVariantId != null) {
        final variant = await ProductService().getVariantById(
          widget.item.productId,
          widget.item.productVariantId!,
        );
        fetchedPrice = product.price + variant.additionalPrice;
        fetchedVariantName = variant.variantName;
      }

      setState(() {
        productName = product.name;
        variantName = fetchedVariantName;
        price = fetchedPrice;
        imageUrl = fetchedImage;
        _loading = false;
      });
    } catch (e) {
      // btn lỗi fallback
      setState(() {
        productName = 'Unknown product';
        price = 0;
        imageUrl = 'https://via.placeholder.com/150';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: Colors.white,
        elevation: widget.isMobile ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(widget.isMobile ? 0 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh sản phẩm/variant
              Container(
                width: widget.isMobile ? 60 : 80,
                height: widget.isMobile ? 60 : 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên và nút delete
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            productName,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.isEditing)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: widget.onDelete,
                          ),
                      ],
                    ),

                    // Hiển thị variant nếu có
                    if (variantName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        variantName,
                        style: TextStyle(color: AppColors.hexToColor(AppColors.grey)),
                      ),
                    ],

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
                                if (widget.item.quantity > 1) {
                                  widget.onQuantityChanged(widget.item.quantity - 1);
                                }
                              },
                            ),
                            Text(
                              widget.item.quantity.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add_circle,
                                color: AppColors.hexToColor(AppColors.purple),
                              ),
                              onPressed: () {
                                widget.onQuantityChanged(widget.item.quantity + 1);
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
