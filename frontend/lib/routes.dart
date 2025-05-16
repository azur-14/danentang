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
import 'package:shared_preferences/shared_preferences.dart';

import 'Screens/Customer/Home/sentiment_screen.dart';
import 'Screens/Customer/Login/ChangePassword.dart';
import 'Screens/Customer/Login/Intro.dart';
import 'Screens/Customer/Product/test_product_details.dart';
import 'Screens/Customer/Search/search_v2.dart';
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
  // Always land on the home page first
  initialLocation: '/sentiment',
  routes: [

    /// Splash / Intro
    GoRoute(
      path: '/intro',
      builder: (context, state) => const SplashScreen(),
    ),

    /// Home
    GoRoute(
      path: '/homepage',
      builder: (context, state) => const HomeScreen(),
    ),

    /// Login / Sign-Up
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
    GoRoute(
      path: '/change_password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    GoRoute(
      path: '/search',
      builder: (context, state) => const Searching(),
    ),

    GoRoute(
      path: '/sentiment',
      builder: (context, state) => const ReviewScreen(),
    ),

    /// Product listing & details
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductsScreen(),
    ),
    GoRoute(
      path: '/products/:title',
      builder: (context, state) {
        final title = state.pathParameters['title']!;
        final extra = state.extra as Map<String, dynamic>;
        return ProductListScreen(
          title: title,
          products: extra['products'] as List<Product>,
          isWeb: extra['isWeb'] as bool,
        );
      },
    ),
    GoRoute(
      name: 'product',
      path: '/product/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProductDetailsScreen(productId: id);
      },
    ),

    /// Cart / Checkout
    GoRoute(
      path: '/checkout',
      builder: (context, state) {
        return FutureBuilder<SharedPreferences>(
          future: SharedPreferences.getInstance(),
          builder: (ctx, snap) {
            if (!snap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final prefs = snap.data!;
            final token = prefs.getString('token');
            final isLoggedIn = token != null;
            final userId = isLoggedIn ? prefs.getString('userId') : null;
            return CartScreenCheckOut(
              isLoggedIn: isLoggedIn,
              userId: userId,
            );
          },
        );
      },
    ),

    /// User profile & settings
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileManagementScreen(),
    ),
    GoRoute(
      path: '/personal-info',
      builder: (context, state) => const ProfileManagementScreen(),
    ),
    GoRoute(
      path: '/account-settings',
      builder: (context, state) => const AccountSettingsScreen(),
    ),

    /// Manager dashboard & support
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
