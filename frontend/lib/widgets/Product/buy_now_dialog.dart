import 'package:flutter/material.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/Screens/Customer/Payment/payment_screen.dart';

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
          isScrollControlled: true,
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

        final content = SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Text('Mã sản phẩm: ${widget.product.id}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 16),
                const Text('Tên sản phẩm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(widget.product.name, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 16),
                const Text('Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: widget.product.variants.map((variant) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          localSelectedColor = variant.variantName;
                          maxQuantity = _getMaxQuantity(localSelectedColor);
                          if (localQuantity > maxQuantity) localQuantity = maxQuantity;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(variant.variantName),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Số lượng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: localQuantity > 1 ? () => setState(() => localQuantity--) : null,
                    ),
                    Text('$localQuantity'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: localQuantity < maxQuantity ? () => setState(() => localQuantity++) : null,
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
                                'quantity': localQuantity
                              },
                            ],
                            total: widget.discountedPrice * localQuantity,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Mua ngay', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );

        return isMobile
            ? Container(
          height: MediaQuery.of(context).size.height * 0.75,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: content,
        )
            : content;
      },
    );
  }

  int _getMaxQuantity(String color) {
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
      content: _buildDialogContent(isMobile: false),
    )
        : const SizedBox();
  }
}