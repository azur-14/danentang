import 'package:flutter/material.dart';
import 'package:danentang/constants/colors.dart';

class WebHeader extends StatelessWidget {
  final bool isLoggedIn;

  const WebHeader({
    Key? key,
    required this.isLoggedIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryPurple,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "HoaLahe | Kênh người bán | Tải Ứng dụng | Kết nối",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          Row(
            children: [
              const Text(
                "Tiếng Việt",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "je3mlgb384",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}