import 'package:flutter/material.dart';
import '../../../constants/colors.dart';
import 'package:danentang/Service/user_service.dart';
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
  final UserService _userService = UserService();

  bool isLoading = false;

  Future<void> registerUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu không khớp')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await _userService.register(
        email: widget.email,
        fullName: nameController.text.trim(),
        password: passwordController.text,
        addressLine1: addressController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công!')),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(email: widget.email),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thất bại: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildTextField(
      String hint,
      TextEditingController controller, {
        bool isPassword = false,
      }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
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
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sign Up",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField("Enter your name *", nameController),
                    const SizedBox(height: 15),
                    _buildTextField(
                        "Enter your password *", passwordController,
                        isPassword: true),
                    const SizedBox(height: 15),
                    _buildTextField(
                        "Enter password again *", confirmPasswordController,
                        isPassword: true),
                    const SizedBox(height: 15),
                    _buildTextField("Enter your address *", addressController),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: h * 0.07,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                            color: Colors.white)
                            : Text(
                          "Register",
                          style: TextStyle(
                            fontSize: w * 0.05,
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LoginScreen(email: widget.email),
                            ),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(color: Colors.black54),
                            children: [
                              TextSpan(text: "Already have an account? "),
                              TextSpan(
                                text: "Log in now.",
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
                        _buildTextField("Enter password again *", confirmPasswordController, isPassword: true),
                        const SizedBox(height: 15),
                        _buildTextField("Enter your address *", addressController),
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandSecondary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: isLoading ? null : registerUser,
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              "Register",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LoginScreen(email: widget.email),
                                ),
                              );
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
    final w = MediaQuery.of(context).size.width;
    return w > 800 ? _buildWebLayout() : _buildMobileLayout();
  }
}
