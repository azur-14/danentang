import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../Widget/Footer/footer_into.dart';
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF211463),
      body: Column(
        children: [
          const SizedBox(height: 80),
          Center(child: Image.asset('assets/Logo.png', width: 150)),
          const SizedBox(height: 10),
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
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight - 180,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField("Enter your name *", nameController),
                        const SizedBox(height: 15),
                        _buildPasswordField("Enter your password *", passwordController),
                        const SizedBox(height: 15),
                        _buildPasswordField("Enter your password again *", confirmPasswordController),
                        const SizedBox(height: 15),
                        _buildTextField("Enter your address *", addressController),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          height: screenHeight * 0.07,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : registerUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8204FF),
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
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black54),
                                children: const [
                                  TextSpan(text: "Already have an account? "),
                                  TextSpan(
                                    text: "Log in now.",
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        const AppFooter(),
                        const SizedBox(height: 10),
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

  Widget _buildTextField(String hintText, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField(String hintText, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: const Icon(Icons.remove_red_eye_outlined, color: Colors.black26),
      ),
    );
  }
}
