import 'dart:convert';
import 'dart:typed_data';
import 'package:danentang/ultis/image_helper.dart';
import 'package:flutter/material.dart';
import 'package:danentang/data/order_data.dart';
import 'package:danentang/models/Order.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:danentang/models/OrderStatusHistory.dart';
import 'package:danentang/models/product.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;
  final List<Product> products;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    // Tính tổng số lượng và tổng giá
    final totalQuantity = order.items.fold(0, (sum, item) => sum + item.quantity);
    final totalPrice = order.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chi tiết đơn hàng',
          style: TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6F0FA), Color(0xFFF7FAFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin đơn hàng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Mã đơn hàng: ${order.orderNumber}',
                    style: const TextStyle(color: Color(0xFF2D3748), fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tổng cộng: ₫${NumberFormat('#,###').format(order.totalAmount)}',
                    style: const TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (order.discountAmount > 0) ...[
                    Text(
                      'Giảm giá: ₫${NumberFormat('#,###').format(order.discountAmount)}',
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                    ),
                  ],
                  if (order.couponCode != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Mã giảm giá: ${order.couponCode}',
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                    ),
                  ],
                  if (order.loyaltyPointsUsed > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Điểm thưởng sử dụng: ${order.loyaltyPointsUsed}',
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Trạng thái: ${order.status}',
                    style: const TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Timeline trạng thái
                  const Text(
                    'Lịch sử trạng thái:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildOrderStatusTimeline(),
                  const SizedBox(height: 16),
                  // Địa chỉ giao hàng
                  const Text(
                    'Địa chỉ giao hàng:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  Text(
                    [
                      order.shippingAddress.addressLine,
                      order.shippingAddress.ward,
                      order.shippingAddress.district,
                      order.shippingAddress.city,
                    ].where((part) => part.isNotEmpty).join(', '),
                    style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  // Danh sách sản phẩm
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Giỏ hàng của bạn',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...order.items.map((item) {
                            final product = products.firstWhere(
                                  (p) => p.id == item.productId,
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
                            final imageUrl = product.images.isNotEmpty
                                ? (product?.images.isNotEmpty == true ? product!.images.first.url : 'assets/placeholder.png')
                                : 'assets/placeholder.png';

                            return Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image(
                                        image: AssetImage(imageUrl),
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(color: Colors.grey, width: 60, height: 60);
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
                                              color: Color(0xFF2D3748),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Phân loại: ${item.variantName}, Số lượng: ${item.quantity}, Giá: ₫${NumberFormat('#,###').format(item.price)}',
                                            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tổng số lượng: $totalQuantity sản phẩm',
                                style: const TextStyle(
                                  color: Color(0xFF1E3A8A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Tổng: ₫${NumberFormat('#,###').format(totalPrice)}',
                                style: const TextStyle(
                                  color: Color(0xFF1E3A8A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Đặt hàng lúc: ${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)}',
                    style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                  ),
                  Text(
                    'Cập nhật lần cuối: ${DateFormat('dd/MM/yyyy HH:mm').format(order.updatedAt)}',
                    style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: order.status == 'Đang giao'
          ? Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            context.push('/review/${order.id}');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
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

  // Widget để hiển thị timeline trạng thái đơn hàng
  Widget _buildOrderStatusTimeline() {
    // Danh sách các trạng thái có thể có (theo thứ tự)
    final List<Map<String, dynamic>> statusSteps = [
      {'status': 'Đặt hàng', 'timestamp': order.createdAt, 'completed': true},
      {
        'status': 'Đang xử lý',
        'timestamp': _getStatusTimestamp('Đang xử lý'),
        'completed': _isStatusCompleted('Đang xử lý'),
      },
      {
        'status': 'Đang giao',
        'timestamp': _getStatusTimestamp('Đang giao'),
        'completed': _isStatusCompleted('Đang giao'),
      },
      {
        'status': 'Đã giao',
        'timestamp': _getStatusTimestamp('Đã giao'),
        'completed': _isStatusCompleted('Đã giao'),
      },
      {
        'status': 'Hoàn thành',
        'timestamp': _getStatusTimestamp('Hoàn thành'),
        'completed': _isStatusCompleted('Hoàn thành'),
      },
    ];

    return Column(
      children: List.generate(statusSteps.length, (index) {
        final step = statusSteps[index];
        final isCompleted = step['completed'] as bool;
        final isCurrent = order.status == step['status'];
        final isLast = index == statusSteps.length - 1;

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
                        : (isCompleted ? const Color(0xFF10B981) : Colors.grey[300]),
                  ),
                  child: Icon(
                    isCompleted || isCurrent ? Icons.check : Icons.circle,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted ? const Color(0xFF10B981) : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step['status'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isCurrent
                          ? Colors.blue[700]
                          : (isCompleted ? const Color(0xFF10B981) : Colors.grey[600]),
                    ),
                  ),
                  if (step['timestamp'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(step['timestamp'] as DateTime),
                        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
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

  // Kiểm tra xem trạng thái đã hoàn thành chưa
  bool _isStatusCompleted(String status) {
    return order.statusHistory.any((history) => history.status == status) || order.status == status;
  }

  // Lấy thời gian của trạng thái từ statusHistory
  DateTime? _getStatusTimestamp(String status) {
    final history = order.statusHistory.firstWhere(
          (history) => history.status == status,
      orElse: () => OrderStatusHistory(status: '', timestamp: DateTime.now()),
    );
    return history.status.isNotEmpty ? history.timestamp : null;
  }
}