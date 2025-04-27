import 'package:danentang/Screens/Manager/User/user_list.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';  // Thêm import cho MobileNavigationBar

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

  // Animation Variables
  double _opacity = 0.0;
  double _scale = 0.8;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1.0;
        _scale = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Users",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Không cần hỏi xác nhận khi quay lại
          },
        )
            : const SizedBox(),
      ),
      body: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 500),
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 500),
          child: SingleChildScrollView(
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
        ),
      ),
      bottomNavigationBar: MobileNavigationBar(
        selectedIndex: 0,  // Chỉnh lại chỉ mục được chọn nếu cần
        onItemTapped: (index) {},  // Xử lý khi người dùng nhấn vào một item
        isLoggedIn: true,  // Cập nhật trạng thái đăng nhập nếu cần
      ),
    );
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

  // Nút "Xem Chi Tiết"
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
          style: TextStyle(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
