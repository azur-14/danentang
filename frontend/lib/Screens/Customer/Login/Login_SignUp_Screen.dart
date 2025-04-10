import 'package:flutter/material.dart';
import '../../../../Widget/Footer/footer_into.dart'; // Import Footer

class LoginSignupScreen extends StatelessWidget {
  const LoginSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xFF211463),
      body: SingleChildScrollView(  // Wrap the entire body in SingleChildScrollView
        child: Column(
          children: [
            const SizedBox(height: 80),

            // Logo ở giữa
            Center(
              child: Image.asset('assets/Logo.png', width: 150),
            ),

            const SizedBox(height: 10),

            // Form đăng ký
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.05),  // Adjusted height to make it flexible
                  Text(
                    "Sign-up",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                                    
                  // Ô nhập email
                  TextField(
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

                  // Điều khoản sử dụng
                  Row(
                    children: [
                      const Text(
                        "By continuing, I agree to the ",
                        style: TextStyle(color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          "Terms of Use",
                          style: TextStyle(color: Color(0xFF642FBF), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Text(" & "),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          "Privacy Policy",
                          style: TextStyle(color: Color(0xFF642FBF), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),

                  // Nút Continue
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8204FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Continue",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Hỗ trợ đăng nhập
                  Padding(
                    padding: const EdgeInsets.only(left: 5), // Thêm khoảng cách nếu cần
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "Have trouble logging in? Get help",
                        style: TextStyle(color: Color(0xFF642FBF), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),  // Add space between content and footer
                  
                  // Footer
                  Center(child: AppFooter()),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
