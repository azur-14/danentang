import 'dart:convert';
import 'dart:typed_data';
import 'package:danentang/ultis/image_helper.dart';
import 'package:flutter/material.dart';
import 'package:danentang/data/order_data.dart';
import 'package:danentang/models/Order.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:danentang/Service/product_service.dart';
import 'package:danentang/models/OrderStatusHistory.dart';
import 'package:danentang/models/product.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  List<Product> products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final result = await ProductService.fetchAllProducts();
    setState(() {
      products = result;
      _isLoading = false;
    });
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Mã đơn hàng:', style: TextStyle(color: Color(0xFF718096))),
                          Text(order.orderNumber, style: const TextStyle(color: Color(0xFF2D3748))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ngày đặt hàng:', style: TextStyle(color: Color(0xFF718096))),
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
                          const Text('Tổng tiền:', style: TextStyle(color: Color(0xFF718096))),
                          Text(
                            '₫${NumberFormat('#,##0', 'vi_VN').format(order.totalAmount)}',
                            style: const TextStyle(
                              color: Color(0xFF2D3748),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tên người nhận: ${order.shippingAddress.receiverName}',
                        style: const TextStyle(color: Color(0xFF2D3748)),
                      ),
                      Text(
                        order.shippingAddress.addressLine,
                        style: const TextStyle(color: Color(0xFF2D3748)),
                      ),
                      Text(
                        'Phường/Xã: ${order.shippingAddress.ward}',
                        style: const TextStyle(color: Color(0xFF2D3748)),
                      ),
                      Text(
                        'Quận/Huyện: ${order.shippingAddress.district}',
                        style: const TextStyle(color: Color(0xFF2D3748)),
                      ),
                      Text(
                        'Thành phố: ${order.shippingAddress.city}',
                        style: const TextStyle(color: Color(0xFF2D3748)),
                      ),
                      Text(
                        'Số điện thoại: ${order.shippingAddress.phoneNumber}',
                        style: const TextStyle(color: Color(0xFF2D3748)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Product List
              const Text(
                'Sản phẩm',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              ...order.items.map((item) {
                final product = products.firstWhere(
                      (p) => p.variants.any((v) => v.id == item.productVariantId),
                  orElse: () => Product(
                    id: '',
                    name: '',
                    price: 0,
                    discountPercentage: 0,
                    categoryId: '',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    images: [],
                    variants: [],
                  ),
                );
                final base64Image = product.images.isNotEmpty ? product.images.first.url : null;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: imageFromBase64String(
                              base64Image,
                              width: 80,
                              height: 80,
                              placeholder: const AssetImage('assets/placeholder.png'),
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
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
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
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Ngày giao hàng dự kiến:', style: TextStyle(color: Color(0xFF718096))),
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
                          const Text('Mã theo dõi:', style: TextStyle(color: Color(0xFF718096))),
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
              const SizedBox(height: 16),
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
              const SizedBox(height: 24),
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
      {'name': 'Đặt hàng', 'icon': Icons.event_note},
      {'name': 'Đang xử lý', 'icon': Icons.hourglass_empty},
      {'name': 'Đang giao', 'icon': Icons.local_shipping},
      {'name': 'Đã giao', 'icon': Icons.check_circle},
      {'name': 'Hoàn thành', 'icon': Icons.done_all},
    ];

    return Column(
      children: List.generate(statuses.length, (index) {
        final status = statuses[index]['name']!;
        final icon = statuses[index]['icon'] as IconData;
        final isCompleted = order.statusHistory.any((h) => h.status == status) || order.status == status;
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
                        : (isCompleted ? Colors.green : Colors.grey[300]),
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: isCompleted || isCurrent ? Colors.white : Colors.transparent,
                  ),
                ),
                if (!isLast)
                  Container(
                    height: 40,
                    width: 2,
                    color: isCompleted ? Colors.green : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  if (isCompleted && timestamp != null)
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