import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Màn hình khách hàng
import 'package:danentang/Screens/Customer/Home/home_screen.dart';
import 'package:danentang/Screens/Customer/Home/product_list_screen.dart';
import 'package:danentang/Screens/Customer/Home/sentiment_screen.dart';
import 'package:danentang/Screens/Customer/CheckOut/cart_screen.dart';
import 'package:danentang/Screens/Customer/Login/Login_Screen.dart';
import 'package:danentang/Screens/Customer/Login/Login_SignUp_Screen.dart';
import 'package:danentang/Screens/Customer/Login/SignUp.dart';
import 'package:danentang/Screens/Customer/Login/ChangePassword.dart';
import 'package:danentang/Screens/Customer/Login/Intro.dart';
import 'package:danentang/Screens/Customer/Product/test_product_details.dart';
import 'package:danentang/Screens/Customer/Search/search_v2.dart';
import 'package:danentang/Screens/Customer/User/profile_page.dart';
import 'package:danentang/Screens/Customer/User/personal_info_screen.dart';
import 'package:danentang/Screens/Customer/User/account_settings_screen.dart';
import 'package:danentang/Screens/Customer/Order/MyOrdersScreen.dart';
import 'package:danentang/Screens/Customer/Order/OrderDetailsScreen.dart';
import 'package:danentang/Screens/Customer/Order/ReviewScreen.dart';
import 'package:danentang/Screens/Customer/Payment/order_success_screen.dart';
import 'package:danentang/Screens/Customer/Payment/payment_method_screen.dart';
import 'package:danentang/Screens/Customer/Payment/add_card_screen.dart';
import 'package:danentang/Screens/Customer/Product/ProductCatalogPage.dart';

// Màn hình quản lý
import 'package:danentang/Screens/Manager/DashBoard/MobileDashboard.dart';
import 'package:danentang/Screens/Manager/DashBoard/WebDashboard.dart';
import 'package:danentang/Screens/Manager/Support/customer_support.dart';
import 'package:danentang/Screens/Manager/Support/customer_service.dart';
import 'package:danentang/Screens/Manager/User/user_list.dart';
import 'package:danentang/Screens/Manager/Product/product_management.dart';
import 'package:danentang/Screens/Manager/Product/add_product.dart';
import 'package:danentang/Screens/Manager/Product/delete_product.dart';
import 'package:danentang/Screens/Manager/Coupon/coupon_management.dart';
import 'package:danentang/Screens/Manager/Category/categories_management.dart';
import 'package:danentang/Screens/Manager/Order/order_list.dart';
import 'package:danentang/Screens/Manager/Report/oders_report.dart';
import 'package:danentang/Screens/Manager/Report/revenue_report.dart';
import 'package:danentang/Screens/Manager/Report/user_report.dart';

// Models
import 'package:danentang/models/product.dart';
import 'package:danentang/models/card_info.dart';
import 'package:danentang/models/ship.dart';
import 'package:danentang/models/voucher.dart';
import 'package:danentang/models/Address.dart';
import 'package:danentang/models/Order.dart';
import 'package:danentang/models/User.dart';

import 'Screens/Manager/Order/order_detail_screen.dart';
import 'Screens/Manager/Product/product_detail_screen.dart';

// Hàm kiểm tra vai trò admin
Future<bool> _isAdmin() async {
  final prefs = await SharedPreferences.getInstance();
  final role = prefs.getString('role');
  return role == 'admin';
}

// Hàm kiểm tra trạng thái đăng nhập
Future<bool> _isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  return token != null;
}

final GoRouter router = GoRouter(
  initialLocation: '/intro',
  redirect: (BuildContext context, GoRouterState state) async {
    final isLoggedIn = await _isLoggedIn();
    final isAdmin = await _isAdmin();
    final path = state.uri.toString();

    // Chuyển hướng người dùng chưa đăng nhập đến trang đăng nhập cho các tuyến bảo vệ
    if (!isLoggedIn &&
        (path.startsWith('/manager') ||
            path.startsWith('/profile') ||
            path.startsWith('/my-orders') ||
            path.startsWith('/checkout'))) {
      return '/login';
    }

    // Chuyển hướng người dùng không phải admin khỏi các tuyến quản lý
    if (!isAdmin && path.startsWith('/manager')) {
      return '/homepage';
    }

    // Chuyển hướng người dùng đã đăng nhập từ intro/login đến trang chủ
    if (isLoggedIn && (path == '/intro' || path == '/login' || path == '/login-signup')) {
      return '/homepage';
    }

    return null;
  },
  routes: [
    // Màn hình khởi động
    GoRoute(
      path: '/intro',
      builder: (context, state) => const SplashScreen(),
    ),

    // Tuyến xác thực
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
      path: '/change-password',
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return ForgotPasswordScreen(email: email);
      },
    ),

    // Tuyến khách hàng
    GoRoute(
      path: '/homepage',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const Searching(),
    ),
    GoRoute(
      path: '/sentiment',
      builder: (context, state) => const SentimentScreen(),
    ),

    // Tuyến sản phẩm
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductListScreen(
        title: 'Tất cả sản phẩm',
        products: [],
        isWeb: false,
      ),
    ),
    GoRoute(
      path: '/products/:title',
      builder: (context, state) {
        final title = state.pathParameters['title']!;
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ProductListScreen(
          title: title,
          products: extra['products'] as List<Product>? ?? [],
          isWeb: extra['isWeb'] as bool? ?? false,
        );
      },
    ),
    GoRoute(
      name: 'product',
      path: '/product/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProductDetailScreen(productId: id);
      },
    ),

    // Giỏ hàng & Thanh toán
    GoRoute(
      path: '/checkout',
      builder: (context, state) => FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return CartScreenCheckOut();
        },
      ),
    ),

    // danh mmu
    GoRoute(
      name: 'product-list',
      path: '/products/:categoryId',
      builder: (context, state) {
        final categoryId = state.pathParameters['categoryId']!;
        return ProductCatalogPage(categoryId: categoryId);
      },
    ),

    // Tuyến thanh toán
    GoRoute(
      path: '/payment-method',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return PaymentMethodScreen(
          initialPaymentMethod: extra['initialPaymentMethod'] ?? 'Thẻ tín dụng',
          initialCard: extra['initialCard'] as CardInfo?,
          cards: extra['cards'] as List<CardInfo>? ?? [],
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
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return OrderSuccessScreen(
          products: extra['products'] as List<Map<String, dynamic>>? ?? [],
          total: extra['total'] as double? ?? 0.0,
          shippingMethod: extra['shippingMethod'] as ShippingMethod?,
          paymentMethod: extra['paymentMethod'] ?? 'Không xác định',
          sellerNote: extra['sellerNote'],
          voucher: extra['voucher'] as Voucher?,
          address: extra['address'] as Address? ??
              Address(
                receiverName: 'Không xác định',
                phone: '0000000000',
                addressLine: 'N/A',
                commune: 'N/A',
                district: 'N/A',
                city: 'N/A',
                isDefault: false,
              ),
          card: extra['card'] as CardInfo?,
          order: extra['order'] as Order?,
        );
      },
    ),

    // Tuyến đơn hàng
    GoRoute(
      path: '/my-orders',
      builder: (context, state) => const MyOrdersScreen(),
    ),
    GoRoute(
      path: '/order-details/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return OrderDetailsScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/review/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return ReviewScreen(orderId: orderId);
      },
    ),
    GoRoute(
      path: '/reorder/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return const Placeholder(); // Thay bằng ReorderScreen khi triển khai
      },
    ),
    GoRoute(
      path: '/return/:orderId',
      builder: (context, state) {
        final orderId = state.pathParameters['orderId']!;
        return const Placeholder(); // Thay bằng ReturnScreen khi triển khai
      },
    ),

    // Tuyến hồ sơ
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

    // Tuyến trò chuyện
    GoRoute(
      path: '/chat',
      builder: (context, state) => const CustomerServiceScreen(),
    ),
    GoRoute(
      path: '/chat/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId'];
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final user = extra['user'] as User?;
        return CustomerServiceScreen(userId: userId);
      },
    ),

    // Tuyến quản lý
    GoRoute(
      path: '/manager',
      builder: (context, state) {
        final isWeb = MediaQuery.of(context).size.width >= 600;
        return isWeb ? const WebDashboard() : const MobileDashboard();
      },
      routes: [
        GoRoute(
          path: 'dashboard',
          builder: (context, state) {
            final isWeb = MediaQuery.of(context).size.width >= 600;
            return isWeb ? const WebDashboard() : const MobileDashboard();
          },
        ),
        GoRoute(
          path: 'dashboard',
          builder: (context, state) {
            final isWeb = MediaQuery.of(context).size.width >= 600;
            return isWeb ? const WebDashboard() : const MobileDashboard();
          },
        ),
        GoRoute(
          path: 'products',
          builder: (context, state) => const ProductManagementScreen(),
          routes: [
            GoRoute(
              path: ':id', // Admin product detail route
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ProductDetailScreenManager(productId: id); // Use admin screen
              },
            ),
            GoRoute(
              path: 'edit',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>? ?? {};
                return AddProductScreen(product: extra['product'] as Product?);
              },
            ),
            GoRoute(
              path: 'delete',
              builder: (context, state) {
                final extra = state.extra as Map<String, dynamic>? ?? {};
                return DeleteProductScreen(product: extra['product'] as Product);
              },
            ),
          ],
        ),
        GoRoute(
          path: 'coupons',
          builder: (context, state) => const CouponManagement(),
        ),
        GoRoute(
          path: 'categories',
          builder: (context, state) => const CategoriesManagement(),
        ),
        GoRoute(
          path: 'users',
          builder: (context, state) => const UserListScreen(),
        ),
        GoRoute(
          path: 'orders',
          builder: (context, state) => const OrderListScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final order = state.extra as Order;
                return OrderDetailScreen(order: order);
              },
            ),
          ],
        ),
        GoRoute(
          path: 'orders-report',
          builder: (context, state) => const OrdersReport(),
        ),
        GoRoute(
          path: 'revenue-report',
          builder: (context, state) => const RevenueReport(),
        ),
        GoRoute(
          path: 'user-report',
          builder: (context, state) => const UserReportScreen(),
        ),
        GoRoute(
          path: 'support',
          builder: (context, state) => const CustomerSupport(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const ProfileManagementScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Lỗi: Trang không tìm thấy - ${state.uri}'),
    ),
  ),
);