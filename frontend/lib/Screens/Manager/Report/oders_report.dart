import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';

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

  Future<bool> _showExitConfirmation(BuildContext context) async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn quay lại?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Có'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
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
      height: 150,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
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
            Text("User: $user", style: const TextStyle(color: Colors.grey)),
            Text("Project: $project", style: const TextStyle(color: Colors.grey)),
            Text("Address: $address", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            const Text("Date: Just now", style: TextStyle(color: Colors.grey)),
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
              _buildTabButton("Day", 0),
              _buildTabButton("Week", 1),
              _buildTabButton("Month", 2),
            ],
          ),
          const SizedBox(height: 20),
          _buildChart(),
          const SizedBox(height: 20),
          const Text("Orders List", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                _buildTabButton("Day", 0),
                const SizedBox(width: 12),
                _buildTabButton("Week", 1),
                const SizedBox(width: 12),
                _buildTabButton("Month", 2),
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
        final shouldExit = await _showExitConfirmation(context);
        return shouldExit;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Orders", style: TextStyle(fontWeight: FontWeight.bold)),
          leading: (defaultTargetPlatform == TargetPlatform.android ||
                    defaultTargetPlatform == TargetPlatform.iOS)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    final shouldPop = await _showExitConfirmation(context);
                    if (shouldPop) {
                      Navigator.of(context).maybePop();
                    }
                  },
                )
              : const SizedBox(), // Ẩn trên Web/Desktop
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: widget.isMobile ? _buildMobileLayout() : _buildWebLayout(),
        bottomNavigationBar: widget.isMobile ? _buildBottomNavigationBar() : null,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {},
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.black54,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}