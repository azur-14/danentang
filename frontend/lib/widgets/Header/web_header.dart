import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MobileHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoggedIn;
  final String userName;

  const MobileHeader({required this.isLoggedIn, required this.userName});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Icon(Icons.diamond, color: Colors.purple, size: 20),
          SizedBox(width: 8),
          Text(
            "Hello $userName",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: Icon(Icons.shopping_cart, color: Colors.black),
              onPressed: () {
                context.go('/cart', extra: isLoggedIn);
              },
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  "1",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        Stack(
          children: [
            IconButton(
              icon: Icon(Icons.message, color: Colors.black),
              onPressed: () {},
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  "1",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}