import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:danentang/models/User.dart';
import 'package:danentang/constants/colors.dart';

class WebHeader extends StatelessWidget {
  const WebHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

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
                  GestureDetector(
                    onTap: () {
                      context.go('/profile');
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user.userName,
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