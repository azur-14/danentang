import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../Chart/piechart.dart';
import '../Chart/linechartuser.dart';
import '../Chart/revenuechart.dart';
import '../Chart/oderschart.dart';
import '../Chart/barchart.dart';

import 'package:danentang/Screens/Manager/User/user_list.dart';
import 'package:danentang/Screens/Manager/Project/projects.dart';
import 'package:danentang/Screens/Manager/Product/product_management.dart';
import 'package:danentang/Screens/Manager/Coupon/coupon_management.dart';
import 'package:danentang/Screens/Manager/Category/categories_management.dart';
import 'package:danentang/Screens/Manager/Support/customer_support.dart';
import 'package:danentang/Screens/Manager/Order/order_list.dart';

class WebDashboard extends StatefulWidget {
  const WebDashboard({super.key});

  @override
  State<WebDashboard> createState() => _WebDashboardState();
}

class _WebDashboardState extends State<WebDashboard> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _opacityAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text(
          'Trang chủ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: FadeTransition(
        opacity: _opacityAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatCards(context),
                const SizedBox(height: 20),
                _buildChartsGrid(),
                const SizedBox(height: 20),
                _buildManagementLinks(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Text('Admin Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          _drawerItem(context, 'Trang chủ', Icons.dashboard, null),
          _drawerItem(context, 'Quản lý Dự án', Icons.work, Projects()),
          _drawerItem(context, 'Quản lý Sản phẩm', Icons.shopping_cart, ProductManagementScreen()),
          _drawerItem(context, 'Quản lý Mã giảm giá', Icons.card_giftcard, CouponManagement()),
          _drawerItem(context, 'Quản lý Danh mục', Icons.category, CategoriesManagement()),
          _drawerItem(context, 'Quản lý Người dùng', Icons.people, UserListScreen()),
          _drawerItem(context, 'Quản lý Đơn hàng', Icons.receipt, OrderListScreen()),
          _drawerItem(context, 'Hỗ trợ người dùng', Icons.support, CustomerSupportScreen()),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Đăng xuất'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(BuildContext context, String title, IconData icon, Widget? screen) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (screen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        }
      },
    );
  }

  Widget _buildStatCards(BuildContext context) {
    List<Map<String, dynamic>> stats = [
      {"title": "Người dùng", "value": "7,625", "color": Colors.red, "percent": "+11.01%"},
      {"title": "Đơn hàng", "value": "10,000", "color": Colors.blue, "percent": "+12.5%"},
      {"title": "Người dùng mới", "value": "300", "color": Colors.purpleAccent, "percent": "+3.5%"},
      {"title": "Doanh thu", "value": "\$100,000", "color": Colors.green, "percent": "+8.9%"},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        double itemWidth = constraints.maxWidth < 600 ? constraints.maxWidth / 2 - 10 : constraints.maxWidth / 4 - 12;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: stats.map((stat) {
            return AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: SizedBox(
                    width: itemWidth,
                    child: _statCard(stat),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _statCard(Map<String, dynamic> stat) {
    final Color bgColor = Color.alphaBlend(stat['color'].withOpacity(0.15), Colors.white);
    final Color textColor = Colors.black87;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: bgColor,
      shadowColor: stat['color'].withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stat['title'],
              style: TextStyle(
                color: stat['color'],
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              stat['value'],
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              stat['percent'],
              style: TextStyle(
                color: stat['percent'].contains('+') ? Colors.green[700] : Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600 ? 1 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: 5,
          itemBuilder: (context, index) {
            Widget child;
            switch (index) {
              case 0:
                child = const LineChartUser(
                  spots: [FlSpot(0, 1), FlSpot(1, 3), FlSpot(2, 2), FlSpot(3, 5)],
                  lineColor: Colors.purple,
                );
                break;
              case 1:
                child = const RevenueChartWidget(
                  spots: [FlSpot(0, 50), FlSpot(1, 55), FlSpot(2, 60), FlSpot(3, 62)],
                  lineColor: Colors.red,
                );
                break;
              case 2:
                child = const OrdersChartWidget(
                  spots: [FlSpot(0, 30), FlSpot(1, 35), FlSpot(2, 50), FlSpot(3, 40)],
                  lineColor: Colors.blue,
                );
                break;
              case 3:
                child = const BarChartWidget();
                break;
              case 4:
              default:
                child = const PieChartCard();
            }
            return AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, _) => Opacity(
                opacity: _opacityAnimation.value,
                child: child,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildManagementLinks(BuildContext context) {
    List<Map<String, dynamic>> managements = [
      {"title": "Quản lý Dự án", "screen": Projects()},
      {"title": "Quản lý Sản phẩm", "screen": ProductManagementScreen()},
      {"title": "Quản lý Mã giảm giá", "screen": CouponManagement()},
      {"title": "Quản lý Danh mục", "screen": CategoriesManagement()},
      {"title": "Quản lý Người dùng", "screen": UserListScreen()},
      {"title": "Quản lý Đơn hàng", "screen": OrderListScreen()},
      {"title": "Hỗ trợ người dùng", "screen": CustomerSupportScreen()},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Lối tắt", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...managements.map((item) {
          return AnimatedBuilder(
            animation: _opacityAnimation,
            builder: (context, _) => Opacity(
              opacity: _opacityAnimation.value,
              child: Card(
                child: ListTile(
                  title: Text(item["title"]),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => item["screen"]));
                  },
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

class PieChartCard extends StatelessWidget {
  const PieChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(height: 10),
        Expanded(
          child: AnimatedPieChart(),
        ),
      ],
    );
  }
}