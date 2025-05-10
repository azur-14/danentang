import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:danentang/constants/colors.dart';

class WebHeader extends StatelessWidget {
  final Map<String, dynamic> userData;

  const WebHeader({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String userName = userData['userName'] as String? ?? 'Guest';
    final String? avatarUrl = userData['avatarUrl'] as String?;

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
                      // Wrap userData in a map to ensure clarity on the receiving end
                      context.go('/profile', extra: {'userData': userData});
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    userName,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
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