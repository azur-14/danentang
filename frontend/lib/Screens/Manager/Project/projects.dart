import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';

class Projects extends StatelessWidget {
  const Projects({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveProjectsScreen();
  }
}

class ResponsiveProjectsScreen extends StatelessWidget {
  const ResponsiveProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 600;
        final bool isMobilePlatform = defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS;
        final bool showBackButton = !kIsWeb && isMobile && isMobilePlatform;

        return ProjectsScreen(
          isMobile: isMobile,
          showBackButton: showBackButton,
        );
      },
    );
  }
}

class ProjectsScreen extends StatefulWidget {
  final bool isMobile;
  final bool showBackButton;

  const ProjectsScreen({
    super.key,
    required this.isMobile,
    required this.showBackButton,
  });

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final _cards = const [
    {"title": "Total Projects", "value": "29", "change": "+11.02%", "icon": Icons.folder, "color": Colors.purple},
    {"title": "Total Tasks", "value": "715", "change": "-0.03%", "icon": Icons.list, "color": Colors.black},
    {"title": "Members", "value": "31", "change": "+15.03%", "icon": Icons.people, "color": Colors.black},
    {"title": "Productivity", "value": "93.8%", "change": "+6.08%", "icon": Icons.bar_chart, "color": Colors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: widget.showBackButton,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Projects",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildOverviewCards(widget.isMobile ? 2 : 4),
                  const SizedBox(height: 16),
                  widget.isMobile
                      ? Column(
                    children: [
                      _buildProjectStatusChart(),
                      const SizedBox(height: 16),
                      _buildTaskList(),
                      const SizedBox(height: 16),
                      _buildTasksOverviewChart(),
                    ],
                  )
                      : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildProjectStatusChart()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTasksOverviewChart()),
                    ],
                  ),
                  if (!widget.isMobile) ...[
                    const SizedBox(height: 16),
                    _buildTaskList(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: (widget.isMobile && !kIsWeb)
          ? MobileNavigationBar(
        selectedIndex: 2,
        onItemTapped: (index) {
          // TODO: xử lý khi user đổi tab
        },
        isLoggedIn: true,
        role: 'manager',
      )
          : null,
    );
  }

  Widget _buildOverviewCards(int crossAxisCount) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 8.0;
        final cardWidth = (constraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _cards.map((item) {
            return SizedBox(
              width: cardWidth,
              child: _overviewCard(
                item["title"] as String,
                item["value"] as String,
                item["change"] as String,
                item["icon"] as IconData,
                item["color"] as Color,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _overviewCard(String title, String value, String change, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(change, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
          Icon(icon, color: Colors.white, size: 30),
        ],
      ),
    );
  }

  Widget _buildProjectStatusChart() => _chartContainer(
    title: "Project Status",
    titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    child: AspectRatio(
      aspectRatio: 1.2,
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
  );

  Widget _buildTaskList() {
    final tasks = [
      {"title": "Coffee detail page", "status": "In Progress", "color": Colors.purple},
      {"title": "Drinking bottle graphics", "status": "Complete", "color": Colors.green},
      {"title": "App design and development", "status": "Pending", "color": Colors.blue},
      {"title": "Poster illustration design", "status": "Approved", "color": Colors.orange},
      {"title": "App UI design", "status": "Rejected", "color": Colors.grey},
    ];

    return _chartContainer(
      title: "Tasks",
      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
      child: Column(
        children: tasks.map((task) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(task["title"] as String, style: const TextStyle(fontSize: 14))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (task["color"] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(task["status"] as String, style: TextStyle(color: task["color"] as Color)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTasksOverviewChart() => _chartContainer(
    title: "Tasks Overview",
    titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
    child: AspectRatio(
      aspectRatio: 1.5,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 30,
          barGroups: List.generate(12, (i) {
            final toY = i == 7 ? 26.6 : (10 + i * 2);
            final color = i == 7 ? Colors.orange : Colors.grey;

            final validToY = toY <= 30 ? toY.toDouble() : 30.0;

            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(toY: validToY, color: color),
              ],
            );
          }),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                  final idx = value.toInt();
                  return (idx >= 0 && idx < months.length)
                      ? Text(months[idx], style: const TextStyle(fontSize: 10))
                      : const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
        ),
      ),
    ),
  );

  Widget _chartContainer({
    required String title,
    required TextStyle titleStyle,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
