import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'edit_dialog.dart';
import 'gender_dialog.dart';
import 'date_picker_dialog.dart';

class ProfileMobileLayout extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileMobileLayout({super.key, required this.userData});

  @override
  _ProfileMobileLayoutState createState() => _ProfileMobileLayoutState();
}

class _ProfileMobileLayoutState extends State<ProfileMobileLayout> {
  late Map<String, dynamic> _userData;

  @override
  void initState() {
    super.initState();
    // Create a mutable copy of userData to allow updates
    _userData = Map<String, dynamic>.from(widget.userData);
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = kIsWeb
          ? await picker.pickImage(source: ImageSource.gallery)
          : await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _userData['avatarUrl'] = image.path;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ảnh đại diện đã được cập nhật')),
        );
      }
    } catch (e) {
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
                child: _userData['avatarUrl'] == null
                    ? const Icon(Icons.person, size: 40)
                    : Image.network(
                  _userData['avatarUrl'],
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
                    _userData['userName'],
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _pickImage,
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
          const Text('Thông tin cá nhân',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildInfoRow(
              context, 'Giới tính', _userData['gender'], () => _showGenderDialog()),
          _buildInfoRow(context, 'Ngày sinh', _userData['dateOfBirth'],
                  () => _showDatePickerDialog()),
          _buildInfoRow(context, 'SĐT', _userData['phoneNumber'],
                  () => _showEditDialog('phoneNumber', 'Số điện thoại')),
          _buildInfoRow(context, 'Email', _userData['email'],
                  () => _showEditDialog('email', 'Email')),
          _buildInfoRow(context, 'Địa chỉ', _userData['address'],
                  () => context.push('/address')),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, String label, String value, VoidCallback onTap) {
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
                Text(value,
                    style: const TextStyle(fontSize: 16, color: Colors.grey)),
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

  Future<void> _showGenderDialog() async {
    final selectedGender = await GenderDialog.show(context, null);
    if (selectedGender != null) {
      setState(() {
        _userData['gender'] = selectedGender;
      });
    }
  }

  Future<void> _showDatePickerDialog() async {
    final selectedDate = await ProfileDatePickerDialog.show(context, null);
    if (selectedDate != null) {
      setState(() {
        _userData['dateOfBirth'] = selectedDate;
      });
    }
  }

  Future<void> _showEditDialog(String field, String title) async {
    final newValue = await EditDialog.show(context, null, field, title);
    if (newValue != null) {
      setState(() {
        _userData[field] = newValue;
      });
    }
  }
}