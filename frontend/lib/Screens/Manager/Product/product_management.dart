import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:danentang/Screens/Manager/Product/add_product.dart';
import 'package:danentang/Screens/Manager/Product/delete_product.dart';
import 'package:flutter/foundation.dart';

class Product_Management extends StatelessWidget {
  const Product_Management({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProductManagementScreen(),
    );
  }
}

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  _ProductManagementScreenState createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  int _currentIndex = 0;

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có chắc chắn muốn thoát khỏi màn hình này không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Không'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Có'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldExit = await _showExitConfirmation(context);
        return shouldExit;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Ngăn AppBar tự thêm nút back
          leading: !kIsWeb &&
                  (defaultTargetPlatform == TargetPlatform.iOS ||
                      defaultTargetPlatform == TargetPlatform.android)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () async {
                    bool shouldExit = await _showExitConfirmation(context);
                    if (shouldExit) {
                      Navigator.pop(context);
                    }
                  },
                )
              : null,
          title: const Text(
            'Product Management',
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
        body: Column(
          children: [
            _buildProductSection('Latest Product', 'View All'),
            _buildProductItem('Laptop ASUS', 'Color: Grey, AA - 07 - 902', 200),
            const SizedBox(height: 10),
            _buildProductSection('Danh Sách Sản Phẩm Được Bổ Sung', ''),
            Expanded(
              child: ListView(
                children: [
                  _buildProductItem(
                      'Laptop Dell', 'Color: Black, BB - 12 - 345', 300),
                  _buildProductItem(
                      'MacBook Pro', 'Color: Silver, CC - 78 - 910', 1500),
                ],
              ),
            ),
            _buildActionButtons(context),
          ],
        ),
        bottomNavigationBar: !kIsWeb &&
                (defaultTargetPlatform == TargetPlatform.iOS ||
                    defaultTargetPlatform == TargetPlatform.android)
            ? BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.purple,
                unselectedItemColor: Colors.grey,
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.history), label: 'History'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.notifications), label: 'Notifications'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.settings), label: 'Settings'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person), label: 'Profile'),
                ],
              )
            : null,
      ),
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
          Text('\$${price.toStringAsFixed(1)}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _buildActionButton('New Product', FontAwesomeIcons.boxOpen, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewProductScreen()),
          );
        }),
        _buildActionButton('Edit Product', FontAwesomeIcons.pen, () {
          // Logic edit
        }),
        _buildActionButton('Delete Product', FontAwesomeIcons.trash, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SuccessScreen()),
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