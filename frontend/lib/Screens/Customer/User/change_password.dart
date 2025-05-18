// lib/screens/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:danentang/Service/user_service.dart';
import 'package:danentang/models/User.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPwCtrl = TextEditingController();
  final _newPwCtrl     = TextEditingController();
  final _confirmPwCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<String?> _getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    // Giả sử bạn lưu email khi login
    return prefs.getString('email');
  }

  @override
  void dispose() {
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = await _getEmail();
    if (email == null) {
      setState(() => _error = 'Không xác định được tài khoản.');
      return;
    }

    setState(() {
      _loading = true;
      _error   = null;
    });

    try {
      await UserService().changePassword(
        email: email,
        currentPassword: _currentPwCtrl.text,
        newPassword: _newPwCtrl.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đổi mật khẩu thành công!')),
      );
      context.go('/profile');
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: Column(
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              TextFormField(
                controller: _currentPwCtrl,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                ),
                obscureText: true,
                validator: (v) =>
                (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu hiện tại' : null,
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _newPwCtrl,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu mới',
                ),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu mới';
                  if (v.length < 6) return 'Mật khẩu phải ít nhất 6 ký tự';
                  return null;
                },
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPwCtrl,
                decoration: const InputDecoration(
                  labelText: 'Xác nhận mật khẩu mới',
                ),
                obscureText: true,
                validator: (v) {
                  if (v != _newPwCtrl.text) return 'Không khớp mật khẩu mới';
                  return null;
                },
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _onSubmit,
                child: const Text('Xác nhận'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

