import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/Order.dart';
import '../../../Service/order_service.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  int _currentIndex = 0;
  bool _isLoggedIn = true;
  int _currentPage = 1;
  static const int _itemsPerPage = 20;

  List<Order> orders = [];
  Set<int> selectedIndexes = {};

  String selectedFilter = 'all';
  String? selectedStatus;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final fetched = await OrderService.fetchAllOrders();
      setState(() {
        orders = _applyFilters(fetched);
        _currentPage = 1;
      });
    } catch (e) {
      debugPrint("❌ Error fetching orders: $e");
    }
  }

  List<Order> _applyFilters(List<Order> all) {
    final now = DateTime.now();
    List<Order> filtered = all;

    if (selectedFilter != 'all') {
      if (selectedFilter == 'today') {
        filtered = filtered.where((o) =>
        o.createdAt.year == now.year &&
            o.createdAt.month == now.month &&
            o.createdAt.day == now.day
        ).toList();
      } else if (selectedFilter == 'week') {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        filtered = filtered.where((o) => o.createdAt.isAfter(startOfWeek)).toList();
      } else if (selectedFilter == 'month') {
        filtered = filtered.where((o) =>
        o.createdAt.year == now.year && o.createdAt.month == now.month
        ).toList();
      }
    }

    if (startDate != null && endDate != null) {
      filtered = filtered.where((o) =>
      o.createdAt.isAfter(startDate!.subtract(const Duration(days: 1))) &&
          o.createdAt.isBefore(endDate!.add(const Duration(days: 1)))
      ).toList();
    }

    if (selectedStatus != null && selectedStatus != 'all') {
      filtered = filtered.where((o) => o.status == selectedStatus).toList();
    }

    return filtered;
  }

  List<Order> get _pagedOrders {
    final start = (_currentPage - 1) * _itemsPerPage;
    return orders.skip(start).take(_itemsPerPage).toList();
  }

  int get totalPages => (orders.length / _itemsPerPage).ceil();

  void _changeFilter(String value) {
    setState(() {
      selectedFilter = value;
      startDate = null;
      endDate = null;
    });
    _fetchOrders();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onStatusChanged(String? value) {
    setState(() {
      selectedStatus = value;
    });
    _fetchOrders();
  }

  void _onDateRangePicked(DateTimeRange? range) {
    if (range != null) {
      setState(() {
        startDate = range.start;
        endDate = range.end;
        selectedFilter = 'custom';
      });
      _fetchOrders();
    }
  }

  void _toggleSelect(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
      } else {
        selectedIndexes.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý đơn hàng", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          DropdownButton<String>(
            value: selectedStatus ?? 'all',
            underline: Container(),
            onChanged: _onStatusChanged,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('Tất cả')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'in progress', child: Text('In Progress')),
              DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.black),
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2023),
                lastDate: DateTime.now(),
              );
              _onDateRangePicked(range);
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onSelected: _changeFilter,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'all', child: Text("Tất cả")),
              PopupMenuItem(value: 'today', child: Text("Hôm nay")),
              PopupMenuItem(value: 'week', child: Text("Tuần này")),
              PopupMenuItem(value: 'month', child: Text("Tháng này")),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          Expanded(
            child: _pagedOrders.isEmpty
                ? const Center(child: Text('Không có đơn hàng.'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pagedOrders.length,
              itemBuilder: (context, index) {
                final realIndex = (_currentPage - 1) * _itemsPerPage + index;
                final order = _pagedOrders[index];
                final selected = selectedIndexes.contains(realIndex);
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
                  ),
                  child: Opacity(
                    opacity: selected ? 0.6 : 1.0,
                    child: _OrderCard(order: order),
                  ),
                );
              },
            ),
          ),
          _buildPaginationBar(),
        ],
      ),
      bottomNavigationBar: isMobile
          ? MobileNavigationBar(
        selectedIndex: _currentIndex,
        onItemTapped: _onItemTapped,
        isLoggedIn: _isLoggedIn,
        role: 'manager',
      )
          : null,
    );
  }

  Widget _buildPaginationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 1
                ? () => setState(() => _currentPage--)
                : null,
          ),
          Text("Trang $_currentPage / $totalPages"),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < totalPages
                ? () => setState(() => _currentPage++)
                : null,
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.blue;
      case 'in progress':
        return Colors.orange;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final shipping = order.shippingAddress;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(order.orderNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(order.status,
                    style: TextStyle(
                        color: getStatusColor(order.status),
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _infoRow("Người nhận", shipping.receiverName),
          _infoRow("SĐT", shipping.phoneNumber),
          _infoRow("Địa chỉ",
              "${shipping.addressLine}, ${shipping.ward}, ${shipping.district}, ${shipping.city}"),
          _infoRow("Ngày tạo", DateFormat('dd/MM/yyyy – HH:mm').format(order.createdAt)),
          _infoRow("Tổng tiền", "${order.totalAmount.toStringAsFixed(0)} ₫"),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Flexible(child: Text(value)),
      ],
    ),
  );
}
