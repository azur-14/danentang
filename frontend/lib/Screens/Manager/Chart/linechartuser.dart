import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Report/user_report.dart';

class LineChartUser extends StatefulWidget {
  final List<FlSpot> spots;
  final Color lineColor;

  const LineChartUser({
    Key? key,
    required this.spots,
    required this.lineColor,
  }) : super(key: key);

  @override
  State<LineChartUser> createState() => _LineChartUserState();
}

class _LineChartUserState extends State<LineChartUser> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<FlSpot> _animatedSpots() {
    return widget.spots.map((spot) {
      // Dịch toàn bộ spot x + 1
      return FlSpot(spot.x + 1, spot.y * _animation.value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Báo cáo người dùng theo tháng",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: 250,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          drawHorizontalLine: true,
                          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey, strokeWidth: 0.5),
                          getDrawingVerticalLine: (value) => FlLine(color: Colors.grey, strokeWidth: 0.5),
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
                                if (value == 0 || value == 13) {
                                  return const Text('');
                                } else if (value >= 1 && value <= 12) {
                                  return Text('Tháng ${value.toInt()}');
                                } else {
                                  return const Text('');
                                }
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: Colors.black, width: 1),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _animatedSpots(), // Dùng spots đã animate + dịch
                            isCurved: true,
                            color: widget.lineColor,
                            barWidth: 3,
                            belowBarData: BarAreaData(show: false),
                            dotData: FlDotData(show: true),
                          ),
                        ],
                        minX: 0,
                        maxX: 13,
                        minY: 0,
                        maxY: widget.spots.isEmpty
                            ? 10
                            : widget.spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.2, // Nới maxY thêm 20%
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserScreen()),
                  );
                },
                child: const Text(
                  "Xem chi tiết",
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}