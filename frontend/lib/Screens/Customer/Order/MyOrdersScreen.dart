import 'package:flutter/material.dart';
import 'package:danentang/data/order_data.dart';
import 'package:danentang/models/Order.dart';
import 'package:go_router/go_router.dart';
import 'package:danentang/widgets/Order/OrderCard.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/widgets/Order/order_filter_widget.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late List<Product> products;
  late Map<String, List<Order>> filteredOrders;
  late Map<String, int> orderCounts;
  DateTime? _startDate;
  DateTime? _endDate;
  RangeValues _priceRange = const RangeValues(0, 10000000);
  String _searchQuery = '';
  double _maxPrice = 10000000;

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
            sortOrder: 1)
      ],
      variants: [
        ProductVariant(
            id: item.productVariantId ?? '',
            variantName: item.variantName,
            additionalPrice: 0,
            inventory: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now())
      ],
    ))
        .toSet()
        .toList();

    _maxPrice = testOrders.isNotEmpty
        ? testOrders
        .map((order) => (order.totalAmount ?? 0).toDouble())
        .reduce((a, b) => a > b ? a : b)
        : 10000000.0;
    _priceRange = RangeValues(0, _maxPrice);
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      List<Order> orders = testOrders.where((order) {
        bool passesDateFilter = true;
        if (_startDate != null) {
          passesDateFilter = order.createdAt.isAfter(_startDate!);
        }
        if (_endDate != null) {
          passesDateFilter =
              passesDateFilter && order.createdAt.isBefore(_endDate!);
        }

        bool passesPriceFilter = (order.totalAmount ?? 0) >= _priceRange.start &&
            (order.totalAmount ?? 0) <= _priceRange.end;

        bool passesSearchFilter = _searchQuery.isEmpty ||
            order.items.any((item) =>
                item.productName.toLowerCase().contains(_searchQuery.toLowerCase()));

        bool passesCategoryFilter = _selectedCategory == 'All' ||
            order.items.any((item) => item.productName.contains(_selectedCategory));

        bool passesBrandFilter = _selectedBrand == 'All' ||
            order.items.any((item) => item.productName.contains(_selectedBrand));

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
        order.status == 'Đặt hàng' || order.status == 'Đang chờ xử lý')
            .toList(),
        'shipped': orders.where((order) => order.status == 'Đang giao').toList(),
        'delivered':
        orders.where((order) => order.status == 'Đã giao').toList(),
        'canceled': orders.where((order) => order.status == 'Đã hủy').toList(),
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
            print('Attempting to pop two routes from MyOrdersScreen');
            print(
                'Current GoRouter stack: ${GoRouter.of(context).routerDelegate.currentConfiguration.routes}');
            if (context.canPop()) {
              print('Popping first route');
              context.pop();
              if (context.canPop()) {
                print('Popping second route');
                context.pop();
              } else {
                print('Only one route in stack, no second pop');
              }
            } else {
              print('No routes in stack, navigating to /homepage');
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
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), // Reduced padding
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true, // Make TabBar scrollable
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
                        fontSize: 14, // Reduced font size
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: 13, // Slightly smaller for unselected
                        fontWeight: FontWeight.w500,
                      ),
                      labelPadding: EdgeInsets.symmetric(horizontal: 12), // Reduced tab padding
                      tabs: [
                        _buildTab('Tất cả', orderCounts['all']!, Icons.all_inclusive),
                        _buildTab('Chờ xác nhận', orderCounts['pending']!, Icons.hourglass_empty),
                        _buildTab('Đang giao', orderCounts['shipped']!, Icons.local_shipping),
                        _buildTab('Đã giao', orderCounts['delivered']!, Icons.check_circle),
                        _buildTab('Đã hủy', orderCounts['canceled']!, Icons.cancel),
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
      body: LayoutBuilder(
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
                        _buildOrderList(filteredOrders['all']!),
                        _buildOrderList(filteredOrders['pending']!),
                        _buildOrderList(filteredOrders['shipped']!),
                        _buildOrderList(filteredOrders['delivered']!),
                        _buildOrderList(filteredOrders['canceled']!),
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
        constraints: BoxConstraints(maxWidth: 120), // Limit tab width
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16), // Reduced icon size
            SizedBox(width: 4), // Reduced spacing
            Flexible(
              child: Text(
                '$title ($count)',
                overflow: TextOverflow.ellipsis, // Handle long text
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
        : ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: OrderCard(order: order),
        );
      },
    );
  }
}