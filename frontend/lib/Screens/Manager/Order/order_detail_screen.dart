import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final address = order.shippingAddress;

    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết đơn hàng ${order.orderNumber}"),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle("Thông tin người nhận"),
          _buildInfoRow("Họ tên", address.receiverName),
          _buildInfoRow("SĐT", address.phoneNumber),
          _buildInfoRow("Địa chỉ", "${address.addressLine}, ${address.ward}, ${address.district}, ${address.city}"),

          const SizedBox(height: 16),
          _buildSectionTitle("Thông tin đơn hàng"),
          _buildInfoRow("Mã đơn hàng", order.orderNumber),
          _buildInfoRow("Tổng tiền", "${order.totalAmount.toStringAsFixed(0)} ₫"),
          if (order.discountAmount > 0) _buildInfoRow("Giảm giá", "-${order.discountAmount.toStringAsFixed(0)} ₫"),
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
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: _statusOptions
                .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                .toList(),
            onChanged: (value) => setState(() => _selectedStatus = value!),
          ),

          const SizedBox(height: 16),
          _buildSectionTitle("Lịch sử trạng thái"),
          ...order.statusHistory.map((s) => ListTile(
            leading: const Icon(Icons.history),
            title: Text(s.status),
            subtitle: Text(DateFormat('dd/MM/yyyy – HH:mm').format(s.timestamp)),
          )),

          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            icon: const Icon(Icons.save),
            label: const Text("Lưu thay đổi"),
              onPressed: () async {
                try {
                  final history = OrderStatusHistory(
                    status: _selectedStatus,
                    timestamp: DateTime.now(),
                  );
                  if (widget.order.id != null) {
                    await OrderService.instance.updateOrderStatus(widget.order.id!, history);
                  } else {
                    // Xử lý trường hợp id bị null, báo lỗi hoặc không làm gì cả
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đã lưu trạng thái đơn hàng")),
                  );
                  Navigator.pop(context); // hoặc refetch
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Lỗi: $e")),
                  );
                }
              }

          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text("$title:", style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}
