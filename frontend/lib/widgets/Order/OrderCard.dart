import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/Order.dart';
import '../../models/OrderItem.dart';
import '../../models/OrderStatusHistory.dart';
import '../../models/product.dart';
import 'package:danentang/ultis/image_helper.dart'; // Đảm bảo bạn đã có hàm imageFromBase64String()

// Dữ liệu giả tạm (thay bằng fetch từ API khi cần)
final List<Product> products = [
  Product(
    id: 'p1',
    name: 'Laptop ABC',
    brand: 'ASUS',
    description: 'Mạnh mẽ và gọn nhẹ',
    discountPercentage: 10,
    categoryId: 'c1',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    images: [
      ProductImage(
        id: 'img1',
        url: '<base64-string-hoặc-để-trống>',
        sortOrder: 1,
      ),
    ],
    variants: [
      ProductVariant(
        id: 'v1',
        variantName: '16GB RAM',
        additionalPrice: 0,
        inventory: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ],
  ),
];

class OrderCard extends StatefulWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  void _cancelOrder() {
    setState(() {
      widget.order.status = 'Đã hủy';
      widget.order.statusHistory.add(OrderStatusHistory(
        status: 'Đã hủy',
        timestamp: DateTime.now(),
      ));
      widget.order.updatedAt = DateTime.now();
    });
  }

  void _confirmDelivery() {
    setState(() {
      widget.order.status = 'Đã giao';
      widget.order.statusHistory.add(OrderStatusHistory(
        status: 'Đã giao',
        timestamp: DateTime.now(),
      ));
      widget.order.updatedAt = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPending = widget.order.status == 'Đang chờ xử lý' || widget.order.status == 'Đặt hàng';
    final isShipped = widget.order.status == 'Đang giao';
    final isDelivered = widget.order.status == 'Đã giao';
    final isCanceled = widget.order.status == 'Đã hủy';

    Color statusColor = Colors.grey;
    if (isCanceled) {
      statusColor = Colors.red;
    } else if (isDelivered) {
      statusColor = Colors.green;
    } else if (isShipped) {
      statusColor = Colors.blue[700]!;
    } else if (isPending) {
      statusColor = Colors.orange;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn hàng #${widget.order.orderNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  widget.order.status,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Sản phẩm:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 8),
            ...widget.order.items.map((item) => _buildOrderItem(item, isShipped)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                ),
                Text(
                  '₫${NumberFormat('#,##0', 'vi_VN').format(widget.order.totalAmount)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ngày đặt:', style: TextStyle(fontSize: 14, color: Color(0xFF333333))),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(widget.order.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isPending)
                  ElevatedButton(
                    onPressed: _cancelOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Hủy đơn', style: TextStyle(color: Colors.white)),
                  ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    context.push('/order-details/${widget.order.id}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Xem chi tiết', style: TextStyle(color: Colors.white)),
                ),
                if (isDelivered) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => context.push('/review/${widget.order.id}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Đánh giá', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => context.push('/reorder/${widget.order.id}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Mua lại', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => context.push('/return/${widget.order.id}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Trả hàng', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item, bool isShipped) {
    final Product product = products.firstWhere(
          (p) => p.variants.any((v) => v.id == item.productVariantId),
      orElse: () => Product(
        id: '',
        name: '',
        brand: '',
        description: '',
        discountPercentage: 0,
        categoryId: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        images: [],
        variants: [],
      ),
    );

    final base64 = product.images.isNotEmpty ? product.images.first.url : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageFromBase64String(
              base64,
              width: 80,
              height: 80,
              placeholder: const AssetImage('assets/placeholder.png'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Biến thể: ${item.variantName} | Số lượng: ${item.quantity}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '₫${NumberFormat('#,##0', 'vi_VN').format(item.price * item.quantity)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
          if (isShipped)
            ElevatedButton(
              onPressed: _confirmDelivery,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Xác nhận', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
        ],
      ),
    );
  }
}
