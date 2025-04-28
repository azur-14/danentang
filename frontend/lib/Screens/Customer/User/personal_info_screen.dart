import 'package:danentang/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileManagementScreen extends StatelessWidget {
  const ProfileManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, userModel, child) {
        final bool isWideScreen = MediaQuery.of(context).size.width > 600;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Hồ sơ của bạn'),
            backgroundColor: kIsWeb ? Colors.white : null,
            elevation: kIsWeb ? 0 : null,
            leading: isWideScreen
                ? null
                : Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          drawer: !isWideScreen ? _buildDrawer(context) : null,
          body: Row(
            children: [
              if (isWideScreen) _buildDrawer(context),
              Expanded(
                child: kIsWeb
                    ? _buildWebLayout(context, userModel)
                    : _buildMobileLayout(context, userModel),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF211463),
            ),

          child: Image.asset('assets/Logo.png', width: 180)
          ),
          _buildDrawerItem(context, 'Hồ sơ của bạn', Icons.person, '/profile', true),
          _buildDrawerItem(context, 'Phương thức thanh toán', Icons.payment, '/payment'),
          _buildDrawerItem(context, 'Đơn hàng của tui', Icons.receipt, '/orders'),
          _buildDrawerItem(context, 'Cài đặt', Icons.settings, '/settings'),
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
        Navigator.of(context).pushReplacementNamed(route);
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, UserModel userModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: userModel.avatarUrl != null
                    ? NetworkImage(userModel.avatarUrl!)
                    : null,
                child: userModel.avatarUrl == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              const SizedBox(width: 16),
              Text(
                userModel.userName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Thông tin cá nhân', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildInfoRow(context, 'Giới tính', userModel.gender ?? 'Nữ', () => _showGenderDialog(context, userModel)),
          _buildInfoRow(context, 'Ngày sinh', userModel.dateOfBirth ?? 'xx/xx/xxxx', () => _showDatePicker(context, userModel)),
          _buildInfoRow(context, 'SĐT', userModel.phoneNumber ?? 'xxxxxxxxxx', () => _showEditDialog(context, userModel, 'phoneNumber', 'Số điện thoại')),
          _buildInfoRow(context, 'Email', userModel.email ?? 'example@gmail.com', () => _showEditDialog(context, userModel, 'email', 'Email')),
          _buildInfoRow(context, 'Địa chỉ', userModel.address ?? 'hhhdshdhhhhhh', () => Navigator.pushNamed(context, '/address')),
        ],
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, UserModel userModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: userModel.avatarUrl != null
                      ? NetworkImage(userModel.avatarUrl!)
                      : null,
                  child: userModel.avatarUrl == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  userModel.userName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Logic to upload new photo (e.g., using image_picker)
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2E5B),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('UPLOAD NEW PHOTO'),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        userModel.updateUser(avatarUrl: null);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2A2E5B)),
                        foregroundColor: const Color(0xFF2A2E5B),
                      ),
                      child: const Text('DELETE'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTextField('FIRST NAME', userModel.userName.split(' ').first, (value) {
                  final names = userModel.userName.split(' ');
                  userModel.updateUser(userName: '$value ${names.length > 1 ? names.last : ''}');
                }),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField('LAST NAME', userModel.userName.split(' ').last, (value) {
                  final names = userModel.userName.split(' ');
                  userModel.updateUser(userName: '${names.first} $value');
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField('USER NAME', userModel.userName, (value) {
            userModel.updateUser(userName: value);
          }),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField('EMAIL ADDRESS', userModel.email ?? 'example@gmail.com', (value) {
                  userModel.updateUser(email: value);
                }, icon: Icons.email),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField('PHONE NUMBER', userModel.phoneNumber ?? '', (value) {
                  userModel.updateUser(phoneNumber: value);
                }, icon: Icons.phone),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField('ĐỊA CHỈ', userModel.address ?? '', (value) {
            userModel.updateUser(address: value);
          }),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Row(
              children: [
                Text(value, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value, Function(String) onChanged, {IconData? icon}) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: 'e.g. $value',
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
      ),
      controller: TextEditingController(text: value),
      onChanged: onChanged,
    );
  }

  void _showGenderDialog(BuildContext context, UserModel userModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Giới tính'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Nam'),
                onTap: () {
                  userModel.updateUser(gender: 'Nam');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Nữ'),
                onTap: () {
                  userModel.updateUser(gender: 'Nữ');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showDatePicker(BuildContext context, UserModel userModel) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate != null) {
        final formattedDate = '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
        userModel.updateUser(dateOfBirth: formattedDate);
      }
    });
  }

  void _showEditDialog(BuildContext context, UserModel userModel, String field, String title) {
    final controller = TextEditingController(text: field == 'phoneNumber' ? userModel.phoneNumber : userModel.email);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cập nhật $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: title),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (field == 'phoneNumber') {
                  userModel.updateUser(phoneNumber: controller.text);
                } else {
                  userModel.updateUser(email: controller.text);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }
}