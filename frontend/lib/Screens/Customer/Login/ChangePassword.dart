import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:danentang/constants/colors.dart';
import 'package:danentang/Screens/Customer/Login/Login_Screen.dart';
import 'package:danentang/Service/user_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String email;
  const ForgotPasswordScreen({required this.email, Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController emailController;
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  String? _serverOtp;
  String? errorMessage;

  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.email);
    _sendOtp();
  }

  Future<void> _sendOtp() async {
    try {
      final otp = await _userService.sendOtp(widget.email);
      debugPrint('sendOtp success, otp=$otp');
      setState(() {
        _serverOtp = otp;
        errorMessage = null;
      });
      _showSnackBar('Mã OTP đã gửi đến ${widget.email}');
    } catch (e, st) {
      debugPrint('Error in sendOtp(): $e');
      debugPrintStack(stackTrace: st);
      setState(() {
        errorMessage = e.toString();
      });
      _showSnackBar('Lỗi gửi OTP: $e');
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (otpController.text.trim() != _serverOtp) {
      setState(() {
        errorMessage = 'OTP không đúng';
      });
      _showSnackBar('OTP không đúng');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await _userService.resetPassword(
        email: widget.email,
        newPassword: newPasswordController.text,
      );
      debugPrint('resetPassword success');
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Thành công'),
          content: const Text('Đổi mật khẩu thành công!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(email: widget.email),
                  ),
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e, st) {
      debugPrint('Error in resetPassword(): $e');
      debugPrintStack(stackTrace: st);
      setState(() {
        errorMessage = e.toString();
      });
      _showSnackBar('Lỗi đổi mật khẩu: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildTextFormField({
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool isPassword = false,
    bool isConfirm = false,
    bool isNumeric = false,
  }) {
    final obscure = isPassword
        ? (isConfirm ? !showConfirmPassword : !showPassword)
        : false;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType:
      isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            (isConfirm ? showConfirmPassword : showPassword)
                ? Icons.visibility
                : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              if (isConfirm) {
                showConfirmPassword = !showConfirmPassword;
              } else {
                showPassword = !showPassword;
              }
            });
          },
        )
            : null,
      ),
      validator: validator,
    );
  }

  Widget _buildFormContent(double h, double w) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quên mật khẩu",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Email read-only
          TextFormField(
            controller: emailController,
            readOnly: true,
            decoration: InputDecoration(
              hintText: "Email của bạn",
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // OTP
          _buildTextFormField(
            hint: "Nhập mã OTP",
            controller: otpController,
            isNumeric: true,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Vui lòng nhập mã OTP';
              if (!RegExp(r'^\d{4,6}$').hasMatch(v)) {
                return 'OTP phải từ 4–6 chữ số';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),

          // Mật khẩu mới
          _buildTextFormField(
            hint: "Mật khẩu mới",
            controller: newPasswordController,
            isPassword: true,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
              if (v.length < 6) return 'Ít nhất 6 ký tự';
              return null;
            },
          ),
          const SizedBox(height: 15),

          // Xác nhận mật khẩu
          _buildTextFormField(
            hint: "Xác nhận mật khẩu",
            controller: confirmPasswordController,
            isPassword: true,
            isConfirm: true,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Vui lòng xác nhận mật khẩu';
              if (v != newPasswordController.text) return 'Mật khẩu không khớp';
              return null;
            },
          ),
          const SizedBox(height: 15),

          // Hiển thị lỗi (nếu có)
          if (errorMessage != null) ...[
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 15),
          ],

          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: h * 0.07,
            child: ElevatedButton(
              onPressed: isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                "Đặt lại mật khẩu",
                style: TextStyle(
                  fontSize: w * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Gửi lại OTP
          Center(
            child: TextButton(
              onPressed: _sendOtp,
              child: const Text(
                "Gửi lại mã OTP",
                style: TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Quay về Login
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LoginScreen(email: widget.email),
                  ),
                );
              },
              child: const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "Nhớ mật khẩu? "),
                    TextSpan(
                      text: "Đăng nhập",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    if (w > 800) {
      // Web layout
      return Scaffold(
        body: Row(
          children: [
            Expanded(
              child: Container(color: AppColors.brandPrimary),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(40),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: _buildFormContent(h, w),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Mobile layout
    return Scaffold(
      backgroundColor: AppColors.brandPrimary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: _buildFormContent(h, w),
      ),
    );
  }
}
