import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:manager/categories_management.dart';
import 'package:manager/coupon_management.dart';
import 'package:manager/customer_support.dart';
import 'package:manager/order_list.dart';
import 'package:manager/product_management.dart';
import 'package:manager/projects.dart';
import 'package:manager/user_list.dart';
import 'package:manager/user_report.dart';

class DashBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatCards(),
            _buildCard('Users', _buildLineChartUsers(context)),
            _buildCard('Revenue', _buildRevenueChart()),
            _buildCard('Orders', _buildOrdersChart()),
            _buildCard('Best-Selling Products', _buildBarChart()),
            _buildCard('Total Sales', _buildPieChart()),
            _buildManagementSections(context),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statCard("Users", "7,625", Colors.purple, "+11.01%"),
            _statCard("Orders", "10,000", Colors.blue, "+11.01%"),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statCard("New Users", "300", Colors.purpleAccent, "+11.01%"),
            _statCard("Revenue", "\$100,000", Colors.deepPurple.shade100, "+11.01%"),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, Color color, String percentage) {
    return Container(
      width: 160,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(Icons.trending_up, size: 16, color: Colors.black),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(percentage, style: TextStyle(fontSize: 14, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildCard(String title, Widget chart) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChartUsers(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                      return value.toInt() < months.length ? Text(months[value.toInt()]) : Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [
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
                  belowBarData: BarAreaData(show: false),
                  dotData: FlDotData(show: true),
                )
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserScreen()),
              );
            },
            child: Text(
              "Xem Chi Tiết",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, 
              getTitlesWidget: (value, meta) {
                List<String> months = ['Jan', 'Feb', 'Mar', 'Apr'];
                return value.toInt() < months.length ? Text(months[value.toInt()]) : Text('');
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [FlSpot(0, 50), FlSpot(1, 55), FlSpot(2, 60), FlSpot(3, 62)],
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
          LineChartBarData(
            spots: [FlSpot(0, 48), FlSpot(1, 52), FlSpot(2, 58), FlSpot(3, 61)],
            isCurved: true,
            color: Colors.grey,
            barWidth: 2,
            dashArray: [5, 5],
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersChart() {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: [FlSpot(0, 30), FlSpot(1, 35), FlSpot(2, 50), FlSpot(3, 40)],
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(fromY: 0, toY: 20, color: Colors.grey)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(fromY: 0, toY: 30, color: Colors.grey)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(fromY: 0, toY: 25, color: Colors.grey)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(fromY: 0, toY: 28, color: Colors.grey)]),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: 30, color: Colors.green, title: 'Direct'),
          PieChartSectionData(value: 20, color: Colors.blue, title: 'Affiliate'),
          PieChartSectionData(value: 15, color: Colors.orange, title: 'Sponsored'),
          PieChartSectionData(value: 10, color: Colors.yellow, title: 'Email'),
        ],
      ),
    );
  }

  Widget _buildManagementSections(BuildContext context) {
    List<Map<String, dynamic>> managements = [
      {"title": "Projects Management", "screen": ProjectsScreen()},
      {"title": "Product Management", "screen": ProductManagementScreen()},
      {"title": "Coupon Management", "screen": CouponManagementScreen()},
      {"title": "Manage Categories", "screen": CategoriesScreen()},
      {"title": "User Management", "screen": UserListScreen()},
      {"title": "Orders Management", "screen": OrdersListScreen()},
      {"title": "Customer Support", "screen": CustomerSupportScreen()},
    ];

    return Column(
      children: managements.map((item) => Card(
        child: ListTile(
          title: Text(item["title"]),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () {
            if (item["screen"] != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => item["screen"]),
              );
            }
          },
        ),
      )).toList(),
    );
  }
}