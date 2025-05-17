import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:danentang/data/user_data.dart';
import 'package:danentang/widgets/User/profile_drawer.dart';
import 'package:danentang/widgets/User/profile_mobile_layout.dart';
import 'package:danentang/widgets/User/profile_web_layout.dart';

class ProfileManagementScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ProfileManagementScreen({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final Map<String, dynamic> effectiveUserData = userData ?? UserData.userData;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      key: _scaffoldKey,
      appBar: isMobile
          ? AppBar(
        title: const Text('Hồ sơ của bạn'),
        backgroundColor: const Color(0xFF4B5EFC), // Match MyOrdersScreen
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF3B82F6)),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      )
          : null,
      drawer: isMobile ? const ProfileDrawer() : null,
      backgroundColor: const Color(0xFFF8FAFC), // Match MyOrdersScreen
      body: Row(
        children: [
          if (!isMobile && kIsWeb)
            const SizedBox(
              width: 250,
              child: ProfileDrawer(),
            ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: kIsWeb ? const ProfileWebLayout() : const ProfileMobileLayout(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}