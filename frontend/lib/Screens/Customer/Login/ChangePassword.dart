import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import 'Login_Screen.dart';
import '../../../Service/user_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;
  bool showConfirmPassword = false;

  final UserService _userService = UserService();

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final otp = otpController.text.trim();
    final newPass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;

    if (newPass != confirmPass) {
      _showSnackBar('Mật khẩu xác nhận không khớp.');
      return;
    }

    setState(() => isLoading = true);

    try {
      await _userService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPass,
      );

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Thành công'),
          content: const Text('Đổi mật khẩu thành công!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen(email: email)),
                );
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showSnackBar('Lỗi: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void resendOTP() {
    _showSnackBar('Mã OTP đã được gửi lại đến email.');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildTextFormField({
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool isPassword = false,
    bool isConfirm = false,
    bool isNumeric = false,
  }) {
    bool isObscure =
    isPassword ? (isConfirm ? !showConfirmPassword : !showPassword) : false;

    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
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
            color: Colors.black26,
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
          _buildTextFormField(
            hint: "Nhập email",
            controller: emailController,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Vui lòng nhập email';
              final regex = RegExp(r'^[\w.+-]+@gmail\.com$');
              if (!regex.hasMatch(value)) return 'Chỉ chấp nhận Gmail hợp lệ';
              return null;
            },
          ),
          const SizedBox(height: 15),
          _buildTextFormField(
            hint: "Mã OTP",
            controller: otpController,
            isNumeric: true,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Vui lòng nhập mã OTP';
              if (!RegExp(r'^\d{4,6}$').hasMatch(value)) return 'OTP phải từ 4–6 số';
              return null;
            },
          ),
          const SizedBox(height: 15),
          _buildTextFormField(
            hint: "Mật khẩu mới",
            controller: newPasswordController,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
              if (value.length < 6) return 'Ít nhất 6 ký tự';
              return null;
            },
          ),
          const SizedBox(height: 15),
          _buildTextFormField(
            hint: "Xác nhận mật khẩu",
            controller: confirmPasswordController,
            isPassword: true,
            isConfirm: true,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
              if (value != newPasswordController.text) return 'Mật khẩu không khớp';
              return null;
            },
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: h * 0.07,
            child: ElevatedButton(
              onPressed: isLoading ? null : resetPassword,
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
          Center(
            child: GestureDetector(
              onTap: resendOTP,
              child: const Text(
                "Gửi lại mã OTP",
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              child: const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "Nhớ mật khẩu? "),
                    TextSpan(
                      text: "Đăng nhập",
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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

  Widget _buildMobileLayout() {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.brandPrimary,
      body: Column(
        children: [
          const SizedBox(height: 40),
          Center(child: Image.asset('assets/Logo.png', width: 180)),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: _buildFormContent(h, w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebLayout() {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: AppColors.brandPrimary,
              padding: const EdgeInsets.all(60),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/Logo.png', width: 250),
                    const SizedBox(height: 30),
                    const Text(
                      "Đặt lại mật khẩu",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Vui lòng điền thông tin bên phải.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(60),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 8)),
                  ],
                ),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: _buildFormContent(700, 500),
                  ),
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
    return w > 800 ? _buildWebLayout() : _buildMobileLayout();
  }
}