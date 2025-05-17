import 'package:flutter/material.dart';
import 'package:danentang/data/order_data.dart';
import 'package:danentang/models/Order.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:danentang/Service/product_service.dart';
import 'package:danentang/models/OrderStatusHistory.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/ultis/image_helper.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> with SingleTickerProviderStateMixin {
  List<Product> products = [];
  bool _isLoading = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.push('/review/${widget.orderId}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = testOrders.firstWhere(
          (o) => o.id == widget.orderId,
      orElse: () => throw Exception('Order not found'),
    );
    final expectedDeliveryDate = order.createdAt.add(const Duration(days: 5));
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B5EFC),
        elevation: 4,
        title: Text(
          'Chi tiết đơn hàng #${order.orderNumber}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF4B5EFC)))
            : LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Container(
                  margin: const EdgeInsets.all(12.0),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      child: FadeTransition(
                        opacity: _animation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Thông tin đơn hàng'),
                            const SizedBox(height: 12),
                            Card(
                              elevation: 4, // Giữ đổ bóng
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildInfoRow('Mã đơn hàng:', order.orderNumber),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      'Ngày đặt hàng:',
                                      DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      'Tổng tiền:',
                                      '₫${NumberFormat('#,##0', 'vi_VN').format(order.totalAmount)}',
                                      isBold: true,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Địa chỉ giao hàng'),
                            const SizedBox(height: 12),
                            Card(
                              elevation: 4, // Giữ đổ bóng
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Wrap(
                                  spacing: 16.0,
                                  runSpacing: 12.0,
                                  children: [
                                    _buildAddressInfo('Tên người nhận:', order.shippingAddress.receiverName),
                                    _buildAddressInfo('Địa chỉ:', order.shippingAddress.addressLine),
                                    _buildAddressInfo('Phường/Xã:', order.shippingAddress.ward),
                                    _buildAddressInfo('Quận/Huyện:', order.shippingAddress.district),
                                    _buildAddressInfo('Thành phố:', order.shippingAddress.city),
                                    _buildAddressInfo('Số điện thoại:', order.shippingAddress.phoneNumber),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Sản phẩm'),
                            const SizedBox(height: 12),
                            ...order.items.map((item) {
                              final product = products.firstWhere(
                                    (p) => p.variants.any((v) => v.id == item.productVariantId),
                                orElse: () => Product(
                                  id: '',
                                  name: 'Sản phẩm không tìm thấy',
                                  discountPercentage: 0,
                                  categoryId: '',
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                  images: [],
                                  variants: [],
                                ),
                              );
                              final imageUrl = product.images.isNotEmpty ? product.images.first.url : 'assets/placeholder.jpg';

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Card(
                                  elevation: 2, // Giữ đổ bóng
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Hero(
                                          tag: 'product-image-${item.productVariantId ?? item.productName.hashCode}',
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.asset(
                                              imageUrl,
                                              width: screenWidth * 0.25 > 80 ? 80 : screenWidth * 0.25,
                                              height: screenWidth * 0.25 > 80 ? 80 : screenWidth * 0.25,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Image.asset(
                                                  'assets/placeholder.jpg',
                                                  width: screenWidth * 0.25 > 80 ? 80 : screenWidth * 0.25,
                                                  height: screenWidth * 0.25 > 80 ? 80 : screenWidth * 0.25,
                                                  fit: BoxFit.cover,
                                                );
                                              },
                                            ),
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
                                                  color: Color(0xFF1E293B),
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Biến thể: ${item.variantName} | Số lượng: ${item.quantity}',
                                                style: const TextStyle(
                                                  color: Color(0xFF64748B),
                                                  fontSize: 13,
                                                ),
                                              ),
                                              if (item.productVariantId != null) ...[
                                                const SizedBox(height: 6),
                                                Text(
                                                  'Mã biến thể: ${item.productVariantId}',
                                                  style: const TextStyle(
                                                    color: Color(0xFF64748B),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(height: 8),
                                              Text(
                                                '₫${NumberFormat('#,##0', 'vi_VN').format(item.price * item.quantity)}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1E293B),
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
                            }).toList(),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Chi tiết đơn hàng'),
                            const SizedBox(height: 12),
                            Card(
                              elevation: 4, // Giữ đổ bóng
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    _buildInfoRow(
                                      'Ngày giao hàng dự kiến:',
                                      DateFormat('dd MMM yyyy').format(expectedDeliveryDate),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow('Mã theo dõi:', 'TRK${order.id}52126542'),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildSectionTitle('Tình trạng đơn hàng'),
                            const SizedBox(height: 12),
                            Card( // Bọc phần này trong Card để tách biệt
                              elevation: 4, // Đổ bóng để nổi bật
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: _buildOrderStatusTimeline(order),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: order.status == 'Đang giao'
          ? FloatingActionButton.extended(
        onPressed: _confirmDelivery,
        backgroundColor: const Color(0xFF4B5EFC),
        label: const Text(
          'Xác nhận đã nhận hàng',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        icon: const Icon(Icons.check, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      )
          : null,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E293B),
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF1E293B),
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressInfo(String label, String value) {
    return SizedBox(
      width: 300,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatusTimeline(Order order) {
    final List<Map<String, dynamic>> statuses = [
      {'name': 'Đặt hàng', 'icon': Icons.event_note},
      {'name': 'Đang xử lý', 'icon': Icons.hourglass_empty},
      {'name': 'Đang giao', 'icon': Icons.local_shipping},
      {'name': 'Đã giao', 'icon': Icons.check_circle},
      {'name': 'Hoàn thành', 'icon': Icons.done_all},
    ];

    return Column(
      children: List.generate(statuses.length, (index) {
        final String status = statuses[index]['name'] as String;
        final IconData icon = statuses[index]['icon'] as IconData;
        final bool isCompleted = order.statusHistory.any((h) => h.status == status) || order.status == status;
        final bool isCurrent = order.status == status;
        final DateTime timestamp = order.statusHistory.firstWhere(
              (h) => h.status == status,
          orElse: () => OrderStatusHistory(status: '', timestamp: order.createdAt),
        ).timestamp;
        final bool isLast = index == statuses.length - 1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedOpacity(
                opacity: isCompleted || isCurrent ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 400),
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrent
                            ? const Color(0xFF4B5EFC)
                            : (isCompleted ? const Color(0xFF22C55E) : Colors.grey.shade200),
                        border: Border.all(color: Colors.grey.shade200, width: 2),
                      ),
                      child: Icon(
                        icon,
                        size: 18,
                        color: isCompleted || isCurrent ? Colors.white : Colors.grey.shade400,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        height: 48,
                        width: 2,
                        color: isCompleted ? const Color(0xFF22C55E) : Colors.grey.shade200,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                        color: isCompleted || isCurrent ? const Color(0xFF1E293B) : Colors.grey.shade500,
                      ),
                    ),
                    if (order.statusHistory.any((h) => h.status == status))
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          DateFormat('dd MMM yyyy, HH:mm').format(timestamp),
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}