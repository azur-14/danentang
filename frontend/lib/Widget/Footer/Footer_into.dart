import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Align( // Căn giữa theo chiều ngang
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 5),
          Text(
            "SHOPPING APP",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 5),
          Container(
            width: 80, // Độ dài của thanh bo tròn
            height: 5, // Độ dày của thanh
            decoration: BoxDecoration(
              color: Colors.grey.shade400, // Màu xám nhạt
              borderRadius: BorderRadius.circular(10), // Bo tròn 2 đầu
            ),
          ),
        ],
      ),
    );
  }
}
