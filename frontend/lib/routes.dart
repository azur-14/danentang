import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:danentang/Screens/Customer/Home/home_screen.dart';
import 'package:danentang/Screens/Customer/Home/cart_screen.dart';
import 'package:danentang/Screens/Customer/Home/checkout_screen.dart';
import 'package:danentang/Screens/Customer/Home/product_list_screen.dart';
import 'package:danentang/Screens/Customer/CheckOut/cart_screen.dart';
import 'models/product.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => CartScreenCheckOut(
        isLoggedIn: state.extra as bool? ?? false,
      ),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => CartScreenCheckOut(
        isLoggedIn: state.extra as bool? ?? false,
      ),
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) {
        final isLoggedIn = state.extra as bool;
        return CartScreen(isLoggedIn: isLoggedIn);
      },
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
          products: products,
          isWeb: isWeb,
        );
      },
    ),
  ],
);