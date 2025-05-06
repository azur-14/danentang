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

class WebDashboard extends StatelessWidget {
  const WebDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
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
          _drawerItem(context, 'Dashboard', Icons.dashboard, null),
          _drawerItem(context, 'Projects', Icons.work, Projects()),
          _drawerItem(context, 'Products', Icons.shopping_cart, ProductManagementScreen()),
          _drawerItem(context, 'Coupons', Icons.card_giftcard, CouponManagement()),
          _drawerItem(context, 'Categories', Icons.category, CategoriesManagement()),
          _drawerItem(context, 'Users', Icons.people, UserListScreen()),
          _drawerItem(context, 'Orders', Icons.receipt, OrdersListScreen()),
          _drawerItem(context, 'Support', Icons.support, CustomerSupportScreen()),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Handle logout logic here
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
      {"title": "Users", "value": "7,625", "color": Colors.purple, "percent": "+11.01%"},
      {"title": "Orders", "value": "10,000", "color": Colors.blue, "percent": "+12.5%"},
      {"title": "New Users", "value": "300", "color": Colors.purpleAccent, "percent": "+3.5%"},
      {"title": "Revenue", "value": "\$100,000", "color": Colors.green, "percent": "+8.9%"},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        double itemWidth = constraints.maxWidth < 600 ? constraints.maxWidth / 2 - 10 : constraints.maxWidth / 4 - 12;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: stats.map((stat) {
            return SizedBox(
              width: itemWidth,
              child: _statCard(stat),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _statCard(Map<String, dynamic> stat) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: stat['color'].withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stat['title'], style: TextStyle(color: stat['color'], fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(stat['value'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(stat['percent'], style: const TextStyle(color: Colors.black54)),
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
            switch (index) {
              case 0:
                return const LineChartUser(
                  spots: [FlSpot(0, 1), FlSpot(1, 3), FlSpot(2, 2), FlSpot(3, 5)],
                  lineColor: Colors.purple,
                );
              case 1:
                return const RevenueChartWidget(
                  spots: [FlSpot(0, 50), FlSpot(1, 55), FlSpot(2, 60), FlSpot(3, 62)],
                  lineColor: Colors.red,
                );
              case 2:
                return const OrdersChartWidget(
                  spots: [FlSpot(0, 30), FlSpot(1, 35), FlSpot(2, 50), FlSpot(3, 40)],
                  lineColor: Colors.blue,
                );
              case 3:
                return const BarChartWidget();
              case 4:
                return const PieChartCard();
              default:
                return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  Widget _buildManagementLinks(BuildContext context) {
    List<Map<String, dynamic>> managements = [
      {"title": "Projects Management", "screen": Projects()},
      {"title": "Product Management", "screen": ProductManagementScreen()},
      {"title": "Coupon Management", "screen": CouponManagement()},
      {"title": "Manage Categories", "screen": CategoriesManagement()},
      {"title": "User Management", "screen": UserListScreen()},
      {"title": "Orders Management", "screen": OrdersListScreen()},
      {"title": "Customer Support", "screen": CustomerSupportScreen()},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Quick Access", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...managements.map((item) {
          return Card(
            child: ListTile(
              title: Text(item["title"]),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => item["screen"]));
              },
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