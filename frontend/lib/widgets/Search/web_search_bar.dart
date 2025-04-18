import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:danentang/constants/colors.dart';

class WebSearchBar extends StatelessWidget {
  final bool isLoggedIn;

  const WebSearchBar({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: [
          Text(
            "HoaLaHe",
            style: TextStyle(
              color: AppColors.primaryPurple,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 32),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Container(
                  margin: EdgeInsets.only(left: 8, right: 8),
                  child: CircleAvatar(
                    radius: 16,
                    child: Icon(
                      Icons.search,
                      color: AppColors.primaryPurple,
                      size: 20,
                    ),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.lightGrey,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, size: 32),
            onPressed: () {
              context.go('/cart', extra: isLoggedIn);
            },
          ),
        ],
      ),
    );
  }
}