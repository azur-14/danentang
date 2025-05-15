import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MobileHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoggedIn;
  final String userName;
  const MobileHeader({
    Key? key,
    required this.isLoggedIn,
    this.userName = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.diamond, color: Colors.purple, size: 20),
          const SizedBox(width: 8),
          Text(
            isLoggedIn ? 'Hello $userName' : 'Hoalahe',
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
        ],
      ),
      actions: [
        // 1. Icon giỏ hàng luôn hiện
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.black),
              onPressed: () => context.go('/checkout', extra: isLoggedIn),
            ),
            const Positioned(
              right: 8,
              top: 8,
              child: _Badge(count: 1),
            ),
          ],
        ),

        const SizedBox(width: 8),

        // 2. Nếu đã login: show chat icon, ngược lại: nút Đăng nhập
        if (isLoggedIn) ...[
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.message, color: Colors.black),
                onPressed: () => context.go('/chat'),
              ),
              const Positioned(
                right: 8,
                top: 8,
                child: _Badge(count: 1),
              ),
            ],
          ),
        ] else ...[
          TextButton(
            onPressed: () => context.go('/login-signup'),
            child: const Text(
              'Đăng nhập',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],

        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({Key? key, required this.count}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 10),
        textAlign: TextAlign.center,
      ),
    );
  }
}

