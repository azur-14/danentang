import 'package:flutter/material.dart';
import '../../../../Widget/Footer/footer_into.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'Login_Screen.dart';
import 'SignUp.dart';

class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final emailController = TextEditingController();

  void checkEmailAndNavigate(BuildContext context, String email) async {
    final url = Uri.parse('http://localhost:5012/api/auth/check-email?email=$email');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final exists = json['exists'];

      if (exists == true) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen(email: email)),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Signup(email: email)),
        );
      }
    } else {
      print("Lỗi khi gọi API: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
                    minHeight: screenHeight - 180, // Chiều cao tối thiểu
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Sign Up", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                        const SizedBox(height: 10),
                        Wrap(
                          children: [
                            const Text("By continuing, I agree to the ", style: TextStyle(color: Colors.black54)),
                            GestureDetector(
                              onTap: () {},
                              child: const Text("Terms of Use", style: TextStyle(color: Color(0xFF642FBF), fontWeight: FontWeight.bold)),
                            ),
                            const Text(" & "),
                            GestureDetector(
                              onTap: () {},
                              child: const Text("Privacy Policy", style: TextStyle(color: Color(0xFF642FBF), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8204FF),
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
                            child: const Text("Continue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Spacer(), // đẩy footer xuống đáy nếu có khoảng trống
                        Center(child: AppFooter()),
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
}
