import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';
import '../User/user_list.dart';

class UserReportScreen extends StatefulWidget {
  const UserReportScreen({super.key});

  @override
  State<UserReportScreen> createState() => _UserReportScreenState();
}

class _UserReportScreenState extends State<UserReportScreen>
    with SingleTickerProviderStateMixin {
  String _selectedPeriod = "Tháng";
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<FlSpot> _spots = [
    FlSpot(1, 2),
    FlSpot(2, 4),
    FlSpot(3, 3),
    FlSpot(4, 6),
    FlSpot(5, 5),
    FlSpot(6, 7),
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<FlSpot> _animatedSpots() {
    final int currentIndex = (_spots.length * _animation.value).toInt();
    return _spots.take(currentIndex.clamp(1, _spots.length)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Báo cáo Người dùng",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        )
            : const SizedBox(),
      ),
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSegmentedControl(),
                _buildLineChart(),
                _buildDetailButton(context),
                _buildUserSection(title: "Người dùng mới", users: [
                  {
                    "name": "ByeWind",
                    "date": "Jun 24, 2024",
                    "avatar": "assets/Manager/Avatar/avatar01.jpg"
                  },
                  {
                    "name": "Natali Craig",
                    "date": "Mar 10, 2024",
                    "avatar": "assets/Manager/Avatar/avatar02.jpg"
                  },
                  {
                    "name": "Drew Cano",
                    "date": "Nov 10, 2024",
                    "avatar": "assets/Manager/Avatar/avatar03.jpg"
                  },
                  {
                    "name": "Orlando Diggs",
                    "date": "Dec 20, 2024",
                    "avatar": "assets/Manager/Avatar/avatar04.jpg"
                  },
                  {
                    "name": "Andi Lane",
                    "date": "Jul 25, 2024",
                    "avatar": "assets/Manager/Avatar/avatar05.jpg"
                  },
                ]),
                _buildUserSection(title: "Danh sách người dùng", users: [
                  {
                    "name": "ByeWind",
                    "date": "Jun 24, 2024",
                    "avatar": "assets/Manager/Avatar/avatar.jpg"
                  },
                ]),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)
          ? MobileNavigationBar(
        selectedIndex: 0,
        onItemTapped: (index) {},
        isLoggedIn: true,
        role: 'manager',
      )
          : null,
    );
  }

  Widget _buildSegmentedControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ["Ngày", "Tuần", "Tháng"]
            .map((label) => _buildSegmentButton(label))
            .toList(),
      ),
    );
  }

  Widget _buildSegmentButton(String text) {
    final bool isSelected = _selectedPeriod == text;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = text),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.black) : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child:
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLineChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double chartHeight = constraints.maxWidth > 600 ? 300 : 250;
            return SizedBox(
              height: chartHeight,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, interval: 2),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value >= 1 && value <= 12) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                              child: Text(
                                '${value.toInt()}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _animatedSpots(),
                      isCurved: true,
                      color: Colors.purple,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.withOpacity(0.3),
                            Colors.purple.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserSection(
      {required String title, required List<Map<String, String>> users}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          ...users.map(_buildUserItem).toList(),
        ],
      ),
    );
  }

  Widget _buildUserItem(Map<String, String> user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(user["avatar"]!),
            radius: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user["name"]!,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(user["date"]!,
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserListScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
          ),
          child: const Text(
            "Xem Chi Tiết",
            style: TextStyle(
              fontSize: 16,
              color: Colors.purple,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}