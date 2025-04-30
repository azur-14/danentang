import 'package:danentang/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'edit_dialog.dart';
import 'gender_dialog.dart';
import 'date_picker_dialog.dart';

class ProfileMobileLayout extends StatelessWidget {
  final UserModel userModel;

  const ProfileMobileLayout({super.key, required this.userModel});

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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                child: userModel.avatarUrl == null
                    ? const Icon(Icons.person, size: 40)
                    : Image.network(
                  userModel.avatarUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const CircularProgressIndicator();
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error, size: 40);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userModel.userName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _pickImage(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A2E5B),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Cập nhật ảnh'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Thông tin cá nhân', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildInfoRow(context, 'Giới tính', userModel.gender ?? 'Nữ', () => GenderDialog.show(context, userModel)),
          _buildInfoRow(context, 'Ngày sinh', userModel.dateOfBirth ?? 'xx/xx/xxxx', () => ProfileDatePickerDialog.show(context, userModel)),
          _buildInfoRow(context, 'SĐT', userModel.phoneNumber ?? 'xxxxxxxxxx', () => EditDialog.show(context, userModel, 'phoneNumber', 'Số điện thoại')),
          _buildInfoRow(context, 'Email', userModel.email ?? 'example@gmail.com', () => EditDialog.show(context, userModel, 'email', 'Email')),
          _buildInfoRow(context, 'Địa chỉ', userModel.address ?? 'hhhdshdhhhhhh', () => context.push('/address')),
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
}