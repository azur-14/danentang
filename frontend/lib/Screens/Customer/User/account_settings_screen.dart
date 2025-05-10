import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:danentang/models/User.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Change Password'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implement change password logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Change Password feature coming soon!')),
                );
              },
            ),
            ListTile(
              title: const Text('Logout'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                final user = Provider.of<User>(context, listen: false);
                user.updateUser(isLoggedIn: false);
                context.go('/login');
              },
            ),
            ListTile(
              title: const Text('Đổi Theme'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implement theme change logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme change feature coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}