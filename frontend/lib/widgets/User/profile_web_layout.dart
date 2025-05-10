import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'text_field_widget.dart';

class ProfileWebLayout extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileWebLayout({super.key, required this.userData});

  @override
  _ProfileWebLayoutState createState() => _ProfileWebLayoutState();
}

class _ProfileWebLayoutState extends State<ProfileWebLayout> {
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

  void _deleteImage() {
    setState(() {
      _userData['avatarUrl'] = null;
    });
  }

  void _updateName(String firstName, String lastName) {
    setState(() {
      _userData['userName'] = '$firstName $lastName'.trim();
    });
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
                  child: _userData['avatarUrl'] == null
                      ? const Icon(Icons.person, size: 50)
                      : Image.network(
                    _userData['avatarUrl'],
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
                  _userData['userName'],
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2E5B),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('UPLOAD NEW PHOTO'),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: _deleteImage,
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
                  value: _userData['userName'].toString().split(' ').first,
                  onChanged: (value) {
                    final names = _userData['userName'].toString().split(' ');
                    _updateName(value, names.length > 1 ? names.last : '');
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFieldWidget(
                  label: 'LAST NAME',
                  value: _userData['userName'].toString().split(' ').last,
                  onChanged: (value) {
                    final names = _userData['userName'].toString().split(' ');
                    _updateName(names.first, value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFieldWidget(
            label: 'USER NAME',
            value: _userData['userName'].toString(),
            onChanged: (value) {
              setState(() {
                _userData['userName'] = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFieldWidget(
                  label: 'EMAIL ADDRESS',
                  value: _userData['email']?.toString() ?? 'example@gmail.com',
                  onChanged: (value) {
                    setState(() {
                      _userData['email'] = value;
                    });
                  },
                  icon: Icons.email,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFieldWidget(
                  label: 'PHONE NUMBER',
                  value: _userData['phoneNumber']?.toString() ?? '',
                  onChanged: (value) {
                    setState(() {
                      _userData['phoneNumber'] = value;
                    });
                  },
                  icon: Icons.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFieldWidget(
            label: 'ĐỊA CHỈ',
            value: _userData['address']?.toString() ?? '',
            onChanged: (value) {
              setState(() {
                _userData['address'] = value;
              });
            },
          ),
        ],
      ),
    );
  }
}