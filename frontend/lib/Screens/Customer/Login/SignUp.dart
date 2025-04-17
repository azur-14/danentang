import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../constants/colors.dart';
import '../Login/Login_Screen.dart';

class Signup extends StatefulWidget {
  final String email;
  const Signup({required this.email, super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final addressController = TextEditingController();

  bool isLoading = false;

  Future<void> registerUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu không khớp')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('http://localhost:5012/api/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': widget.email,
        'fullName': nameController.text,
        'password': passwordController.text,
        'addressLine1': addressController.text,
        'addressLine2': '',
        'city': 'Hanoi',
        'state': 'HN',
        'zipCode': '10000',
        'country': 'Vietnam',
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công!')),
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen(email: widget.email)),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thất bại: ${response.body}')),
      );
    }
  }

  // Widget xây dựng các trường nhập liệu cho Signup
  Widget _buildTextField(String hintText, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? const Icon(Icons.remove_red_eye_outlined, color: Colors.black26)
            : null,
      ),
    );
  }

  /// Layout cho Mobile (Android): sử dụng thiết kế dạng cột như phiên bản ban đầu,
  /// với logo phóng to và card đăng ký có nền trắng.
  Widget _buildMobileLayout() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField("Enter your name *", nameController),
                    const SizedBox(height: 15),
                    _buildTextField("Enter your password *", passwordController, isPassword: true),
                    const SizedBox(height: 15),
                    _buildTextField("Enter your password again *", confirmPasswordController, isPassword: true),
                    const SizedBox(height: 15),
                    _buildTextField("Enter your address *", addressController),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.07,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                          "Register",
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black54),
                            children: [
                              TextSpan(text: "Already have an account? "),
                              TextSpan(
                                text: "Log in now.",
                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  /// Layout cho Web: giao diện chia đôi. Bên trái hiển thị logo và slogan, bên phải chứa form đăng ký.
  Widget _buildWebLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Bên trái: chỉ hiển thị logo và slogan trên nền AppColors.brandPrimary.
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
                      "Welcome to Shopping App",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Discover exclusive deals and experience a new way to shop online.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: Colors.white70, height: 1.3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bên phải: Card chứa form đăng ký/đăng nhập với nền trắng.
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
                        _buildTextField("Enter your name *", nameController),
                        const SizedBox(height: 15),
                        _buildTextField("Enter your password *", passwordController, isPassword: true),
                        const SizedBox(height: 15),
                        _buildTextField("Enter your password again *", confirmPasswordController, isPassword: true),
                        const SizedBox(height: 15),
                        _buildTextField("Enter your address *", addressController),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandSecondary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () {
                              final email = widget.email;
                              if (email.isNotEmpty) {
                                registerUser();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter your email')),
                                );
                              }
                            },
                            child: const Text(
                              "Register",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(color: Colors.black54),
                                children: [
                                  TextSpan(text: "Already have an account? "),
                                  TextSpan(
                                    text: "Log in now.",
                                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 800 ? _buildWebLayout() : _buildMobileLayout();
  }
}
