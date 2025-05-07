import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:danentang/Screens/Manager/Product/add_product.dart';
import 'package:danentang/Screens/Manager/Product/delete_product.dart';
import 'package:flutter/foundation.dart';
import 'package:danentang/widgets/Footer/mobile_navigation_bar.dart';

class Product_Management extends StatelessWidget {
  const Product_Management({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProductManagementScreen();
  }
}

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  _ProductManagementScreenState createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: !kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android)
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        )
            : null,
        title: const Text(
          'Quản lý Sản phẩm',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildProductSection('Sản phẩm mới nhất', 'Xem tất cả'),
                _buildProductItem('Laptop ASUS', 'Color: Grey, AA - 07 - 902', 200),
                const SizedBox(height: 10),
                _buildProductSection('Danh Sách Sản Phẩm Được Bổ Sung', ''),
                ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildProductItem('Laptop Dell', 'Color: Black, BB - 12 - 345', 300),
                    _buildProductItem('MacBook Pro', 'Color: Silver, CC - 78 - 910', 1500),
                  ],
                ),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android)
          ? MobileNavigationBar(
        selectedIndex: _currentIndex,
        onItemTapped: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        isLoggedIn: true,
        role:'manager',
      )
          : null,
    );
  }

  Widget _buildProductSection(String title, String actionText) {
    return Container(
      color: Colors.grey.shade300,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (actionText.isNotEmpty)
            TextButton(
              onPressed: () {},
              child: Text(actionText, style: const TextStyle(color: Colors.blue)),
            ),
        ],
      ),
    );
  }

  Widget _buildProductItem(String name, String details, double price) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(details, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Text('\$${price.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _buildActionButton('Thêm Sản phẩm mới', FontAwesomeIcons.boxOpen, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewProductScreen()),
          );
        }),
        _buildActionButton('Sửa Sản phẩm', FontAwesomeIcons.pen, () {
          // TODO: xử lý edit product
        }),
        _buildActionButton('Xóa Sản phẩm', FontAwesomeIcons.trash, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SuccessScreen()),
          );
        }),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(icon, color: Colors.black),
        label: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        onPressed: onTap,
      ),
    );
  }
}