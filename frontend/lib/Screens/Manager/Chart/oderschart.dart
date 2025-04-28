import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../Report/oders_report.dart';

class OrdersChartWidget extends StatefulWidget {
  final List<FlSpot> spots;
  final Color lineColor;

  const OrdersChartWidget({
    Key? key,
    required this.spots,
    required this.lineColor,
  }) : super(key: key);

  @override
  _OrdersChartWidgetState createState() => _OrdersChartWidgetState();
}

class _OrdersChartWidgetState extends State<OrdersChartWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
              "Báo cáo đơn hàng theo tháng",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
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
                          if (value.toInt() < 12) {
                            return Text((value.toInt() + 1).toString());
                          } else if (value.toInt() == 12) {
                            return const Text('Tháng');
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
                      spots: widget.spots,
                      isCurved: true,
                      color: widget.lineColor,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: false),
                      dotData: FlDotData(show: true),
                    ),
                  ],
                  minX: 0,  // Bắt đầu từ 0
                  maxX: 11, // Kết thúc ở tháng 12 (11 là giá trị cuối cùng trên trục X)
                  minY: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OrdersReport()),
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