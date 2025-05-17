import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFFFFFF),
      elevation: 8.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
              ),
              boxShadow: [
                //BoxShadow(
                 // color: Colors.black,
                  //blurRadius: 8,
                  //offset: const Offset(0, 4),
                //),
              ],
            ),
            child: Center(
              child: Image.asset('assets/images/logoapbar.jpg', width: 180),
            ),
          ),
          _buildDrawerItem(context, 'Hồ sơ của bạn', Icons.person, '/personal-info'),
          _buildDrawerItem(context, 'Đơn hàng của tui', Icons.receipt, '/my-orders'),
          _buildDrawerItem(context, 'Đổi mật khẩu', Icons.lock, '/change_password'),
          _buildDrawerItem(context, 'Đăng xuất', Icons.logout, '/login', isLogout: true),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context,
      String title,
      IconData icon,
      String route, {
        bool isLogout = false,
      }) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final bool selected = currentRoute == route && !isLogout;
    return _DrawerItem(
      title: title,
      icon: icon,
      route: route,
      isLogout: isLogout,
      selected: selected,
      onTap: () async {
        try {
          print('Navigating to $route from ProfileDrawer');
          print('Current route: $currentRoute');
          print('GoRouter available: ${GoRouter.of(context) != null}');
          if (isLogout) {
            await _handleLogout();
            context.go(route);
          } else if (route == '/my-orders') {
            final prefs = await SharedPreferences.getInstance();
            final isLoggedIn = prefs.getString('token') != null;
            context.go(route, extra: isLoggedIn);
          } else {
            context.go(route);
          }
          Navigator.of(context).pop();
        } catch (e) {
          print('Navigation error for route $route: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể điều hướng tới $title')),
          );
        }
      },
    );
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
  }
}

class _DrawerItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final String route;
  final bool isLogout;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.isLogout,
    required this.selected,
    required this.onTap,
  });

  @override
  _DrawerItemState createState() => _DrawerItemState();
}

class _DrawerItemState extends State<_DrawerItem> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap,
        onHighlightChanged: (isHighlighted) {
          setState(() {
            _isPressed = isHighlighted;
          });
        },
        onHover: (isHovered) {
          setState(() {
            _isHovered = isHovered;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: _isPressed
                ? (widget.isLogout ? const Color(0xFFFFE4E6) : const Color(0xFFD1E7FF))
                : _isHovered
                ? (widget.isLogout ? const Color(0xFFFEE2E2) : const Color(0xFFEFF6FF))
                : widget.selected
                ? const Color(0xFFEFF6FF)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.selected || _isHovered || _isPressed
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ]
                : [],
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: widget.isLogout ? const Color(0xFFF87171) : const Color(0xFF4B5EFC),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.isLogout ? const Color(0xFFF87171) : const Color(0xFF1E293B),
                    fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}