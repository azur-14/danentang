import 'package:flutter/material.dart';
import 'package:danentang/data/order_data.dart';
import 'package:danentang/models/Order.dart';
import 'package:go_router/go_router.dart';
import 'package:danentang/widgets/Order/OrderCard.dart';
import 'package:danentang/models/product.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late List<Product> products;

  // Lưu trữ các danh sách đơn hàng đã lọc
  late Map<String, List<Order>> filteredOrders;
  late Map<String, int> orderCounts;

  @override
  bool get wantKeepAlive => true; // Giữ trạng thái của widget

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Lấy danh sách sản phẩm từ testOrders
    products = testOrders
        .expand((o) => o.items)
        .map((item) => Product(
      id: item.productId,
      name: item.productName,
      brand: '',
      description: '',
      discountPercentage: 0,
      categoryId: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      images: [
        ProductImage(
          id: 'img001',
          url: 'assets/images/laptop.jpg',
          sortOrder: 1,
        ),
      ],
      variants: [
        ProductVariant(
          id: item.productVariantId ?? '',
          variantName: item.variantName,
          additionalPrice: 0,
          inventory: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
    ))
        .toSet()
        .toList();

    // Tính toán các danh sách đơn hàng và số lượng trước
    filteredOrders = {
      'all': testOrders,
      'pending': testOrders
          .where((order) => order.status == 'Đặt hàng' || order.status == 'Đang chờ xử lý')
          .toList(),
      'shipped': testOrders.where((order) => order.status == 'Đang giao').toList(),
      'delivered': testOrders.where((order) => order.status == 'Đã giao').toList(),
      'canceled': testOrders.where((order) => order.status == 'Đã hủy').toList(),
    };

    orderCounts = {
      'all': testOrders.length,
      'pending': filteredOrders['pending']!.length,
      'shipped': filteredOrders['shipped']!.length,
      'delivered': filteredOrders['delivered']!.length,
      'canceled': filteredOrders['canceled']!.length,
    };
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Cần thiết khi sử dụng AutomaticKeepAliveClientMixin

    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;
    final contentWidth = isWeb ? 800.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: const Text(
          'Đơn hàng của tôi',
          style: TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () {
            print('Popping back from MyOrdersScreen');
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/homepage'); // Quay về trang chủ nếu không thể pop
            }
          },
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
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 14),
              tabs: [
                Tab(text: 'Tất cả (${orderCounts['all']})'),
                Tab(text: 'Chờ xác nhận (${orderCounts['pending']})'),
                Tab(text: 'Đang giao (${orderCounts['shipped']})'),
                Tab(text: 'Đã giao (${orderCounts['delivered']})'),
                Tab(text: 'Đã hủy (${orderCounts['canceled']})'),
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
              _buildOrderList(filteredOrders['all']!),
              _buildOrderList(filteredOrders['pending']!),
              _buildOrderList(filteredOrders['shipped']!),
              _buildOrderList(filteredOrders['delivered']!),
              _buildOrderList(filteredOrders['canceled']!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    return orders.isEmpty
        ? const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Không có đơn hàng nào',
            style: TextStyle(fontSize: 16, color: Color(0xFF2D3748)),
          ),
        ],
      ),
    )
        : ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
        );
      },
    );
  }
}