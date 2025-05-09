import 'package:flutter/material.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';
import 'package:danentang/Service/product_service.dart';
// lib/Screens/Manager/Product/delete_product.dart

import 'package:flutter/material.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/Service/product_service.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';

class Delete_Product extends StatefulWidget {
  final Product product;
  const Delete_Product({Key? key, required this.product}) : super(key: key);

  @override
  State<Delete_Product> createState() => _Delete_ProductState();
}

class _Delete_ProductState extends State<Delete_Product>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation, _scaleAnimation;
  bool _deleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();

    _performDelete();
  }

  Future<void> _performDelete() async {
    // 1) Call the delete API
    await ProductService.deleteProduct(widget.product.id);

    // 2) Show the success animation
    setState(() => _deleted = true);

    // 3) Wait a moment so user sees it
    await Future.delayed(const Duration(seconds: 1));

    // 4) Pop back to the management screen, passing "true" to indicate deletion
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _deleted
            ? FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.check, size: 60, color: Colors.white),
                ),
                SizedBox(height: 20),
                Text(
                  "Xóa Sản phẩm\nThành công!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Trở về danh sách để tiếp tục quản lý",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        )
            : const CircularProgressIndicator(),
      ),
      bottomNavigationBar: isMobile
          ? MobileNavigationBar(
        selectedIndex: 0,
        onItemTapped: (_) {},
        isLoggedIn: true,
        role: 'manager',
      )
          : null,
    );
  }
}
