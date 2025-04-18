import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MobileNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isLoggedIn;

  const MobileNavigationBar({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Chat'),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        onItemTapped(index);
        if (index == 1) {
          context.go('/cart', extra: isLoggedIn);
        } else if (index == 0) {
          context.go('/');
        }
      },
    );
  }
}