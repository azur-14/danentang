import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';

class CouponManagement extends StatelessWidget {
  const CouponManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveCouponScreen();
  }
}

class ResponsiveCouponScreen extends StatefulWidget {
  const ResponsiveCouponScreen({super.key});

  @override
  State<ResponsiveCouponScreen> createState() => _ResponsiveCouponScreenState();
}

class _ResponsiveCouponScreenState extends State<ResponsiveCouponScreen> {
  int _selectedIndex = 0;
  bool _isSelectedAll = false;
  List<bool> _selectedCoupons = List.generate(3, (_) => false); // for tracking selected coupons

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleSelectAll() {
    setState(() {
      _isSelectedAll = !_isSelectedAll;
      _selectedCoupons = List.generate(3, (_) => _isSelectedAll);
    });
  }

  void _editAll() {
    // Handle edit all logic here
    print("Edit all selected coupons");
  }

  void _deleteAll() {
    // Handle delete all logic here
    print("Delete all selected coupons");
  }

  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return MobileCouponScreen(
              onBackPressed: () {
                Navigator.of(context).maybePop();
              },
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              isLoggedIn: true,
              onSelectAll: _toggleSelectAll,
              onEditAll: _editAll,
              onDeleteAll: _deleteAll,
              isSelectedAll: _isSelectedAll,
            );
          } else {
            return const WebCouponScreen();
          }
        },
      ),
    );
  }
}

class MobileCouponScreen extends StatelessWidget {
  final VoidCallback onBackPressed;
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isLoggedIn;
  final VoidCallback onSelectAll;
  final VoidCallback onEditAll;
  final VoidCallback onDeleteAll;
  final bool isSelectedAll;

  const MobileCouponScreen({
    super.key,
    required this.onBackPressed,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.isLoggedIn,
    required this.onSelectAll,
    required this.onEditAll,
    required this.onDeleteAll,
    required this.isSelectedAll,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: onBackPressed,
        ),
        title: const Text(
          "Quản lý Mã giảm giá",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'select_all') {
                onSelectAll();
              } else if (value == 'edit_all') {
                onEditAll();
              } else if (value == 'delete_all') {
                onDeleteAll();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'select_all',
                  child: Text(isSelectedAll ? 'Bỏ chọn tất cả' : 'Chọn tất cả'),
                ),
                const PopupMenuItem<String>(
                  value: 'edit_all',
                  child: Text('Sửa tất cả'),
                ),
                const PopupMenuItem<String>(
                  value: 'delete_all',
                  child: Text('Xóa tất cả'),
                ),
              ];
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      backgroundColor: Colors.white,
      body: const CouponContent(),
      bottomNavigationBar: MobileNavigationBar(
        selectedIndex: selectedIndex,
        onItemTapped: onItemTapped,
        isLoggedIn: isLoggedIn,
        role: 'manager',
      ),
    );
  }
}

class WebCouponScreen extends StatelessWidget {
  const WebCouponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Quản lý Mã giảm giá",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.more_horiz, color: Colors.black),
          SizedBox(width: 10),
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          width: 800,
          child: const CouponContent(),
        ),
      ),
    );
  }
}

class CouponContent extends StatelessWidget {
  const CouponContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: List.generate(3, (index) => CouponItem(index: index)),
        ),
        const SizedBox(height: 20),
        const Text(
          "Mã giảm giá mới",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),
        const CouponTextField(label: "Tên Mã Giảm Giá"),
        const CouponTextField(label: "Giá Trị Mã Giảm Giá"),
        const CouponTextField(label: "Ngày Tạo"),
        const CouponTextField(label: "Ký Tự Mã Giảm"),
        const CouponTextField(label: "Số Lần Sử Dụng"),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Tạo Mã Giảm Giá",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class CouponItem extends StatelessWidget {
  final int index;
  const CouponItem({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        // Handle long press to edit or delete
        print("Long pressed on coupon $index");
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Image.asset('assets/Manager/Coupon/coupon1.jpg', width: 60, height: 60),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Giảm tối đa 100K",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text("Mua đơn hàng trị giá 200K", style: TextStyle(color: Colors.black, fontSize: 14)),
                  Text("Đã sử dụng: 89%", style: TextStyle(color: Colors.black54, fontSize: 12)),
                  Text("Số lần sử dụng: 10 (đã dùng 9 lần)", style: TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ),
            const Text(
              "Lấy mã",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class CouponTextField extends StatelessWidget {
  final String label;
  const CouponTextField({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
    );
  }
}