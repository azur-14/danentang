import 'package:flutter/material.dart';
import 'package:danentang/data/order_data.dart';
import 'package:danentang/models/Order.dart';
import 'package:go_router/go_router.dart';
import 'package:danentang/widgets/Order/OrderCard.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

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
      appBar: AppBar(
        title: const Text('Đơn hàng của tôi',
            style: TextStyle(color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            width: isWeb ? contentWidth : double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.blue[700],
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Colors.blue[700],
              tabs: const [
                Tab(text: 'Tất cả'),
                Tab(text: 'Chờ xác nhận'),
                Tab(text: 'Đang giao'),
                Tab(text: 'Đã giao'),
                Tab(text: 'Đã hủy'),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: contentWidth),
          padding: const EdgeInsets.all(16),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(testOrders),
              _buildOrderList(testOrders
                  .where((order) => order.status == 'Đặt hàng' || order.status == 'Đang chờ xử lý')
                  .toList()),
              _buildOrderList(testOrders
                  .where((order) => order.status == 'Đang giao')
                  .toList()),
              _buildOrderList(testOrders
                  .where((order) => order.status == 'Đã giao')
                  .toList()),
              _buildOrderList(testOrders
                  .where((order) => order.status == 'Đã hủy')
                  .toList()),
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