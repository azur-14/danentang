import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';
import 'package:danentang/models/Coupon.dart';
import 'package:danentang/Service/order_service.dart';

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
  final _codeCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  final _limitCtrl = TextEditingController();
  DateTime? _expiresAt;
  final _couponService = OrderService.instance;
  late Future<List<Coupon>> _couponFuture;
  List<Coupon> _coupons = [];

  @override
  void initState() {
    super.initState();
    _refreshCoupons();
  }

  void _refreshCoupons() {
    _couponFuture = _couponService.fetchAllCoupons();
    _couponFuture.then((data) => setState(() => _coupons = data));
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Future<bool> _onWillPop() async => true;

  Future<void> _createCoupon() async {
    // Validate inputs
    final code = _codeCtrl.text.trim();
    final discount = int.tryParse(_discountCtrl.text.trim());
    final usageLimit = int.tryParse(_limitCtrl.text.trim());

    // Validation checks
    if (code.isEmpty || code.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã giảm giá phải có ít nhất 5 ký tự')),
      );
      return;
    }

    if (discount == null || discount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giá trị giảm phải là số nguyên dương')),
      );
      return;
    }

    if (usageLimit == null || usageLimit <= 0 || usageLimit > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số lần sử dụng phải từ 1 đến 1000')),
      );
      return;
    }

    if (_expiresAt != null && _expiresAt!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ngày hết hạn phải là trong tương lai')),
      );
      return;
    }

    // Check if code is unique
    try {
      final existingCoupons = await _couponFuture;
      if (existingCoupons.any((c) => c.code.toLowerCase() == code.toLowerCase())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mã giảm giá đã tồn tại')),
        );
        return;
      }

      // Create coupon
      final coupon = Coupon(
        code: code,
        discountValue: discount,
        usageLimit: usageLimit,
        usageCount: 0,
        createdAt: DateTime.now(),
        orderIds: [],
      );

      await _couponService.createCoupon(coupon);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo mã giảm giá thành công')),
      );

      // Clear inputs
      _codeCtrl.clear();
      _discountCtrl.clear();
      _limitCtrl.clear();
      _expiresAt = null;
      _refreshCoupons();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null) setState(() => _expiresAt = picked);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return constraints.maxWidth < 600
              ? MobileCouponScreen(
            onBackPressed: () => Navigator.of(context).maybePop(),
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
            isLoggedIn: true,
            couponFuture: _couponFuture,
            codeCtrl: _codeCtrl,
            discountCtrl: _discountCtrl,
            limitCtrl: _limitCtrl,
            expiresAt: _expiresAt,
            onCreateCoupon: _createCoupon,
            onPickDate: _pickDate,
          )
              : WebCouponScreen(
            couponFuture: _couponFuture,
            codeCtrl: _codeCtrl,
            discountCtrl: _discountCtrl,
            limitCtrl: _limitCtrl,
            expiresAt: _expiresAt,
            onCreateCoupon: _createCoupon,
            onPickDate: _pickDate,
          );
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
  final Future<List<Coupon>> couponFuture;
  final TextEditingController codeCtrl, discountCtrl, limitCtrl;
  final DateTime? expiresAt;
  final VoidCallback onCreateCoupon;
  final VoidCallback onPickDate;

  const MobileCouponScreen({
    super.key,
    required this.onBackPressed,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.isLoggedIn,
    required this.couponFuture,
    required this.codeCtrl,
    required this.discountCtrl,
    required this.limitCtrl,
    required this.expiresAt,
    required this.onCreateCoupon,
    required this.onPickDate,
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
        actions: const [
          SizedBox(width: 10),
        ],
      ),
      backgroundColor: Colors.white,
      body: CouponContent(
        couponFuture: couponFuture,
        codeCtrl: codeCtrl,
        discountCtrl: discountCtrl,
        limitCtrl: limitCtrl,
        expiresAt: expiresAt,
        onCreateCoupon: onCreateCoupon,
        onPickDate: onPickDate,
      ),
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
  final Future<List<Coupon>> couponFuture;
  final TextEditingController codeCtrl, discountCtrl, limitCtrl;
  final DateTime? expiresAt;
  final VoidCallback onCreateCoupon;
  final VoidCallback onPickDate;

  const WebCouponScreen({
    super.key,
    required this.couponFuture,
    required this.codeCtrl,
    required this.discountCtrl,
    required this.limitCtrl,
    required this.expiresAt,
    required this.onCreateCoupon,
    required this.onPickDate,
  });

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
          SizedBox(width: 10),
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          width: 800,
          child: CouponContent(
            couponFuture: couponFuture,
            codeCtrl: codeCtrl,
            discountCtrl: discountCtrl,
            limitCtrl: limitCtrl,
            expiresAt: expiresAt,
            onCreateCoupon: onCreateCoupon,
            onPickDate: onPickDate,
          ),
        ),
      ),
    );
  }
}

class CouponContent extends StatelessWidget {
  final Future<List<Coupon>> couponFuture;
  final TextEditingController codeCtrl, discountCtrl, limitCtrl;
  final DateTime? expiresAt;
  final VoidCallback onCreateCoupon;
  final VoidCallback onPickDate;

  const CouponContent({
    super.key,
    required this.couponFuture,
    required this.codeCtrl,
    required this.discountCtrl,
    required this.limitCtrl,
    required this.expiresAt,
    required this.onCreateCoupon,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Danh sách mã giảm giá", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        FutureBuilder<List<Coupon>>(
          future: couponFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
            if (snapshot.hasError) return Text("Lỗi: ${snapshot.error}");
            final coupons = snapshot.data!;
            if (coupons.isEmpty) return const Text("Chưa có mã giảm giá.");
            return Column(
              children: coupons.map((c) => _buildCouponItem(context, c)).toList(),
            );
          },
        ),
        const Divider(height: 32),
        const Text("Tạo mã giảm giá mới", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        TextField(
          controller: codeCtrl,
          decoration: const InputDecoration(
            labelText: 'Mã giảm giá (ít nhất 5 ký tự)',
            border: OutlineInputBorder(),
            errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          ),
          maxLength: 20, // Giới hạn độ dài mã
        ),
        const SizedBox(height: 10),
        TextField(
          controller: discountCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Giá trị giảm (VND, số nguyên dương)',
            border: OutlineInputBorder(),
            errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: limitCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Số lần sử dụng (1-1000)',
            border: OutlineInputBorder(),
            errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                expiresAt != null
                    ? 'Hạn dùng: ${DateFormat('dd/MM/yyyy').format(expiresAt!)}'
                    : 'Không giới hạn ngày',
              ),
            ),
            ElevatedButton(
              onPressed: onPickDate,
              child: const Text('Chọn ngày'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: onCreateCoupon,
          child: const Text("Tạo mã giảm giá"),
        ),
      ],
    );
  }

  Widget _buildCouponItem(BuildContext context, Coupon c) {
    final percentUsed = (c.usageCount / c.usageLimit * 100).clamp(0, 100).round();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.card_giftcard, color: Colors.purple, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Mã: ${c.code}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Giảm: ${c.discountValue}đ"),
                Text("Đã dùng: ${c.usageCount}/${c.usageLimit} (${percentUsed}%)"),
                if (c.orderIds.isNotEmpty)
                  Text("Đơn đã dùng: ${c.orderIds.join(', ')}", style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirmed = await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Xác nhận xóa"),
                  content: Text("Bạn có chắc muốn xóa mã '${c.code}' không?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Hủy")),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Xóa")),
                  ],
                ),
              );
              if (confirmed == true) {
                await OrderService.instance.deleteCoupon(c.id!);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xóa mã")));
                // Refresh coupons after deletion
                context.findAncestorStateOfType<_ResponsiveCouponScreenState>()?._refreshCoupons();
              }
            },
          ),
        ],
      ),
    );
  }
}