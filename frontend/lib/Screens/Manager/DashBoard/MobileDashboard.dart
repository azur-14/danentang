import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';
import 'package:danentang/Screens/Manager/User/user_list.dart';
import 'package:danentang/Screens/Manager/Product/product_management.dart';
import 'package:danentang/Screens/Manager/Coupon/coupon_management.dart';
import 'package:danentang/Screens/Manager/Category/categories_management.dart';
import 'package:danentang/Screens/Manager/Support/customer_support.dart';
import 'package:danentang/Screens/Manager/Order/order_list.dart';
import '../Chart/barchart.dart';
import '../Chart/linechartuser.dart';
import '../Chart/oderschart.dart';
import '../Chart/piechart.dart';
import '../Chart/revenuechart.dart';
import '../Report/user_report.dart';

class MobileDashboard extends StatefulWidget {
  const MobileDashboard({super.key});

  @override
  State<MobileDashboard> createState() => _MobileDashboardState();
}

class _MobileDashboardState extends State<MobileDashboard> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isLoggedIn = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animationController.forward();
    _checkLoginStatus();
    _loadNavIndex();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    setState(() {
      _isLoggedIn = token != null;
    });
    if (!_isLoggedIn) {
      context.go('/login');
    }
  }

  Future<void> _loadNavIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentIndex = prefs.getInt('nav_index') ?? 0;
    });
  }

  Future<void> _saveNavIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('nav_index', index);
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _saveNavIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          context.go('/manager'); // Giữ người dùng ở dashboard
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trang chủ', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.deepPurple),
                child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              _drawerItem('Quản lý Sản phẩm', '/manager/products'),
              _drawerItem('Quản lý Mã giảm giá', '/manager/coupons'),
              _drawerItem('Quản lý Danh mục', '/manager/categories'),
              _drawerItem('Quản lý Người dùng', '/manager/users'),
              _drawerItem('Quản lý Đơn hàng', '/manager/orders'),
              _drawerItem('Hỗ trợ người dùng', '/manager/support'),
            ],
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              _buildStatCards(),
              LineChartUser(
                spots: const [
                  FlSpot(0, 1),
                  FlSpot(1, 3),
                  FlSpot(2, 2),
                  FlSpot(3, 5),
                  FlSpot(4, 4),
                  FlSpot(5, 6),
                  FlSpot(3, 5),
                  FlSpot(4, 7),
                  FlSpot(8, 5),
                  FlSpot(9, 2),
                  FlSpot(7, 1),
                  FlSpot(9, 7),
                ],
                lineColor: Colors.purple,
              ),
              RevenueChartWidget(
                spots: const [
                  FlSpot(0, 50),
                  FlSpot(1, 55),
                  FlSpot(2, 60),
                  FlSpot(3, 62),
                ],
                lineColor: Colors.red,
              ),
              OrdersChartWidget(
                spots: const [
                  FlSpot(0, 30),
                  FlSpot(1, 35),
                  FlSpot(2, 50),
                  FlSpot(3, 40),
                ],
                lineColor: Colors.blue,
              ),
              BarChartWidget(),
              AnimatedPieChart(),
              _buildManagementSections(context),
            ],
          ),
        ),
        bottomNavigationBar: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return MobileNavigationBar(
                selectedIndex: _currentIndex,
                onItemTapped: _onNavBarTapped,
                isLoggedIn: _isLoggedIn,
                role: 'admin', // Đồng bộ với vai trò "admin"
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  Widget _drawerItem(String title, String path) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        context.go(path); // Sử dụng GoRouter thay vì Navigator.push
        Navigator.pop(context); // Đóng drawer
      },
    );
  }

  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.start,
        children: [
          _statCard("Người dùng", "7,625", Colors.purple, "+11.01%"),
          _statCard("Đơn hàng", "10,000", Colors.blue, "+11.01%"),
          _statCard("Người dùng mới", "300", Colors.purpleAccent, "+11.01%"),
          _statCard("Doanh thu", "\$100,000", Colors.deepPurple.shade100, "+11.01%"),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color, String percentage) {
    final Color backgroundColor = Color.alphaBlend(color.withOpacity(0.15), Colors.white);
    final Color trendColor = percentage.contains('+') ? Colors.green[700]! : Colors.red[700]!;

    return Container(
      width: MediaQuery.of(context).size.width / 2 - 24,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.trending_up, size: 16, color: trendColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            percentage,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: trendColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementSections(BuildContext context) {
    List<Map<String, dynamic>> managements = [
      {"title": "Quản lý Sản phẩm", "path": "/manager/products"},
      {"title": "Quản lý Mã giảm giá", "path": "/manager/coupons"},
      {"title": "Quản lý Danh mục", "path": "/manager/categories"},
      {"title": "Quản lý Người dùng", "path": "/manager/users"},
      {"title": "Quản lý Đơn hàng", "path": "/manager/orders"},
      {"title": "Hỗ trợ người dùng", "path": "/manager/support"},
    ];

    return Column(
      children: managements.map((item) {
        return Card(
          child: ListTile(
            title: Text(item["title"]),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.go(item["path"]); // Sử dụng GoRouter
            },
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _animationController.dispose(); // Giải phóng AnimationController
    super.dispose();
  }
}