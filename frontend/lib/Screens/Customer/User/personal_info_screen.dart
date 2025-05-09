import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:danentang/data/user_data.dart'; // Import file dữ liệu mẫu
import 'package:danentang/widgets/User/profile_drawer.dart';
import 'package:danentang/widgets/User/profile_mobile_layout.dart';
import 'package:danentang/widgets/User/profile_web_layout.dart';

class ProfileManagementScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ProfileManagementScreen({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    // Sử dụng userData được truyền vào, nếu null thì lấy từ UserData.userData
    final Map<String, dynamic> effectiveUserData = userData ?? UserData.userData;

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
      drawer: !isWideScreen && !kIsWeb
          ? ProfileDrawer(userData: effectiveUserData)
          : null,
      body: Row(
        children: [
          if (kIsWeb) ProfileDrawer(userData: effectiveUserData),
          Expanded(
            child: kIsWeb
                ? ProfileWebLayout(userData: effectiveUserData)
                : ProfileMobileLayout(userData: effectiveUserData),
          ),
        ],
      ),
    );
  }
}