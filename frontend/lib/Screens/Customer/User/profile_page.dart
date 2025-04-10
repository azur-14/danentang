import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Color(0xFF333333)),
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Details',
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    'https://i.imgur.com/lv1wB3y.png', // Replace with actual image
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Diew Ne',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 30),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          _buildMenuItem('Hồ sơ của bạn'),
          _buildMenuItem('Phương thức thanh toán'),
          _buildMenuItem('Đơn hàng của tôi'),
          _buildMenuItem('Cài đặt'),
          _buildMenuItem('Đăng xuất'),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'SHOPPING APP',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildMenuItem(String title) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 16,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: () {},
        ),
        const Divider(height: 1, color: Color(0xFFE0E0E0)),
      ],
    );
  }
}
