import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:danentang/constants/colors.dart';
import 'package:danentang/Service/user_service.dart';
import 'package:danentang/models/user.dart';

class WebHeader extends StatefulWidget implements PreferredSizeWidget {
  final bool isLoggedIn;

  const WebHeader({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  _WebHeaderState createState() => _WebHeaderState();
}

class _WebHeaderState extends State<WebHeader> {
  User?   _user;
  bool    _loading = false;
  String? _error;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn) _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _loading = true;
      _error   = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId != null) {
        // giờ đúng:
        final user = await _userService.fetchUserById(userId);
        setState(() => _user = user as User?);
      }
    } catch (e) {
      setState(() => _error = 'Không tải được thông tin người dùng');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = widget.isLoggedIn;

    // Xác định text hiển thị (app name hoặc tên user)
    String title;
    if (!loggedIn) {
      title = 'Hoalahe';
    } else if (_loading) {
      title = 'Đang tải...';
    } else if (_user != null) {
      title = _user!.fullName;
    } else {
      title = 'Guest';
    }

    // Tạo image từ Base64 nếu có
    ImageProvider? avatarImg;
    if (_user?.avatarUrl != null) {
      final raw = _user!.avatarUrl!.split(',').last;
      avatarImg = MemoryImage(base64Decode(raw));
    }

    return Container(
      color: AppColors.primaryPurple,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Phần trái: static links
          const Text(
            "Hoalahe | Kênh người bán | Tải Ứng dụng | Kết nối",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),

          const Spacer(),

          // Ngôn ngữ
          const Text("Tiếng Việt", style: TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(width: 24),

          // Giỏ hàng luôn hiện
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () => context.go('/checkout', extra: loggedIn),
          ),
          const SizedBox(width: 8),

          // Nếu đã login: chat icon, ngược lại: nút Đăng nhập
          if (loggedIn) ...[
            IconButton(
              icon: const Icon(Icons.message, color: Colors.white),
              onPressed: () => context.go('/chat'),
            ),
          ] else ...[
            TextButton(
              onPressed: () => context.go('/login-signup'),
              child: const Text(
                'Đăng nhập',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
          const SizedBox(width: 16),

          // Avatar + tên hoặc chỉ tên app nếu chưa login
          if (loggedIn)
            GestureDetector(
              onTap: () => context.go('/profile'),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: avatarImg,
                    child: avatarImg == null && !_loading
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            )
          else
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}
