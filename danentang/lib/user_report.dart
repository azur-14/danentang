import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class User_Report extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UserScreen(),
    );
  }
}

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldPop = await _showExitConfirmation(context);
        return shouldPop;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Users", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSegmentedControl(),
            _buildLineChart(),
            _buildUserSection(title: "New user", users: [
              {"name": "ByeWind", "date": "Jun 24, 2024", "avatar": "assets/avatar1.png"},
              {"name": "Natali Craig", "date": "Mar 10, 2024", "avatar": "assets/avatar2.png"},
              {"name": "Drew Cano", "date": "Nov 10, 2024", "avatar": "assets/avatar3.png"},
              {"name": "Orlando Diggs", "date": "Dec 20, 2024", "avatar": "assets/avatar4.png"},
              {"name": "Andi Lane", "date": "Jul 25, 2024", "avatar": "assets/avatar5.png"},
            ]),
            _buildUserSection(title: "User List", users: [
              {"name": "ByeWind", "date": "Jun 24, 2024", "avatar": "assets/avatar1.png"},
            ]),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Xác nhận"),
        content: Text("Bạn có muốn thoát khỏi màn hình này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Không"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Có"),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget _buildSegmentedControl() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSegmentButton("Day", isSelected: false),
          _buildSegmentButton("Week", isSelected: false),
          _buildSegmentButton("Month", isSelected: true),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String text, {bool isSelected = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? Border.all(color: Colors.black) : null,
      ),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold)),
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
        padding: EdgeInsets.all(16),
        child: Stack(
          children: [
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: () {
                  // Chuyển đến màn hình chi tiết
                  print("Chuyển đến trang UserScreen");
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
        ),
      ),
    );
  }

  Widget _buildUserSection({required String title, required List<Map<String, String>> users}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (title == "New user") Icon(Icons.keyboard_arrow_down),
            ],
          ),
          SizedBox(height: 8),
          ...users.map((user) => _buildUserItem(user)).toList(),
        ],
      ),
    );
  }

  Widget _buildUserItem(Map<String, String> user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(user["avatar"]!),
            radius: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(user["name"]!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Text(user["date"]!, style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {},
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home, color: Colors.purple), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.history, color: Colors.black54), label: "History"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications, color: Colors.black54), label: "Notifications"),
        BottomNavigationBarItem(icon: Icon(Icons.settings, color: Colors.black54), label: "Settings"),
        BottomNavigationBarItem(icon: Icon(Icons.person, color: Colors.black54), label: "Profile"),
      ],
    );
  }
}