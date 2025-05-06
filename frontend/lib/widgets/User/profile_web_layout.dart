import 'package:danentang/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'text_field_widget.dart';

class ProfileWebLayout extends StatelessWidget {
  final UserModel userModel;

  const ProfileWebLayout({super.key, required this.userModel});

  Future<void> _pickImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = kIsWeb
          ? await picker.pickImage(source: ImageSource.gallery)
          : await picker.pickImage(source: ImageSource.gallery); // Can add camera option for mobile

      if (image != null) {
        // In a real app, upload the image to a server and get the URL.
        // For this example, we'll use the file path as a placeholder.
        final String newAvatarUrl = image.path;
        userModel.updateUser(avatarUrl: newAvatarUrl);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ảnh đại diện đã được cập nhật')),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi khi chọn ảnh')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  child: userModel.avatarUrl == null
                      ? const Icon(Icons.person, size: 50)
                      : Image.network(
                    userModel.avatarUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const CircularProgressIndicator();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error, size: 50);
                    },
                  ),
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
                child: TextFieldWidget(
                  label: 'FIRST NAME',
                  value: userModel.userName.split(' ').first,
                  onChanged: (value) {
                    final names = userModel.userName.split(' ');
                    userModel.updateUser(userName: '$value ${names.length > 1 ? names.last : ''}');
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFieldWidget(
                  label: 'LAST NAME',
                  value: userModel.userName.split(' ').last,
                  onChanged: (value) {
                    final names = userModel.userName.split(' ');
                    userModel.updateUser(userName: '${names.first} $value');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFieldWidget(
            label: 'USER NAME',
            value: userModel.userName,
            onChanged: (value) {
              userModel.updateUser(userName: value);
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFieldWidget(
                  label: 'EMAIL ADDRESS',
                  value: userModel.email ?? 'example@gmail.com',
                  onChanged: (value) {
                    userModel.updateUser(email: value);
                  },
                  icon: Icons.email,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFieldWidget(
                  label: 'PHONE NUMBER',
                  value: userModel.phoneNumber ?? '',
                  onChanged: (value) {
                    userModel.updateUser(phoneNumber: value);
                  },
                  icon: Icons.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFieldWidget(
            label: 'ĐỊA CHỈ',
            value: userModel.address ?? '',
            onChanged: (value) {
              userModel.updateUser(address: value);
            },
          ),
        ],
      ),
    );
  }
}