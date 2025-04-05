import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Projects extends StatelessWidget {
  const Projects({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: const ProjectsScreen(),
    );
  }
}

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () {},
        ),
        title: const Text("Projects", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildOverviewCards(),
            const SizedBox(height: 16),
            _buildProjectStatusChart(),
            const SizedBox(height: 16),
            _buildTaskList(),
            const SizedBox(height: 16),
            _buildTasksOverviewChart(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      children: [
        _overviewCard("Total Projects", "29", "+11.02%", Icons.folder, Colors.purple),
        _overviewCard("Total Tasks", "715", "-0.03%", Icons.list, Colors.black),
        _overviewCard("Members", "31", "+15.03%", Icons.people, Colors.black),
        _overviewCard("Productivity", "93.8%", "+6.08%", Icons.bar_chart, Colors.purple),
      ],
    );
  }

  Widget _overviewCard(String title, String value, String change, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(change, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
          Icon(icon, color: Colors.white, size: 30),
        ],
      ),
    );
  }

  Widget _buildProjectStatusChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Project Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(value: 67.6, title: "Completed", color: Colors.black),
                  PieChartSectionData(value: 26.4, title: "In Progress", color: Colors.green),
                  PieChartSectionData(value: 6.0, title: "Behind", color: Colors.purple),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    List<Map<String, dynamic>> tasks = [
      {"title": "Coffee detail page", "status": "In Progress", "color": Colors.purple},
      {"title": "Drinking bottle graphics", "status": "Complete", "color": Colors.green},
      {"title": "App design and development", "status": "Pending", "color": Colors.blue},
      {"title": "Poster illustration design", "status": "Approved", "color": Colors.orange},
      {"title": "App UI design", "status": "Rejected", "color": Colors.grey},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tasks", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
          const SizedBox(height: 10),
          ...tasks.map((task) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(task["title"]),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: task["color"].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  task["status"],
                  style: TextStyle(color: task["color"]),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTasksOverviewChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tasks Overview", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                barGroups: List.generate(
                  12,
                  (index) => BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: (index == 7) ? 26.598 : (10 + index * 2),
                        color: (index == 7) ? Colors.orange : Colors.grey,
                      ),
                    ],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                    return Text(["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][value.toInt()]);
                  })),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black,
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