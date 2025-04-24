import 'package:danentang/Screens/Manager/User/user_list.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';

class User_Report extends StatelessWidget {
  const User_Report({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const UserScreen(),
    );
  }
}

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String _selectedPeriod = "Month";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitConfirmation(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            "Users",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: (defaultTargetPlatform == TargetPlatform.android ||
                    defaultTargetPlatform == TargetPlatform.iOS)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () async {
                    bool shouldPop = await _showExitConfirmation(context);
                    if (shouldPop) {
                      Navigator.pop(context);
                    }
                  },
                )
              : const SizedBox(), // Không hiển thị nút back trên Web/Desktop
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSegmentedControl(),
              _buildLineChart(context),
              _buildDetailButton(context),  // Nút "Xem Chi Tiết"
              _buildUserSection(title: "New user", users: [
                {"name": "ByeWind", "date": "Jun 24, 2024", "avatar": "assets/Manager/Avartar/avatar01.jpg"},
                {"name": "Natali Craig", "date": "Mar 10, 2024", "avatar": "assets/Manager/Avatar/avatar02.jpg"},
                {"name": "Drew Cano", "date": "Nov 10, 2024", "avatar": "assets/Manager/Avatar/avatar03.jpg"},
                {"name": "Orlando Diggs", "date": "Dec 20, 2024", "avatar": "assets/Manager/Avatar/avatar04.jpg"},
                {"name": "Andi Lane", "date": "Jul 25, 2024", "avatar": "assets/Manager/Avatar/avatar05.jpg"},
              ]),
              _buildUserSection(title: "User List", users: [
                {"name": "ByeWind", "date": "Jun 24, 2024", "avatar": "assets/Manager/Avatar/avatar.jpg"},
              ]),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Xác nhận"),
            content: const Text("Bạn có muốn thoát khỏi màn hình này không?"),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Không")),
              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("Có")),
            ],
          ),
        ) ?? false;
  }

  Widget _buildSegmentedControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSegmentButton("Day"),
          _buildSegmentButton("Week"),
          _buildSegmentButton("Month"),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(String text) {
    bool isSelected = _selectedPeriod == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = text;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.black) : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Xây dựng biểu đồ Line Chart
  Widget _buildLineChart(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 180,
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
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                        if (value.toInt() >= 0 && value.toInt() < months.length) {
                          return Text(months[value.toInt()]);
                        } else {
                          return const Text('');
                        }
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
      ),
    );
  }

  // Xây dựng phần thông tin người dùng
  Widget _buildUserSection({required String title, required List<Map<String, String>> users}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (title == "New user") const Icon(Icons.keyboard_arrow_down),
            ],
          ),
          const SizedBox(height: 10),
          ...users.map((user) => _buildUserItem(user)).toList(),
        ],
      ),
    );
  }

  // Xây dựng một item người dùng
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
                Text(user["name"]!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(user["date"]!, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Xây dựng thanh điều hướng dưới cùng
  Widget _buildBottomNavigationBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return isMobile
            ? BottomNavigationBar(
                currentIndex: 0,
                onTap: (index) {},
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                  BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
                  BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
                  BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
                ],
                selectedItemColor: Colors.purple,
                unselectedItemColor: Colors.black54,
                type: BottomNavigationBarType.fixed,
              )
            : const SizedBox();
      },
    );
  }

  Widget _buildDetailButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserListScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          "Xem Chi Tiết",
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
