import 'package:danentang/models/User.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'edit_dialog.dart';
import 'gender_dialog.dart';
import 'date_picker_dialog.dart';

class ProfileMobileLayout extends StatelessWidget {
  final User user;

  const ProfileMobileLayout({
    super.key,
    required this.user,
  });

  Future<void> _pickImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // In real app upload then get URL; here we just use path
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
    final firstAddress = user.addresses.isNotEmpty
        ? user.addresses.first.addressLine
        : 'Chưa có địa chỉ';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.userName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _pickImage(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A2E5B),
                    ),
                    child: const Text('Cập nhật ảnh'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Thông tin cá nhân',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildInfoRow(context, 'Giới tính',
              user.gender ?? 'Chưa cập nhật', () {
                GenderDialog.show(context, user);
              }),
          _buildInfoRow(context, 'Ngày sinh',
              user.dateOfBirth ?? 'Chưa cập nhật', () {
                ProfileDatePickerDialog.show(context, user);
              }),
          _buildInfoRow(
              context, 'SĐT', user.phoneNumber ?? 'Chưa cập nhật', () {
            EditDialog.show(
                context, user, 'phoneNumber', 'Số điện thoại');
          }),
          _buildInfoRow(context, 'Email', user.email, () {
            EditDialog.show(context, user, 'email', 'Email');
          }),
          _buildInfoRow(context, 'Địa chỉ', firstAddress, () {
            // navigate to a full address management screen
            context.push('/addresses');
          }),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, String label, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Row(
              children: [
                Text(value,
                    style:
                    const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
