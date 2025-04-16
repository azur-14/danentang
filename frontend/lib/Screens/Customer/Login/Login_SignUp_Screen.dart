import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../constants/colors.dart';
import 'Login_Screen.dart';
import 'SignUp.dart';
import '../../../../Widget/Footer/footer_into.dart';


class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _cardFadeAnimation;

  // Hàm gọi API và điều hướng sang Login/Signup
  void checkEmailAndNavigate(BuildContext context, String email) async {
    final url = Uri.parse('http://localhost:5012/api/auth/check-email?email=$email');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final exists = jsonData['exists'];
      if (exists == true) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(email: email)));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (context) => Signup(email: email)));
      }
    } else {
      print("Lỗi khi gọi API: ${response.body}");
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _cardFadeAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    _animationController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Layout dành cho mobile (Android) – giữ nguyên cấu trúc ban đầu với vài cải tiến nhỏ
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: AppColors.brandPrimary,
      body: Column(
        children: [
          const SizedBox(height: 40), // Giảm khoảng trống phía trên
          Center(child: Image.asset('assets/Logo.png', width: 180)), // Phóng to logo
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                // Card nền trắng với bo góc phía trên
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              // SingleChildScrollView để nội dung cuộn nếu cần
              child: SingleChildScrollView(
                // Giảm padding bottom xuống còn 10
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: "Enter your email *",
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      children: [
                        const Text("By continuing, I agree to the ", style: TextStyle(color: Colors.black54)),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            "Terms of Use",
                            style: TextStyle(color: AppColors.brandAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Text(" & "),
                        GestureDetector(
                          onTap: () {},
                          child: const Text(
                            "Privacy Policy",
                            style: TextStyle(color: AppColors.brandAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandSecondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          final email = emailController.text.trim();
                          if (email.isNotEmpty) {
                            checkEmailAndNavigate(context, email);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter your email')),
                            );
                          }
                        },
                        child: const Text(
                          "Continue",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10), // Giảm khoảng cách giữa nút và Footer
                    Center(child: AppFooter()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  /// Layout dành cho web: giao diện chia đôi – bên trái là logo & tagline, bên phải là ô đăng nhập
  Widget _buildWebLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Bên trái: hiển thị logo & slogan ấn tượng với background gradient
          Expanded(
            flex: 1,
            child: Container(
              color: AppColors.brandPrimary,
              padding: const EdgeInsets.all(60),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/Logo.png', width: 200),
                    const SizedBox(height: 30),
                    const Text(
                      "Welcome to Hoalahe",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Experience a revolutionary digital solution\nand enjoy exclusive benefits.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: Colors.white70, height: 1.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bên phải: card chứa form đăng ký/đăng nhập với hiệu ứng Fade & Slide
          Expanded(
            flex: 1,
            child: Center(
              child: SlideTransition(
                position: _cardSlideAnimation,
                child: FadeTransition(
                  opacity: _cardFadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(60),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 30),
                            const Text(
                              "Sign Up",
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                hintText: "Enter your email *",
                                filled: true,
                                fillColor: Colors.grey.shade200,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Wrap(
                              children: [
                                const Text("By continuing, I agree to the ", style: TextStyle(color: Colors.black54)),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text("Terms of Use", style: TextStyle(color: AppColors.brandAccent, fontWeight: FontWeight.bold)),
                                ),
                                const Text(" & "),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text("Privacy Policy", style: TextStyle(color: AppColors.brandAccent, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brandSecondary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () {
                                  final email = emailController.text.trim();
                                  if (email.isNotEmpty) {
                                    checkEmailAndNavigate(context, email);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please enter your email')),
                                    );
                                  }
                                },
                                child: const Text(
                                  "Continue",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Center(child: AppFooter()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 800 ? _buildWebLayout() : _buildMobileLayout();
  }
}
