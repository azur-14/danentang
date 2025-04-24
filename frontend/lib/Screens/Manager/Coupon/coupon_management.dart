import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CouponManagement extends StatefulWidget {
  const CouponManagement({super.key});

  @override
  State<CouponManagement> createState() => _CouponManagementState();
}

class _CouponManagementState extends State<CouponManagement> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      html.window.onBeforeUnload.listen((event) {
        event.preventDefault();
        (event as html.BeforeUnloadEvent).returnValue = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ResponsiveCouponScreen(),
    );
  }
}

class ResponsiveCouponScreen extends StatelessWidget {
  const ResponsiveCouponScreen({super.key});

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => const ExitConfirmationDialog(),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitConfirmation(context);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return MobileCouponScreen(onBackPressed: () async {
              bool shouldExit = await _showExitConfirmation(context);
              if (shouldExit) {
                Navigator.of(context).maybePop();
              }
            });
          } else {
            return const WebCouponScreen();
          }
        },
      ),
    );
  }
}

class ExitConfirmationDialog extends StatelessWidget {
  const ExitConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
    );
  }
}

class MobileCouponScreen extends StatelessWidget {
  final VoidCallback onBackPressed;
  const MobileCouponScreen({super.key, required this.onBackPressed});

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
          "Coupon Management",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.more_horiz, color: Colors.black),
          SizedBox(width: 10),
        ],
      ),
      backgroundColor: Colors.white,
      body: const CouponContent(),
      bottomNavigationBar: const BottomNavBar(),
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
        title: const Text(
          "Coupon Management",
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

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.black,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    );
  }
}

class CouponContent extends StatelessWidget {
  const CouponContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: List.generate(3, (index) => const CouponItem()),
            ),
            const SizedBox(height: 20),
            const Text(
              "New Coupon",
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
        ),
      ),
    );
  }
}

class CouponItem extends StatelessWidget {
  const CouponItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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