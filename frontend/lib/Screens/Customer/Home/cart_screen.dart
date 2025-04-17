import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final bool isLoggedIn;

  const CartScreen({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Your cart has: MacBook Air M1"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go('/checkout', extra: isLoggedIn);
              },
              child: Text("Proceed to Checkout"),
            ),
          ],
        ),
      ),
    );
  }
}