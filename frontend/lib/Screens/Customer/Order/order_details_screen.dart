import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Để định dạng ngày tháng
import 'package:danentang/models/OrderItem.dart';
import 'package:danentang/models/OrderStatusHistory.dart';
import 'package:danentang/models/ShippingAddress.dart';
import 'package:danentang/models/Order.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng', style: TextStyle(color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFFF7FAFC),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin đơn hàng',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
                  ),
                  const SizedBox(height: 16),
                  // Mã đơn hàng
                  Text('Mã đơn hàng: ${order.orderNumber}', style: const TextStyle(color: Color(0xFF2D3748))),
                  const SizedBox(height: 8),
                  // Tổng tiền
                  Text('Tổng cộng: ₫${NumberFormat('#,###').format(order.totalAmount)}', style: const TextStyle(color: Color(0xFF2D3748))),
                  const SizedBox(height: 8),
                  // Giảm giá (nếu có)
                  if (order.discountAmount > 0) ...[
                    Text('Giảm giá: ₫${NumberFormat('#,###').format(order.discountAmount)}', style: const TextStyle(color: Color(0xFF2D3748))),
                  ],
                  // Mã giảm giá (nếu có)
                  if (order.couponCode != null) ...[
                    const SizedBox(height: 8),
                    Text('Mã giảm giá: ${order.couponCode}', style: const TextStyle(color: Color(0xFF2D3748))),
                  ],
                  // Điểm thưởng sử dụng (nếu có)
                  if (order.loyaltyPointsUsed > 0) ...[
                    const SizedBox(height: 8),
                    Text('Điểm thưởng sử dụng: ${order.loyaltyPointsUsed}', style: const TextStyle(color: Color(0xFF2D3748))),
                  ],
                  const SizedBox(height: 16),
                  // Trạng thái
                  Text('Trạng thái: ${order.status}', style: const TextStyle(color: Color(0xFF2D3748))),
                  const SizedBox(height: 16),
                  // Lịch sử trạng thái
                  if (order.statusHistory.isNotEmpty) ...[
                    const Text('Lịch sử trạng thái:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2D3748))),
                    ...order.statusHistory.map((history) => Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${DateFormat('dd/MM/yyyy HH:mm').format(history.timestamp)} - ${history.status}',
                        style: const TextStyle(color: Color(0xFF718096)),
                      ),
                    )),
                  ],
                  const SizedBox(height: 16),
                  // Địa chỉ giao hàng
// Trong phần build của OrderDetailsScreen
                  const Text('Địa chỉ giao hàng:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2D3748))),
                  Text(
                    [
                      order.shippingAddress.street,
                      order.shippingAddress.city,
                      order.shippingAddress.state,
                      order.shippingAddress.postalCode,
                      order.shippingAddress.country,
                    ].where((part) => part != null && part.isNotEmpty).join(', '),
                    style: const TextStyle(color: Color(0xFF718096)),
                  ),
                  const SizedBox(height: 16),
                  // Danh sách sản phẩm
                  const Text('Sản phẩm:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2D3748))),
                  ...order.items.map((item) => ListTile(
                    leading: const Icon(Icons.watch, color: Color(0xFF38B2AC)),
                    title: Text(item.productName, style: const TextStyle(color: Color(0xFF2D3748))),
                    subtitle: Text(
                      'Phân loại: ${item.variantName}, Số lượng: ${item.quantity}, Giá: ₫${NumberFormat('#,###').format(item.price)}',
                      style: const TextStyle(color: Color(0xFF718096)),
                    ),
                  )),
                  const SizedBox(height: 16),
                  // Ngày tạo và cập nhật
                  Text(
                    'Đặt hàng lúc: ${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)}',
                    style: const TextStyle(color: Color(0xFF718096)),
                  ),
                  Text(
                    'Cập nhật lần cuối: ${DateFormat('dd/MM/yyyy HH:mm').format(order.updatedAt)}',
                    style: const TextStyle(color: Color(0xFF718096)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}