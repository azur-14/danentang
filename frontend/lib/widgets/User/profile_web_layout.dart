import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Service/user_service.dart';
import '../../models/Address.dart';
import '../../models/User.dart';
import 'text_field_widget.dart';

class ProfileWebLayout extends StatefulWidget {
  const ProfileWebLayout({super.key});

  @override
  _ProfileWebLayoutState createState() => _ProfileWebLayoutState();
}

class _ProfileWebLayoutState extends State<ProfileWebLayout> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      if (email == null) throw Exception('Không tìm thấy email trong SharedPreferences');

      final user = await UserService().fetchUserByEmail(email);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Lỗi khi load user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải thông tin người dùng: $e')),
      );
    }
  }

  Future<void> _submitChanges() async {
    if (_user == null) return;
    try {
      final updatedUser = _user!.copyWith();
      await UserService().updateUserFull(updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thông tin đã được lưu')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thất bại: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _user = _user!.copyWith(avatarUrl: image.path);
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
    setState(() => _user = _user!.copyWith(avatarUrl: null));
  }

  void _editAddress(int index) async {
    final addr = _user!.addresses[index];
    final receiver = await _showInputDialog('Người nhận', addr.receiverName);
    final phone = await _showInputDialog('SĐT', addr.phone);
    final line = await _showInputDialog('Số nhà, tên đường', addr.addressLine);
    final commune = await _showInputDialog('Phường/Xã', addr.commune ?? '');
    final district = await _showInputDialog('Quận/Huyện', addr.district ?? '');
    final city = await _showInputDialog('Tỉnh/Thành phố', addr.city ?? '');

    if (receiver != null && phone != null && line != null) {
      final updated = addr.copyWith(
        receiverName: receiver,
        phone: phone,
        addressLine: line,
        commune: commune,
        district: district,
        city: city,
      );
      setState(() {
        final list = List<Address>.from(_user!.addresses);
        list[index] = updated;
        _user = _user!.copyWith(addresses: list);
      });
    }
  }

  void _deleteAddress(int index) {
    setState(() {
      final list = List<Address>.from(_user!.addresses);
      list.removeAt(index);
      _user = _user!.copyWith(addresses: list);
    });
  }

  void _addAddress() async {
    final receiver = await _showInputDialog('Người nhận', '');
    final phone = await _showInputDialog('SĐT', '');
    final line = await _showInputDialog('Số nhà, tên đường', '');
    final commune = await _showInputDialog('Phường/Xã', '');
    final district = await _showInputDialog('Quận/Huyện', '');
    final city = await _showInputDialog('Tỉnh/Thành phố', '');

    if (receiver != null && phone != null && line != null) {
      final newAddr = Address(
        receiverName: receiver,
        phone: phone,
        addressLine: line,
        commune: commune,
        district: district,
        city: city,
        isDefault: _user!.addresses.isEmpty,
      );
      setState(() {
        _user = _user!.copyWith(addresses: [..._user!.addresses, newAddr]);
      });
    }
  }

  void _setDefaultAddress(int index) {
    setState(() {
      final updated = _user!.addresses.asMap().entries.map((e) {
        return e.value.copyWith(isDefault: e.key == index);
      }).toList();
      _user = _user!.copyWith(addresses: updated);
    });
  }

  Future<String?> _showInputDialog(String title, String initial) async {
    final controller = TextEditingController(text: initial);
    return await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chỉnh sửa $title'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Lưu')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('User Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _user!.avatarUrl != null ? NetworkImage(_user!.avatarUrl!) : null,
                  child: _user!.avatarUrl == null ? const Icon(Icons.person, size: 50) : null,
                ),
                const SizedBox(height: 16),
                Text(_user!.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
          TextFieldWidget(
            label: 'HỌ VÀ TÊN',
            value: _user!.fullName,
            onChanged: (value) => setState(() => _user = _user!.copyWith(fullName: value)),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _user!.gender,
            decoration: const InputDecoration(labelText: 'GIỚI TÍNH'),
            items: ['Nam', 'Nữ', 'Khác'].map((g) {
              return DropdownMenuItem<String>(
                value: g,
                child: Text(g),
              );
            }).toList(),
            onChanged: (value) => setState(() => _user = _user!.copyWith(gender: value)),
          ),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'NGÀY SINH'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _user!.dateOfBirth != null
                      ? '${_user!.dateOfBirth!.day}/${_user!.dateOfBirth!.month}/${_user!.dateOfBirth!.year}'
                      : 'Chưa chọn',
                ),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _user!.dateOfBirth ?? DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _user = _user!.copyWith(dateOfBirth: date));
                    }
                  },
                  child: const Text('Chọn ngày'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFieldWidget(
            label: 'EMAIL ADDRESS',
            value: _user!.email,
            onChanged: (_) {},
            icon: Icons.email,
          ),
          const SizedBox(height: 16),
          TextFieldWidget(
            label: 'SỐ ĐIỆN THOẠI',
            value: _user!.phoneNumber ?? '',
            onChanged: (value) => setState(() => _user = _user!.copyWith(phoneNumber: value)),
            icon: Icons.phone,
          ),
          const SizedBox(height: 32),
          const Text('ĐỊA CHỈ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._user!.addresses.asMap().entries.map((entry) {
            final index = entry.key;
            final addr = entry.value;
            return Card(
              child: ListTile(
                title: Text('${addr.receiverName} - ${addr.phone}'),
                subtitle: Text(
                  '${addr.addressLine}, ${addr.commune ?? ''}, ${addr.district ?? ''}, ${addr.city ?? ''}',
                ),
                leading: IconButton(
                  icon: Icon(
                    addr.isDefault ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () => _setDefaultAddress(index),
                ),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _editAddress(index)),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteAddress(index)),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          Center(
            child: OutlinedButton.icon(
              onPressed: _addAddress,
              icon: const Icon(Icons.add),
              label: const Text('Thêm địa chỉ mới'),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton.icon(
              onPressed: _submitChanges,
              icon: const Icon(Icons.save),
              label: const Text('Xác nhận sửa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}