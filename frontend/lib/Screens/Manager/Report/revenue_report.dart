import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:danentang/Screens/Manager/DashBoard/MobileDashboard.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';

class RevenueReport extends StatelessWidget {
  const RevenueReport({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RevenueScreen(),
    );
  }
}

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> with SingleTickerProviderStateMixin {
  int selectedTab = 2; // Default is Month
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Scaffold(
          appBar: AppBar(
            leading: isMobile
                ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MobileDashboard()),
                );
              },
            )
                : null,
            title: const Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 1,
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterButtons(isMobile),
                  const SizedBox(height: 10),
                  _buildRevenueChart(isMobile),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Income',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  _buildIncomeList(),
                ],
              ),
            ),
          ),
          bottomNavigationBar: isMobile
              ? MobileNavigationBar(
            selectedIndex: 0,
            onItemTapped: (index) {
              print("Tapped item: $index");
            },
            isLoggedIn: true,
            role: 'manager',
          )
              : null,
        );
      },
    );
  }

  Widget _buildFilterButtons(bool isMobile) {
    List<String> labels = ['Day', 'Week', 'Month'];
    return Row(
      mainAxisAlignment: isMobile ? MainAxisAlignment.spaceAround : MainAxisAlignment.start,
      children: List.generate(
        labels.length,
            (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Text(labels[index]),
            selected: selectedTab == index,
            onSelected: (_) {
              setState(() => selectedTab = index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRevenueChart(bool isMobile) {
    final height = isMobile ? 220.0 : 160.0;
    final aspectRatio = isMobile ? 1.6 : 2.5;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SizedBox(
          height: height,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true, // Hiển thị các gridlines
                  drawVerticalLine: true, // Hiển thị các đường dọc
                  drawHorizontalLine: true, // Hiển thị các đường ngang
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey,
                      strokeWidth: 0.5,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey,
                      strokeWidth: 0.5,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
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
                borderData: FlBorderData(
                  show: true, // Hiển thị khung biên
                  border: Border.all(color: Colors.black, width: 1), // Đặt màu và độ dày của đường viền
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 50),
                      FlSpot(1, 55),
                      FlSpot(2, 60),
                      FlSpot(3, 62),
                    ],
                    isCurved: true,
                    color: Colors.redAccent,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.redAccent.withOpacity(0.1),
                    ),
                  ),
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 48),
                      FlSpot(1, 52),
                      FlSpot(2, 58),
                      FlSpot(3, 61),
                    ],
                    isCurved: true,
                    color: Colors.grey,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dashArray: [5, 5],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeList() {
    final incomeData = [
      {'name': 'Laptop ASUS', 'color': 'Grey, AA-07 - 902', 'price': 200.0, 'status': 'Paid'},
      {'name': 'Macbook Pro', 'color': 'Silver, M2 Chip', 'price': 1500.0, 'status': 'Pending'},
      {'name': 'iPhone 15', 'color': 'Black, 128GB', 'price': 1200.0, 'status': 'Paid'},
      {'name': 'AirPods Pro', 'color': 'White', 'price': 250.0, 'status': 'Paid'},
    ];

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: incomeData.length,
      itemBuilder: (context, index) {
        final item = incomeData[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.laptop_mac, color: Colors.black45),
            ),
            title: Text(
              item['name'].toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Color: ${item['color']}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$${item['price']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  item['status'].toString(),
                  style: TextStyle(
                    color: item['status'] == 'Paid' ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
