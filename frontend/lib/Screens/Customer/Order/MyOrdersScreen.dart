import 'package:flutter/material.dart';
import 'package:danentang/models/Order.dart';
import 'package:danentang/models/OrderItem.dart';
import 'package:danentang/models/OrderStatusHistory.dart';
import 'package:intl/intl.dart'; // For formatting dates

class MyOrdersScreen extends StatefulWidget {
  final List<Order> orders;

  const MyOrdersScreen({super.key, required this.orders});

  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;
    final contentWidth = isWeb ? 800.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: isWeb
          ? null
          : AppBar(
        title: const Text('Đơn hàng của tôi', style: TextStyle(color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF5A4FCF),
          unselectedLabelColor: const Color(0xFF718096),
          indicatorColor: const Color(0xFF5A4FCF),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Chờ xác nhận'),
            Tab(text: 'Đang giao'),
            Tab(text: 'Đã giao'),
            Tab(text: 'Đã hủy'),
          ],
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: contentWidth),
          padding: const EdgeInsets.all(16),
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tất cả
              _buildOrderList(widget.orders),
              // Chờ xác nhận (pending)
              _buildOrderList(widget.orders.where((order) => order.status.toLowerCase() == 'pending').toList()),
              // Đang giao (shipped)
              _buildOrderList(widget.orders.where((order) => order.status.toLowerCase() == 'shipped').toList()),
              // Đã giao (delivered)
              _buildOrderList(widget.orders.where((order) => order.status.toLowerCase() == 'delivered').toList()),
              // Đã hủy (canceled)
              _buildOrderList(widget.orders.where((order) => order.status.toLowerCase() == 'canceled').toList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    return orders.isEmpty
        ? const Center(
      child: Text(
        'Không có đơn hàng nào',
        style: TextStyle(fontSize: 16, color: Color(0xFF2D3748)),
      ),
    )
        : ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(order: order);
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn hàng #${order.orderNumber}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tổng cộng: ₫${order.totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(color: Color(0xFF2D3748)),
            ),
            const SizedBox(height: 8),
            Text(
              'Ngày đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)}',
              style: const TextStyle(color: Color(0xFF718096)),
            ),
            const SizedBox(height: 12),
            // Order Items
            const Text(
              'Sản phẩm:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
            ),
            const SizedBox(height: 4),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(color: Color(0xFF2D3748)),
                        ),
                        Text(
                          'ID Sản phẩm: ${item.productId}',
                          style: const TextStyle(color: Color(0xFF718096), fontSize: 12),
                        ),
                        Text(
                          'Biến thể: ${item.variantName}, Số lượng: ${item.quantity}',
                          style: const TextStyle(color: Color(0xFF718096), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₫${(item.price * item.quantity).toStringAsFixed(0)}',
                    style: const TextStyle(color: Color(0xFFF56565)),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
            // Status History
            ExpansionTile(
              title: const Text(
                'Tình trạng đơn hàng',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
              ),
              children: order.statusHistory.map((history) {
                return ListTile(
                  title: Text(
                    history.status.toUpperCase(),
                    style: const TextStyle(color: Color(0xFF2D3748)),
                  ),
                  subtitle: Text(
                    'Cập nhật: ${DateFormat('dd/MM/yyyy HH:mm').format(history.timestamp)}\n',
                    style: const TextStyle(color: Color(0xFF718096)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String displayText;
    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = Colors.orange;
        displayText = 'Chờ xác nhận';
        break;
      case 'shipped':
        chipColor = Colors.blue;
        displayText = 'Đang giao';
        break;
      case 'delivered':
        chipColor = Colors.green;
        displayText = 'Đã giao';
        break;
      case 'canceled':
        chipColor = Colors.red;
        displayText = 'Đã hủy';
        break;
      default:
        chipColor = Colors.grey;
        displayText = 'Không xác định';
    }
    return Chip(
      label: Text(
        displayText,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
    );
  }
}