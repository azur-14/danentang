import 'package:danentang/Screens/Customer/User/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:danentang/Screens/Customer/Home/home_screen.dart';
import 'package:danentang/Screens/Customer/Home/product_list_screen.dart';
import 'package:danentang/Screens/Customer/CheckOut/cart_screen.dart';
import 'package:danentang/Screens/Customer/Login/Login_Screen.dart';
import 'package:danentang/Screens/Customer/Login/Login_SignUp_Screen.dart';
import 'package:danentang/Screens/Customer/Login/SignUp.dart';
import 'package:danentang/Screens/Customer/User/profile_page.dart';
import 'package:danentang/Screens/Customer/User/personal_info_screen.dart';
import 'package:danentang/Screens/Customer/User/account_settings_screen.dart';

import 'Screens/Manager/Support/customer_support.dart';
import 'Screens/Manager/DashBoard/MobileDashboard.dart';
import 'models/product.dart';

class ProfileScreen extends StatelessWidget {
  final bool isLoggedIn;
  const ProfileScreen({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hồ sơ")),
      body: const Center(child: Text("Hồ sơ")),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: const Center(child: Text("Chat")),
    );
  }
}

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sản phẩm")),
      body: const Center(child: Text("Danh sách sản phẩm")),
    );
  }
}

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) {
        final isLoggedIn = state.extra as bool? ?? false;
        return CartScreenCheckOut(isLoggedIn: isLoggedIn, userId: userId);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) {
        final isLoggedIn = state.extra as bool? ?? false;
        return ProfileManagementScreen();
      },
    ),

    // Chat
    GoRoute(
      path: '/chat',
      builder: (context, state) => const ChatScreen(),
    ),

    // Products
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductsScreen(),
    ),
    GoRoute(
      path: '/products/:title',
      builder: (context, state) {
        final title = state.pathParameters['title']!;
        final extra = state.extra as Map<String, dynamic>;
        final products = extra['products'] as List<Product>;
        final isWeb = extra['isWeb'] as bool;
        return ProductListScreen(
          title: title,
          products: extra['products'] as List<Product>,
          isWeb: extra['isWeb'] as bool,
        );
      },
    ),

    GoRoute(
      name: 'product',                      // ← ADD THIS
      path: '/product/:id',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return ProductDetailsScreen(productId: productId);
      },
    ),


    // Login & SignUp
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/login-signup',
      builder: (context, state) => const LoginSignupScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const Signup(email: ""),
    ),

    // Profile Management (for mobile and web)
    GoRoute(
      path: '/personal-info',
      builder: (context, state) => const ProfileManagementScreen(),
    ),
    GoRoute(
      path: '/account-settings',
      builder: (context, state) => const AccountSettingsScreen(),
    ),

    //Manager
    GoRoute(
      path: '/manager-dashboard',
      builder: (context, state) => const MobileDashboard(),
    ),
    GoRoute(
      path: '/customer-service',
      builder: (context, state) => const Customer_Support(),
    ),
    GoRoute(
      path: '/manager-profile',
      builder: (context, state) => const ProfileManagementScreen(),
    ),
  ],
);