import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnimatedPieChart extends StatefulWidget {
  const AnimatedPieChart({Key? key}) : super(key: key);

  @override
  _AnimatedPieChartState createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart> with SingleTickerProviderStateMixin {
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
              "Các phương thức đăng nhập",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: 30 * _animation.value,
                          color: Colors.green,
                          title: 'Direct',
                          radius: 40,
                          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        PieChartSectionData(
                          value: 20 * _animation.value,
                          color: Colors.blue,
                          title: 'Affiliate',
                          radius: 40,
                          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        PieChartSectionData(
                          value: 15 * _animation.value,
                          color: Colors.orange,
                          title: 'Sponsored',
                          radius: 40,
                          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        PieChartSectionData(
                          value: 10 * _animation.value,
                          color: Colors.yellow,
                          title: 'Email',
                          radius: 40,
                          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                      borderData: FlBorderData(show: false),
                      centerSpaceRadius: 30,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}