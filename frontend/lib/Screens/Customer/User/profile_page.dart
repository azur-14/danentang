import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:danentang/models/user_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý trang cá nhân'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/account-settings');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.userName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    context.push('/personal-info');
                  },
                  child: const Icon(Icons.edit, size: 20, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Phương thức thanh toán'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implement payment methods logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment methods feature coming soon!')),
                );
              },
            ),
            ListTile(
              title: const Text('Đơn hàng của tôi'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implement orders logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Orders feature coming soon!')),
                );
              },
            ),
            ListTile(
              title: const Text('Cài đặt'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                context.push('/account-settings');
              },
            ),
            ListTile(
              title: const Text('Đăng xuất'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                final user = Provider.of<UserModel>(context, listen: false);
                user.updateUser(isLoggedIn: false);
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}