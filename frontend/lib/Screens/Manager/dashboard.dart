import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../widgets/Footer/mobile_navigation_bar.dart';
import 'package:danentang/Screens/Manager/User/user_list.dart';
import 'package:danentang/Screens/Manager/Report/revenue_report.dart';
import 'package:danentang/Screens/Manager/Report/oders_report.dart';
import 'package:danentang/Screens/Manager/Report/user_report.dart';
import 'package:danentang/Screens/Manager/Project/projects.dart';
import 'package:danentang/Screens/Manager/Product/product_management.dart';
import 'package:danentang/Screens/Manager/Coupon/coupon_management.dart';
import 'package:danentang/Screens/Manager/Category/categories_management.dart';
import 'package:danentang/Screens/Manager/Support/customer_support.dart';
import 'package:danentang/Screens/Manager/Order/order_list.dart';

class DashBoard extends StatefulWidget {
  const DashBoard({super.key});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  int _currentIndex = 0;
  bool _isLoggedIn = true;

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
            _buildChartCard('Users Report', _buildLineChartUsers(context)),
            _buildChartCard('Revenue Report', _buildRevenueChart(context)),
            _buildChartCard('Orders Report', _buildOrdersChart(context)),
            _buildChartCard('Best-Selling Products Report', _buildBarChart()),
            _buildChartCard('Total Sales Report', _buildPieChart()),
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

  Widget _buildLineChartUsers(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1),
                      FlSpot(1, 3),
                      FlSpot(2, 2),
                      FlSpot(3, 5),
                      FlSpot(4, 4),
                      FlSpot(5, 6),
                    ],
                    isCurved: true,
                    color: Colors.purple,
                    barWidth: 3,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const UserScreen()));
              },
              child: const Text("Xem chi tiết", style: TextStyle(color: Colors.deepPurple)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 50),
                      FlSpot(1, 55),
                      FlSpot(2, 60),
                      FlSpot(3, 62),
                    ],
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => RevenueReport()));
              },
              child: const Text("Xem chi tiết", style: TextStyle(color: Colors.deepPurple)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersChart(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 30),
                      FlSpot(1, 35),
                      FlSpot(2, 50),
                      FlSpot(3, 40),
                    ],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => OrdersReport()));
              },
              child: const Text("Xem chi tiết", style: TextStyle(color: Colors.deepPurple)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(fromY: 0, toY: 20, color: Colors.grey)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(fromY: 0, toY: 30, color: Colors.grey)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(fromY: 0, toY: 25, color: Colors.grey)]),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(value: 30, color: Colors.green, title: 'Direct'),
            PieChartSectionData(value: 20, color: Colors.blue, title: 'Affiliate'),
            PieChartSectionData(value: 15, color: Colors.orange, title: 'Sponsored'),
            PieChartSectionData(value: 10, color: Colors.yellow, title: 'Email'),
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