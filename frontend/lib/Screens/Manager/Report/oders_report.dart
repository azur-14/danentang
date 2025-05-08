import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';

class OrdersReport extends StatelessWidget {
  const OrdersReport({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ResponsiveOrdersScreen(),
    );
  }
}

class ResponsiveOrdersScreen extends StatelessWidget {
  const ResponsiveOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android;
        return OrdersScreen(isMobile: isMobile);
      },
    );
  }
}

class OrdersScreen extends StatefulWidget {
  final bool isMobile;
  const OrdersScreen({super.key, required this.isMobile});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with SingleTickerProviderStateMixin {
  int selectedTab = 2;
  int _currentIndex = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildTabButton(String text, int index) {
    bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
          _controller.forward(from: 0);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.purple : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, horizontalInterval: 1, verticalInterval: 1),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 32),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 32),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 32),
            ),
          ),
          borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey, width: 1)),
          lineBarsData: [
            LineChartBarData(
              spots: [FlSpot(1, 3), FlSpot(2, 1), FlSpot(3, 4), FlSpot(4, 2)],
              isCurved: true,
              color: Colors.blue,
              dotData: FlDotData(show: false),
            ),
            LineChartBarData(
              spots: [FlSpot(1, 2), FlSpot(2, 4), FlSpot(3, 1), FlSpot(4, 3)],
              isCurved: true,
              color: Colors.green,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(String id, String user, String project, String address, String status, Color statusColor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(id, style: const TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(status, style: TextStyle(color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("Người dùng $user", style: const TextStyle(color: Colors.grey)),
            Text("Dự án: $project", style: const TextStyle(color: Colors.grey)),
            Text("Địa chỉ: $address", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            const Text("Ngày: Bây giờ", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTabButton("Ngày", 0),
              _buildTabButton("Tuần", 1),
              _buildTabButton("Tháng", 2),
            ],
          ),
          const SizedBox(height: 20),
          _buildChart(),
          const SizedBox(height: 20),
          const Text("Danh sách Đơn hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildOrderCard("#CM9801", "Natali Craig", "Landing Page", "Meadow Lane Oakland", "In Progress", Colors.purpleAccent),
          _buildOrderCard("#CM9802", "Kate Morrison", "CRM Admin pages", "Larry San Francisco", "Complete", Colors.green),
        ],
      ),
    );
  }

  Widget _buildWebLayout() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                _buildTabButton("Ngày", 0),
                const SizedBox(width: 12),
                _buildTabButton("Tuần", 1),
                const SizedBox(width: 12),
                _buildTabButton("Tháng", 2),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildChart()),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      _buildOrderCard("#CM9801", "Natali Craig", "Landing Page", "Meadow Lane Oakland", "In Progress", Colors.purpleAccent),
                      _buildOrderCard("#CM9802", "Kate Morrison", "CRM Admin pages", "Larry San Francisco", "Complete", Colors.green),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Đơn hàng", style: TextStyle(fontWeight: FontWeight.bold)),
          leading: (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)
              ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Preventing back press
            },
          )
              : const SizedBox(),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: widget.isMobile ? _buildMobileLayout() : _buildWebLayout(),
        bottomNavigationBar: widget.isMobile
            ? MobileNavigationBar(
          selectedIndex: _currentIndex,
          onItemTapped: _onItemTapped,
          isLoggedIn: true,
          role: 'manager',
        )
            : null,
      ),
    );
  }
}