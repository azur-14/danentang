import 'package:danentang/Widget/discount_banner.dart';
import 'package:flutter/material.dart';
import '../../../../Widget/greeting_header.dart';
import '../../../../widget/search_bar.dart';
import '../../../../widget/category_chips.dart';
import '../../../../widget/featured_products.dart';
import '../../../../widget/discount_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              GreetingHeader(),
              SizedBox(height: 20),
              SearchBarWidget(),
              SizedBox(height: 20),
              CategoryChips(),
              SizedBox(height: 20),
              // DiscountBanner(),
              // SizedBox(height: 20),
              FeaturedProducts(),
            ],
          ),
        ),
      ),
    );
  }
}