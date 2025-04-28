import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/Footer/mobile_navigation_bar.dart';
import 'package:danentang/Screens/Manager/User/user_list.dart';

import 'package:danentang/Screens/Manager/Project/projects.dart';
import 'package:danentang/Screens/Manager/Product/product_management.dart';
import 'package:danentang/Screens/Manager/Coupon/coupon_management.dart';
import 'package:danentang/Screens/Manager/Category/categories_management.dart';
import 'package:danentang/Screens/Manager/Support/customer_support.dart';
import 'package:danentang/Screens/Manager/Order/order_list.dart';

import 'Chart/barchart.dart';
import 'Chart/linechartuser.dart';
import 'Chart/oderschart.dart';
import 'Chart/piechart.dart';
import 'Chart/revenuechart.dart';
import 'Report/user_report.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isLoggedIn = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            _buildStatCards(),
            LineChartUser(spots: const [
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
            RevenueChartWidget(spots: const [
              FlSpot(0, 50),
              FlSpot(1, 55),
              FlSpot(2, 60),
              FlSpot(3, 62),
            ],
              lineColor: Colors.red,
            ),
            OrdersChartWidget(spots: const [
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
              role: 'manager',
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
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
          _statCard("Users", "7,625", Colors.purple, "+11.01%"),
          _statCard("Orders", "10,000", Colors.blue, "+11.01%"),
          _statCard("New Users", "300", Colors.purpleAccent, "+11.01%"),
          _statCard("Revenue", "\$100,000", Colors.deepPurple.shade100, "+11.01%"),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color, String percentage) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 24,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Icon(Icons.trending_up, size: 16, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(percentage, style: const TextStyle(fontSize: 14, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            chart,
          ],
        ),
      ),
    );
  }

  Widget _buildManagementSections(BuildContext context) {
    List<Map<String, dynamic>> managements = [
      {"title": "Projects Management", "screen": Projects()},
      {"title": "Product Management", "screen": ProductManagementScreen()},
      {"title": "Coupon Management", "screen": CouponManagement()},
      {"title": "Manage Categories", "screen": Categories_Management()},
      {"title": "User Management", "screen": UserListScreen()},
      {"title": "Orders Management", "screen": OrdersListScreen()},
      {"title": "Customer Support", "screen": CustomerSupportScreen()},
    ];

    return Column(
      children: managements.map((item) {
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
    );
  }
}