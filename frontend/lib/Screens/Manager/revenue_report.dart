import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Revenue_Report extends StatelessWidget {
  const Revenue_Report({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RevenueScreen(),
    );
  }
}

class RevenueScreen extends StatelessWidget {
  const RevenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Revenue', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterButtons(),
          _buildRevenueChart(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Income', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(child: _buildIncomeList()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildFilterButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFilterButton('Day'),
          _buildFilterButton('Week'),
          _buildFilterButton('Month', isSelected: true),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, {bool isSelected = false}) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.grey[300] : Colors.white,
      ),
      child: Text(text, style: TextStyle(color: Colors.black)),
    );
  }

  Widget _buildRevenueChart() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AspectRatio(
        aspectRatio: 1.5,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [FlSpot(0, 50), FlSpot(1, 55), FlSpot(2, 60), FlSpot(3, 62)],
                isCurved: true,
                color: Colors.red,
                barWidth: 3,
              ),
              LineChartBarData(
                spots: [FlSpot(0, 48), FlSpot(1, 52), FlSpot(2, 58), FlSpot(3, 61)],
                isCurved: true,
                color: Colors.grey,
                barWidth: 2,
                dashArray: [5, 5],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeList() {
    List<Map<String, dynamic>> incomeData = [
      {'name': 'Laptop ASUS', 'color': 'Grey, AA-07 - 902', 'price': 200.0, 'status': 'Paid'},
      {'name': 'Laptop ASUS', 'color': 'Grey, AA-07 - 902', 'price': 200.0, 'status': 'Pending'},
      {'name': 'Laptop ASUS', 'color': 'Grey, AA-07 - 902', 'price': 200.0, 'status': 'Paid'},
      {'name': 'Laptop ASUS', 'color': 'Grey, AA-07 - 902', 'price': 200.0, 'status': 'Paid'},
    ];

    return ListView.builder(
      itemCount: incomeData.length,
      itemBuilder: (context, index) {
        var item = incomeData[index];
        return ListTile(
          leading: Container(width: 50, height: 50, color: Colors.grey[300]),
          title: Text(item['name'], style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Color: ${item['color']}'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('\$${item['price']}', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                item['status'],
                style: TextStyle(color: item['status'] == 'Paid' ? Colors.green : Colors.orange),
              ),
            ],
          ),
        );
      },
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