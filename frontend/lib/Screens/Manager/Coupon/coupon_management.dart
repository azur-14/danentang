import 'package:flutter/material.dart';

class Coupon_Management extends StatelessWidget {
  const Coupon_Management({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return const MobileCouponScreen();
          } else {
            return const WebCouponScreen();
          }
        },
      ),
    );
  }
}

//==================//
// Mobile Layout
//==================//
class MobileCouponScreen extends StatelessWidget {
  const MobileCouponScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).maybePop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).maybePop();
            },
          ),
          title: const Text(
            "Coupon Management",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          actions: const [
            Icon(Icons.more_horiz, color: Colors.black),
            SizedBox(width: 10),
          ],
        ),
        backgroundColor: Colors.white,
        body: const CouponContent(),
        bottomNavigationBar: BottomNavigationBar(
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
        ),
      ),
    );
  }
}

//==================//
// Web Layout
//==================//
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

//==================//
// Nội dung chính
//==================//
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

//==================//
// Coupon Item
//==================//
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

//==================//
// Text Field Widget
//==================//
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