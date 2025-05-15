import 'package:flutter/material.dart';
import 'package:danentang/data/order_data.dart';
import 'package:danentang/models/Order.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/OrderStatusHistory.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  void _confirmDelivery() {
    final order = testOrders.firstWhere((o) => o.id == widget.orderId);
    setState(() {
      order.status = 'Đã giao';
      order.statusHistory.add(OrderStatusHistory(
        status: 'Đã giao',
        timestamp: DateTime.now(),
      ));
      order.updatedAt = DateTime.now();
    });
    // Navigate to review page
    context.push('/review/${widget.orderId}');
  }

  @override
  Widget build(BuildContext context) {
    final order = testOrders.firstWhere(
          (o) => o.id == widget.orderId,
      orElse: () => throw Exception('Order not found'),
    );
    final expectedDeliveryDate = order.createdAt.add(const Duration(days: 5));

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết đơn hàng #${order.orderNumber}'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Information
              const Text(
                'Thông tin đơn hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mã đơn hàng:',
                            style: TextStyle(color: Color(0xFF718096)),
                          ),
                          Text(
                            order.orderNumber,
                            style: const TextStyle(color: Color(0xFF2D3748)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ngày đặt hàng:',
                            style: TextStyle(color: Color(0xFF718096)),
                          ),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt),
                            style: const TextStyle(color: Color(0xFF2D3748)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tổng tiền:',
                            style: TextStyle(color: Color(0xFF718096)),
                          ),
                          Text(
                            '₫${NumberFormat('#,##0', 'vi_VN').format(order.totalAmount)}',
                            style: const TextStyle(
                              color: Color(0xFF2D3748),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mã giảm giá:',
                            style: TextStyle(color: Color(0xFF718096)),
                          ),
                          Text(
                            order.couponCode ?? 'Không có',
                            style: const TextStyle(color: Color(0xFF2D3748)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Điểm tích lũy sử dụng:',
                            style: TextStyle(color: Color(0xFF718096)),
                          ),
                          Text(
                            '${order.loyaltyPointsUsed} điểm',
                            style: const TextStyle(color: Color(0xFF2D3748)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Shipping Address
              const Text(
                'Địa chỉ giao hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.shippingAddress.street,
                        style: const TextStyle(color: Color(0xFF2D3748)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order.shippingAddress.city}, ${order.shippingAddress.state}',
                        style: const TextStyle(color: Color(0xFF2D3748)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mã bưu điện: ${order.shippingAddress.postalCode}',
                        style: const TextStyle(color: Color(0xFF2D3748)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quốc gia: ${order.shippingAddress.country}',
                        style: const TextStyle(color: Color(0xFF2D3748)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Product List
              const Text(
                'Sản phẩm:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        item.imageUrl != null ? item.imageUrl! : 'assets/placeholder.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Biến thể: ${item.variantName} | Số lượng: ${item.quantity}',
                            style: const TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 12,
                            ),
                          ),
                          if (item.productVariantId != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Mã biến thể: ${item.productVariantId}',
                              style: const TextStyle(
                                color: Color(0xFF718096),
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            '₫${NumberFormat('#,##0', 'vi_VN').format(item.price * item.quantity)}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 24),
              // Order Summary
              const Text(
                'Chi tiết đơn hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ngày giao hàng dự kiến',
                            style: TextStyle(color: Color(0xFF718096)),
                          ),
                          Text(
                            DateFormat('dd MMM yyyy').format(expectedDeliveryDate),
                            style: const TextStyle(color: Color(0xFF2D3748)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mã theo dõi',
                            style: TextStyle(color: Color(0xFF718096)),
                          ),
                          Text(
                            'TRK${order.id}52126542',
                            style: const TextStyle(color: Color(0xFF2D3748)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Order Status Timeline
              const Text(
                'Tình trạng đơn hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 16),
              _buildOrderStatusTimeline(order),
            ],
          ),
        ),
      ),
      bottomNavigationBar: order.status == 'Đang giao'
          ? Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _confirmDelivery,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text(
            'Xác nhận đã nhận hàng',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      )
          : null,
    );
  }

  Widget _buildOrderStatusTimeline(Order order) {
    final statuses = [
      'Đặt hàng',
      'Đang xử lý',
      'Đang giao',
      'Đã giao',
      'Đã hủy',
    ];

    return Column(
      children: List.generate(statuses.length, (index) {
        final status = statuses[index];
        final isCompleted = order.statusHistory.any((h) => h.status == status);
        final isCurrent = order.status == status;
        final timestamp = order.statusHistory.firstWhere(
              (h) => h.status == status,
          orElse: () => OrderStatusHistory(status: '', timestamp: order.createdAt),
        ).timestamp;
        final isLast = index == statuses.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrent
                        ? Colors.blue[700]
                        : (isCompleted ? Colors.green : Colors.grey),
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: isCompleted || isCurrent ? Colors.white : Colors.transparent,
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    height: 40,
                    width: 2,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCurrent
                          ? Colors.blue[700]
                          : (isCompleted ? Colors.green : Colors.grey[600]),
                    ),
                  ),
                  if (isCompleted)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(timestamp),
                        style: const TextStyle(color: Color(0xFF718096), fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}