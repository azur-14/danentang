import 'package:flutter/material.dart';
import 'package:danentang/models/Order.dart';
import 'package:danentang/Service/order_service.dart';
import 'package:danentang/widgets/Order/OrderCard.dart';
import 'package:danentang/widgets/Order/order_filter_widget.dart';
import 'package:danentang/models/product.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Service/user_service.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}
class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  List<Order> allOrders = [];
  List<Order> userOrders = [];
  String? userId;
  List<Product> products = [];
  bool _isLoading = true;
  String? _error;
  Map<String, List<Order>> filteredOrders = {};
  Map<String, int> orderCounts = {};
  DateTime? _startDate;
  DateTime? _endDate;
  RangeValues _priceRange = const RangeValues(0, 10000000);
  String _searchQuery = '';
  double _maxPrice = 10000000;
  late TabController _tabController;
  String _selectedCategory = 'All';
  String _selectedBrand = 'All';
  final List<String> _categories = ['All', 'Laptop', 'Headphones', 'MacBook'];
  final List<String> _brands = ['All', 'Lenovo', 'Apple', 'Logitech'];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initAndFetch();
  }

  Future<void> _initAndFetch() async {
    setState(() { _isLoading = true; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? '';
      if (email.isEmpty) throw Exception("Bạn chưa đăng nhập!");

      final user = await UserService().fetchUserByEmail(email);
      userId = user.id;

      // Gọi API mới, chỉ lấy đơn của user này
      userOrders = await OrderService.fetchOrdersByUserId(userId!);

      _applyFilters();
      setState(() { _isLoading = false; });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }
  Future<void> _fetchOrders() async {
    if (userId == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      userOrders = await OrderService.fetchOrdersByUserId(userId!);
      _applyFilters();
      setState(() { _isLoading = false; });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }
  void _applyFilters() {
    setState(() {
      List<Order> orders = userOrders.where((order) {
        bool passesDateFilter = true;
        if (_startDate != null) {
          passesDateFilter = order.createdAt.isAfter(_startDate!);
        }
        if (_endDate != null) {
          passesDateFilter =
              passesDateFilter && order.createdAt.isBefore(_endDate!);
        }

        bool passesPriceFilter =
            (order.totalAmount ?? 0) >= _priceRange.start &&
                (order.totalAmount ?? 0) <= _priceRange.end;

        bool passesSearchFilter = _searchQuery.isEmpty ||
            order.items.any((item) => item.productName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()));

        bool passesCategoryFilter = _selectedCategory == 'All' ||
            order.items.any(
                    (item) => item.productName.contains(_selectedCategory));

        bool passesBrandFilter = _selectedBrand == 'All' ||
            order.items.any(
                    (item) => item.productName.contains(_selectedBrand));

        return passesDateFilter &&
            passesPriceFilter &&
            passesSearchFilter &&
            passesCategoryFilter &&
            passesBrandFilter;
      }).toList();

      filteredOrders = {
        'all': orders,
        'pending': orders
            .where((order) =>
        order.status == 'Đặt hàng' ||
            order.status == 'Đang chờ xử lý' ||
            order.status == 'pending' ||
            order.status == 'Chờ xác nhận')
            .toList(),
        'shipped': orders
            .where((order) =>
        order.status == 'Đang giao' ||
            order.status == 'shipped')
            .toList(),
        'delivered': orders
            .where((order) =>
        order.status == 'Đã giao' ||
            order.status == 'delivered')
            .toList(),
        'canceled': orders
            .where((order) =>
        order.status == 'Đã hủy' ||
            order.status == 'canceled')
            .toList(),
      };

      orderCounts = {
        'all': filteredOrders['all']!.length,
        'pending': filteredOrders['pending']!.length,
        'shipped': filteredOrders['shipped']!.length,
        'delivered': filteredOrders['delivered']!.length,
        'canceled': filteredOrders['canceled']!.length,
      };
    });
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _priceRange = RangeValues(0, _maxPrice);
      _searchQuery = '';
      _selectedCategory = 'All';
      _selectedBrand = 'All';
      _applyFilters();
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return OrderFilterWidget(
          maxPrice: _maxPrice,
          priceRange: _priceRange,
          startDate: _startDate,
          endDate: _endDate,
          selectedCategory: _selectedCategory,
          selectedBrand: _selectedBrand,
          categories: _categories,
          brands: _brands,
          isDialog: true,
          onPriceRangeChanged: (values) {
            setState(() {
              _priceRange = values;
            });
          },
          onStartDateChanged: (date) {
            setState(() {
              _startDate = date;
            });
          },
          onEndDateChanged: (date) {
            setState(() {
              _endDate = date;
            });
          },
          onCategoryChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          onBrandChanged: (value) {
            setState(() {
              _selectedBrand = value;
            });
          },
          onApply: () {
            _applyFilters();
            Navigator.pop(context);
          },
          onReset: () {
            _clearFilters();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    bool hasActiveFilters = _startDate != null ||
        _endDate != null ||
        _priceRange.start != 0 ||
        _priceRange.end != _maxPrice ||
        _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Hero(
          tag: 'orders_title',
          child: Material(
            color: Colors.transparent,
            child: Text(
              'Đơn hàng của tôi',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        backgroundColor: Color(0xFF4B5EFC),
        elevation: 2,
        shadowColor: Colors.grey.withOpacity(0.2),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              if (context.canPop()) {
                context.pop();
              }
            } else {
              context.go('/homepage');
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFFFFFFF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth =
                constraints.maxWidth < 900 ? constraints.maxWidth : 900.0;
                return Center(
                  child: Container(
                    width: contentWidth,
                    padding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      labelColor: Colors.white,
                      unselectedLabelColor: Color(0xFF64748B),
                      indicator: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      labelPadding:
                      EdgeInsets.symmetric(horizontal: 12),
                      tabs: [
                        _buildTab('Tất cả', orderCounts['all'] ?? 0,
                            Icons.all_inclusive),
                        _buildTab('Chờ xác nhận', orderCounts['pending'] ?? 0,
                            Icons.hourglass_empty),
                        _buildTab('Đang giao', orderCounts['shipped'] ?? 0,
                            Icons.local_shipping),
                        _buildTab('Đã giao', orderCounts['delivered'] ?? 0,
                            Icons.check_circle),
                        _buildTab('Đã hủy', orderCounts['canceled'] ?? 0,
                            Icons.cancel),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: MediaQuery.of(context).size.width <= 800
          ? FloatingActionButton(
        onPressed: _showFilterDialog,
        backgroundColor: Color(0xFF3B82F6),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.filter_list, color: Colors.white),
            if (hasActiveFilters)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      )
          : null,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
          : LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth > 800;
          final contentWidth =
          constraints.maxWidth < 900 ? constraints.maxWidth : 900.0;
          return Row(
            children: [
              if (isWeb)
                Container(
                  width: 300,
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: OrderFilterWidget(
                    maxPrice: _maxPrice,
                    priceRange: _priceRange,
                    startDate: _startDate,
                    endDate: _endDate,
                    selectedCategory: _selectedCategory,
                    selectedBrand: _selectedBrand,
                    categories: _categories,
                    brands: _brands,
                    isDialog: false,
                    onPriceRangeChanged: (values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                    onStartDateChanged: (date) {
                      setState(() {
                        _startDate = date;
                      });
                    },
                    onEndDateChanged: (date) {
                      setState(() {
                        _endDate = date;
                      });
                    },
                    onCategoryChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    onBrandChanged: (value) {
                      setState(() {
                        _selectedBrand = value;
                      });
                    },
                    onApply: _applyFilters,
                    onReset: _clearFilters,
                  ),
                ),
              Expanded(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    padding: EdgeInsets.all(16),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOrderList(filteredOrders['all'] ?? []),
                        _buildOrderList(filteredOrders['pending'] ?? []),
                        _buildOrderList(filteredOrders['shipped'] ?? []),
                        _buildOrderList(filteredOrders['delivered'] ?? []),
                        _buildOrderList(filteredOrders['canceled'] ?? []),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab(String title, int count, IconData icon) {
    return Tab(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 120),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            SizedBox(width: 4),
            Flexible(
              child: Text(
                '$title ($count)',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Order> orders) {
    return orders.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 16),
          Text(
            'Không có đơn hàng nào',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Hãy đặt hàng để bắt đầu!',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    )
        : RefreshIndicator(
      onRefresh: _fetchOrders,
      child: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: OrderCard(order: order),
          );
        },
      ),
    );
  }
}
