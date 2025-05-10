// lib/Screens/Manager/Profile/profile_web_layout.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:danentang/models/User.dart';
import 'package:danentang/models/address.dart';
import 'text_field_widget.dart';

class ProfileWebLayout extends StatelessWidget {
  final User user;

  const ProfileWebLayout({super.key, required this.user});

  Future<void> _pickImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        user.updateUser(avatarUrl: image.path);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ảnh đại diện đã được cập nhật')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi chọn ảnh')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // take first addressLine or fallback
    final firstAddressLine = user.addresses.isNotEmpty
        ? user.addresses.first.addressLine
        : '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
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
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.userName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _pickImage(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2E5B),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('UPLOAD NEW PHOTO'),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () {
                        user.updateUser(avatarUrl: null);
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
          // split name into first/last for web
          Row(
            children: [
              Expanded(
                child: TextFieldWidget(
                  label: 'FIRST NAME',
                  value: user.userName.split(' ').first,
                  onChanged: (v) {
                    final parts = user.userName.split(' ');
                    final last = parts.length > 1 ? parts.last : '';
                    user.updateUser(
                        userName: '$v${last.isEmpty ? '' : ' $last'}');
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFieldWidget(
                  label: 'LAST NAME',
                  value: user.userName.split(' ').length > 1
                      ? user.userName.split(' ').last
                      : '',
                  onChanged: (v) {
                    final first = user.userName.split(' ').first;
                    user.updateUser(userName: '$first ${v.trim()}');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFieldWidget(
            label: 'USER NAME',
            value: user.userName,
            onChanged: (v) => user.updateUser(userName: v),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFieldWidget(
                  label: 'EMAIL ADDRESS',
                  value: user.email,
                  icon: Icons.email,
                  onChanged: (v) => user.updateUser(email: v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFieldWidget(
                  label: 'PHONE NUMBER',
                  value: user.phoneNumber ?? '',
                  icon: Icons.phone,
                  onChanged: (v) => user.updateUser(phoneNumber: v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFieldWidget(
            label: 'ĐỊA CHỈ',
            value: firstAddressLine,
            onChanged: (v) {
              // wrap into a single-address list
              user.updateUser(addresses: [
                Address(
                  addressLine: v,
                  city: user.addresses.isNotEmpty
                      ? user.addresses.first.city
                      : null,
                  state: user.addresses.isNotEmpty
                      ? user.addresses.first.state
                      : null,
                  zipCode: user.addresses.isNotEmpty
                      ? user.addresses.first.zipCode
                      : null,
                  country: user.addresses.isNotEmpty
                      ? user.addresses.first.country
                      : null,
                  isDefault: true,
                  createdAt: user.addresses.isNotEmpty
                      ? user.addresses.first.createdAt
                      : DateTime.now(),
                )
              ]);
            },
          ),
        ],
      ),
    );
  }
}
