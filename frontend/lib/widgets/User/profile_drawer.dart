import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key, required Map<String, dynamic> userData});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF211463),
            ),
            child: Image.asset('assets/Logo.png', width: 180),
          ),
          _buildDrawerItem(context, 'Hồ sơ của bạn', Icons.person, '/profile', true),
          _buildDrawerItem(context, 'Phương thức thanh toán', Icons.payment, '/payment'),
          _buildDrawerItem(context, 'Đơn hàng của tui', Icons.receipt, '/orders'),
          _buildDrawerItem(context, 'Cài đặt', Icons.settings, '/account-settings'),
          _buildDrawerItem(context, 'Đang xuất', Icons.share, '/share'),
          _buildDrawerItem(context, 'Địa chỉ', Icons.location_on, '/address'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, String route, [bool selected = false]) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: selected,
      onTap: () {
        context.push(route);
        Navigator.of(context).pop();
      },
    );
  }
}