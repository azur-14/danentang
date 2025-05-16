import 'package:flutter/material.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/Screens/Customer/Payment/payment_screen.dart';
import 'package:danentang/data/user_data.dart';

class BuyNowDialog extends StatefulWidget {
  final Product product;
  final double discountedPrice;
  const BuyNowDialog({super.key, required this.product, required this.discountedPrice});

  @override
  _BuyNowDialogState createState() => _BuyNowDialogState();
}

class _BuyNowDialogState extends State<BuyNowDialog> {
  String selectedColor = '';
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.product.variants.isNotEmpty ? widget.product.variants[0].variantName : 'Default';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      if (screenWidth <= 800) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true, // Cho phép cuộn toàn màn hình
          backgroundColor: Colors.transparent,
          builder: (context) => _buildDialogContent(isMobile: true),
        ).then((_) => Navigator.pop(context));
      }
    });
  }

  Widget _buildDialogContent({required bool isMobile}) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        String localSelectedColor = selectedColor;
        int localQuantity = quantity;
        int maxQuantity = _getMaxQuantity(localSelectedColor);

        return Container(
          width: double.infinity,
          height: isMobile ? MediaQuery.of(context).size.height * 0.9 : null, // Tăng chiều cao để tránh overflow
          decoration: isMobile
              ? const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          )
              : null,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // Đảm bảo luôn cuộn được
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Chỉ chiếm không gian cần thiết
                children: [
                  if (isMobile)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.image, size: 50)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '₫${widget.discountedPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  Text(
                    'Mã sản phẩm: ${widget.product.id}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tên sản phẩm',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.product.name, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                  const Text(
                    'Biến thể',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.product.variants.map((variant) {
                        bool isSelected = localSelectedColor == variant.variantName;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              localSelectedColor = variant.variantName;
                              maxQuantity = _getMaxQuantity(localSelectedColor);
                              if (localQuantity > maxQuantity) {
                                localQuantity = maxQuantity;
                              }
                              selectedColor = localSelectedColor;
                              quantity = localQuantity;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.purple[100] : Colors.grey[300],
                              border: Border.all(
                                color: isSelected ? Colors.purple[700]! : Colors.grey,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              variant.variantName,
                              style: TextStyle(
                                color: isSelected ? Colors.purple[700] : Colors.black,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Số lượng',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: localQuantity > 1
                                  ? () {
                                setState(() {
                                  localQuantity--;
                                  quantity = localQuantity;
                                });
                              }
                                  : null,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              constraints: const BoxConstraints(),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                '$localQuantity',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: localQuantity < maxQuantity
                                  ? () {
                                setState(() {
                                  localQuantity++;
                                  quantity = localQuantity;
                                });
                              }
                                  : null,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Tồn kho: $maxQuantity',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                              products: [
                                {
                                  'product': widget.product,
                                  'color': localSelectedColor,
                                  'quantity': localQuantity,
                                },
                              ],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[700],
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text(
                        'Mua ngay',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    )
                  ),
                  const SizedBox(height: 16), // Thêm khoảng trống cuối để tránh nội dung bị che
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  int _getMaxQuantity(String color) {
    if (widget.product.variants.isEmpty) {
      return 100;
    }
    return widget.product.variants
        .firstWhere((variant) => variant.variantName == color, orElse: () => widget.product.variants[0])
        .inventory ??
        100;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return isDesktop
        ? AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: EdgeInsets.zero, // Loại bỏ padding mặc định của AlertDialog
      content: SingleChildScrollView(
        child: _buildDialogContent(isMobile: false),
      ),
    )
        : const SizedBox();
  }
}