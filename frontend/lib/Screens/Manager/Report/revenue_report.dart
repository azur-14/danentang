import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitConfirmation(context);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold)),
              centerTitle: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 1,
            ),
            body: FadeTransition(
              opacity: _controller,
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
            bottomNavigationBar: isMobile ? _buildBottomNavigationBar() : null,
          );
        },
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
        ) ??
        false;
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

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (index) {},
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.black54,
      type: BottomNavigationBarType.fixed,
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