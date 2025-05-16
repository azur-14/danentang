// lib/widgets/Product/add_to_cart_dialog.dart
import 'package:flutter/material.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/models/CartItem.dart';

class AddToCartDialog extends StatefulWidget {
  final Product product;
  final double discountedPrice; // bạn có thể hiển thị nếu cần

  const AddToCartDialog({
    super.key,
    required this.product,
    required this.discountedPrice,
  });

  @override
  State<AddToCartDialog> createState() => _AddToCartDialogState();
}

class _AddToCartDialogState extends State<AddToCartDialog> {
  late String _selectedVariantName;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Mặc định lấy variant đầu
    _selectedVariantName = widget.product.variants.isNotEmpty
        ? widget.product.variants.first.variantName
        : '';
  }

  int get _maxQuantity {
    if (widget.product.variants.isEmpty) return 100;
    final v = widget.product.variants.firstWhere(
          (v) => v.variantName == _selectedVariantName,
      orElse: () => widget.product.variants.first,
    );
    return v.inventory;
  }

  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  void _increment() {
    if (_quantity < _maxQuantity) setState(() => _quantity++);
  }

  void _onAddPressed() {
    // tìm variant object theo tên để lấy id
    final variant = widget.product.variants.firstWhere(
          (v) => v.variantName == _selectedVariantName,
      orElse: () => widget.product.variants.first,
    );

    // tạo CartItem mà không truyền price
    final item = CartItem(
      productId: widget.product.id,
      productVariantId: variant.id,
      quantity: _quantity,
    );

    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chọn biến thể & số lượng'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Biến thể
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Biến thể:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: widget.product.variants.map((v) {
              final selected = v.variantName == _selectedVariantName;
              return ChoiceChip(
                label: Text(v.variantName),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _selectedVariantName = v.variantName;
                    if (_quantity > _maxQuantity) _quantity = _maxQuantity;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
          // Số lượng
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Số lượng:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.remove), onPressed: _decrement),
              Text('$_quantity', style: const TextStyle(fontSize: 16)),
              IconButton(icon: const Icon(Icons.add), onPressed: _increment),
              const SizedBox(width: 16),
              Text('Tồn: $_maxQuantity', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // hủy → trả về null
          child: const Text('HỦY'),
        ),
        ElevatedButton(
          onPressed: _onAddPressed,
          child: const Text('THÊM VÀO GIỎ'),
        ),
      ],
    );
  }
}
