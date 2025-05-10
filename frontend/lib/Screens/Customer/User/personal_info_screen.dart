import 'package:danentang/models/User.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:danentang/widgets/User/profile_drawer.dart';
import 'package:danentang/widgets/User/profile_mobile_layout.dart';
import 'package:danentang/widgets/User/profile_web_layout.dart';

class ProfileManagementScreen extends StatelessWidget {
  const ProfileManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (context, user, child) {
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final bool isWideScreen = MediaQuery.of(context).size.width > 600;

        return Scaffold(
          appBar: kIsWeb
              ? null
              : AppBar(
            title: const Text('Hồ sơ của bạn'),
            backgroundColor: kIsWeb ? Colors.white : null,
            elevation: kIsWeb ? 0 : null,
            leading: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          drawer: !isWideScreen && !kIsWeb ? const ProfileDrawer() : null,
          body: Row(
            children: [
              if (kIsWeb) const ProfileDrawer(),
              Expanded(
                child: kIsWeb
                    ? ProfileWebLayout(user: user)
                    : ProfileMobileLayout(user: user),
              ),
            ],
          ),
        );
      },
    );
  }
}