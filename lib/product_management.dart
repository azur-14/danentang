import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:manager/add_product.dart';
import 'package:manager/delete_product.dart';

void main() {
  runApp(Product_Management());
}

class Product_Management extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProductManagementScreen(),
    );
  }
}

class ProductManagementScreen extends StatefulWidget {
  @override
  _ProductManagementScreenState createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Product Management',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProductSection('Latest Product', 'View All'),
          _buildProductItem('Laptop ASUS', 'Color: Grey, AA - 07 - 902', 200),
          SizedBox(height: 10),
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildProductSection(String title, String actionText) {
    return Container(
      color: Colors.grey.shade300,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          if (actionText.isNotEmpty)
            TextButton(
              onPressed: () {},
              child: Text(actionText, style: TextStyle(color: Colors.blue)),
            ),
        ],
      ),
    );
  }

  Widget _buildProductItem(String name, String details, double price) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(10),
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
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(details, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Text('\$${price.toStringAsFixed(1)}',
              style: TextStyle(fontWeight: FontWeight.bold)),
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
          // Thêm logic xử lý khi nhấn Edit Product
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
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: Icon(icon, color: Colors.black),
        label: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: onTap,
      ),
    );
  }
}