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
import 'package:danentang/Screens/Customer/Login/ChangePassword.dart';
import 'package:danentang/Screens/Customer/Login/Intro.dart';
import 'package:danentang/Screens/Customer/Product/test_product_details.dart';
import 'package:danentang/Screens/Manager/Support/customer_support.dart';
import 'package:danentang/Screens/Manager/DashBoard/MobileDashboard.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/Screens/Customer/Payment/order_success_screen.dart';
import 'package:danentang/Screens/Customer/Payment/payment_method_screen.dart';
import 'package:danentang/Screens/Customer/Payment/add_card_screen.dart';
import 'package:danentang/models/card_info.dart';
import 'package:danentang/models/ship.dart';
import 'package:danentang/models/voucher.dart';
import 'package:danentang/models/Address.dart';
import 'package:danentang/Screens/Customer/Order/MyOrdersScreen.dart';
import 'package:danentang/models/Order.dart';

final GoRouter router = GoRouter(
  initialLocation: '/homepage',
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

    /// Product listing & details
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductDetailsScreen(productId: ''),
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

    /// Payment Flow
    GoRoute(
      path: '/payment-method',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return PaymentMethodScreen(
          initialPaymentMethod: extra?['initialPaymentMethod'] ?? 'Credit Card',
          initialCard: extra?['initialCard'] as CardInfo?,
          cards: extra?['cards'] as List<CardInfo> ?? [],
        );
      },
    ),
    GoRoute(
      path: '/add-card',
      builder: (context, state) => const AddCardScreen(),
    ),
    GoRoute(
      path: '/order-success',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final address = extra['address'] as Address? ?? Address(
          receiverName: 'Unknown',
          phone: '0000000000',
          addressLine: 'N/A',
          commune: 'N/A',
          district: 'N/A',
          city: 'N/A',
          isDefault: false,
        );
        return OrderSuccessScreen(
          products: extra['products'] as List<Map<String, dynamic>>,
          total: extra['total'] as double,
          shippingMethod: extra['shippingMethod'] as ShippingMethod?,
          paymentMethod: extra['paymentMethod'] as String,
          sellerNote: extra['sellerNote'] as String?,
          voucher: extra['voucher'] as Voucher?,
          address: address,
          card: extra['card'] as CardInfo?,
          order: extra['order'] as Order?, // Pass the order
        );
      },
    ),

    /// Orders
    GoRoute(
      path: '/my-orders',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final orders = extra?['orders'] as List<Order>? ?? [];
        return MyOrdersScreen(orders: orders);
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