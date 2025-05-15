import 'package:danentang/models/Order.dart';
import 'package:danentang/models/OrderItem.dart';
import 'package:danentang/models/OrderStatusHistory.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/ultis/image_helper.dart'; // Giả định hàm imageFromBase64String vẫn tồn tại

class OrderCard extends StatefulWidget {
  final Order order;
  final List<Product> products;

  const OrderCard({
    super.key,
    required this.order,
    required this.products,
  });

  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  void _cancelOrder() {
    if (widget.order.status == 'Đặt hàng' || widget.order.status == 'Đang chờ xử lý') {
      setState(() {
        widget.order.status = 'Đã hủy';
        widget.order.statusHistory.add(OrderStatusHistory(
          status: 'Đã hủy',
          timestamp: DateTime.now(),
        ));
        widget.order.updatedAt = DateTime.now();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đơn hàng đã được hủy!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể hủy đơn hàng ở trạng thái hiện tại!')),
      );
    }
  }

  void _confirmDelivery() {
    if (widget.order.status == 'Đang giao') {
      setState(() {
        widget.order.status = 'Đã giao';
        widget.order.statusHistory.add(OrderStatusHistory(
          status: 'Đã giao',
          timestamp: DateTime.now(),
        ));
        widget.order.updatedAt = DateTime.now();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đơn hàng đã được xác nhận giao!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chỉ có thể xác nhận giao khi đơn hàng đang giao!')),
      );
    }
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
            if (widget.order.items.isNotEmpty)
              ...widget.order.items.map((item) => _buildOrderItem(item, isShipped))
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('Không có sản phẩm trong đơn hàng', style: TextStyle(color: Colors.grey)),
              ),
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
    if (widget.products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(
                image: const AssetImage('assets/placeholder.png'),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.grey, width: 80, height: 80);
                },
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
          ],
        ),
      );
    }

    final Product? product = widget.products.firstWhere(
          (p) => p.variants.any((v) => v.id == item.productVariantId),
      orElse: () => Product(
        id: '',
        name: '',
        brand: '',
        description: '',
        price: 0,
        discountPercentage: 0,
        categoryId: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        images: [],
        variants: [],
      ),
    );

    final imageUrl = product?.images.isNotEmpty == true ? product!.images.first.url : 'assets/placeholder.png';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image(
              image: AssetImage(imageUrl),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey, width: 80, height: 80);
              },
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