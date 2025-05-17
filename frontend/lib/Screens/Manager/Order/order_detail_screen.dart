import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Service/order_service.dart';
import '../../../models/Order.dart';
import '../../../models/OrderStatusHistory.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late String _selectedStatus;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _statusOptions = [
    'pending',
    'in progress',
    'delivered',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');
    if (token == null || role != 'admin') {
      context.go('/login');
    }
  }

  Future<void> _updateOrderStatus() async {
    if (_selectedStatus == widget.order.status) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trạng thái không thay đổi')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận cập nhật'),
        content: Text('Bạn có chắc muốn cập nhật trạng thái thành "$_selectedStatus"?'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      if (widget.order.id == null) {
        throw Exception('ID đơn hàng không hợp lệ');
      }
      final history = OrderStatusHistory(
        status: _selectedStatus,
        timestamp: DateTime.now(),
      );
      await OrderService.instance.updateOrderStatus(widget.order.id!, history);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật trạng thái đơn hàng')),
      );
      context.go('/manager/orders'); // Quay lại danh sách đơn hàng
    } catch (e) {
      setState(() => _errorMessage = 'Lỗi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final address = order.shippingAddress;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          context.go('/manager/orders'); // Quay lại danh sách đơn hàng
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chi tiết đơn hàng ${order.orderNumber}"),
          centerTitle: true,
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => setState(() {}), // Làm mới giao diện
            ),
          ],
        ),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle("Thông tin người nhận"),
                _buildInfoRow("Họ tên", address.receiverName),
                _buildInfoRow("SĐT", address.phoneNumber),
                _buildInfoRow(
                  "Địa chỉ",
                  "${address.addressLine}, ${address.ward}, ${address.district}, ${address.city}",
                ),
                const SizedBox(height: 16),
                _buildSectionTitle("Thông tin đơn hàng"),
                _buildInfoRow("Mã đơn hàng", order.orderNumber),
                _buildInfoRow("Tổng tiền", "${order.totalAmount.toStringAsFixed(0)} ₫"),
                if (order.discountAmount > 0)
                  _buildInfoRow("Giảm giá", "-${order.discountAmount.toStringAsFixed(0)} ₫"),
                if (order.couponCode != null) _buildInfoRow("Mã giảm giá", order.couponCode!),
                _buildInfoRow("Điểm thưởng dùng", "${order.loyaltyPointsUsed}"),
                const SizedBox(height: 16),
                _buildSectionTitle("Danh sách sản phẩm"),
                ...order.items.map((item) => ListTile(
                  title: Text(item.productName),
                  subtitle: Text("Phân loại: ${item.variantName}\nSố lượng: ${item.quantity}"),
                  trailing: Text("${item.price.toStringAsFixed(0)} ₫"),
                )),
                const SizedBox(height: 16),
                _buildSectionTitle("Trạng thái đơn hàng"),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Trạng thái',
                    border: OutlineInputBorder(),
                  ),
                  items: _statusOptions
                      .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedStatus = value!),
                ),
                const SizedBox(height: 16),
                _buildSectionTitle("Lịch sử trạng thái"),
                if (order.statusHistory.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("Chưa có lịch sử trạng thái"),
                  )
                else
                  ...order.statusHistory.map((s) => ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(s.status),
                    subtitle: Text(DateFormat('dd/MM/yyyy – HH:mm').format(s.timestamp)),
                  )),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                      icon: const Icon(Icons.save),
                      label: const Text("Lưu thay đổi"),
                      onPressed: _isLoading ? null : _updateOrderStatus,
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () => context.go('/manager/orders'),
                      child: const Text("Hủy"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$title:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}