import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:danentang/constants/colors.dart';
import 'package:danentang/Service/user_service.dart';
import 'package:danentang/models/User.dart';

class WebHeader extends StatefulWidget implements PreferredSizeWidget {
  final bool isLoggedIn;

  const WebHeader({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  _WebHeaderState createState() => _WebHeaderState();
}

class _WebHeaderState extends State<WebHeader> {
  User? _user;
  bool _loading = false;
  String? _error;
  final UserService _userService = UserService();
  String? _role;

  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn) _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      final role = prefs.getString('role') ?? 'customer';

      debugPrint('📦 Email from prefs: $email');

      if (email != null) {
        final user = await UserService().fetchUserByEmail(email);
        setState(() {
          _user = user; // ✅ đúng kiểu rồi, không cần ép kiểu nữa
        });
      }
    } catch (e) {
      debugPrint('❌ Lỗi khi lấy user: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final loggedIn = widget.isLoggedIn;

    // Hiển thị tên người dùng hoặc fallback
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

    // Hiển thị avatar nếu có
    ImageProvider? avatarImg;
    if (_user?.avatarUrl != null && _user!.avatarUrl!.startsWith('data:image')) {
      try {
        final base64Data = _user!.avatarUrl!.split(',').last;
        avatarImg = MemoryImage(base64Decode(base64Data));
      } catch (_) {
        avatarImg = null;
      }
    }

    return Container(
      color: AppColors.primaryPurple,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            "Hoalahe | Kênh người bán | Tải Ứng dụng | Kết nối",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const Spacer(),
          const Text("Tiếng Việt", style: TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(width: 24),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () => context.go('/checkout', extra: loggedIn),
          ),
          const SizedBox(width: 8),
          if (loggedIn) ...[
            IconButton(
              icon: const Icon(Icons.message, color: Colors.white),
              onPressed: () {
                if (_role == 'admin') {
                  // Admin chưa chọn user, show thông báo hoặc chuyển tới danh sách người dùng khiếu nại
                  context.go('/support'); // bạn có thể dùng '/chat/:userId' nếu có user cụ thể
                } else {
                  // Customer, chat với admin mặc định
                  context.go('/chat');
                }
              },
            ),

          ] else ...[
            TextButton(
              onPressed: () => context.go('/login-signup'),
              child: const Text('Đăng nhập', style: TextStyle(color: Colors.white)),
            ),
          ],
          const SizedBox(width: 16),
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
