import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:danentang/models/CartItem.dart';
import 'package:danentang/models/User.dart';
import 'package:danentang/models/Coupon.dart';
import 'package:danentang/models/Address.dart';
import 'package:danentang/models/OrderItem.dart';
import 'package:danentang/models/ShippingAddress.dart';
import 'package:danentang/widgets/Header/web_header.dart';
import 'package:danentang/Service/user_service.dart';
import 'package:uuid/uuid.dart';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final Coupon? voucher;
  final int loyaltyPointsToUse;

  const PaymentScreen({
    Key? key,
    required this.products,
    this.voucher,
    this.loyaltyPointsToUse = 0,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isLoggedIn = false;
  User? user;
  Address? shippingAddress;
  String guestName = '';
  String guestPhone = '';
  String guestAddress = '';

  @override
  void initState() {
    super.initState();
    _initUserAndAddress();
  }

  Future<void> _initUserAndAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final email = prefs.getString('email');
    if (token != null && email != null) {
      try {
        final u = await UserService().fetchUserByEmail(email);
        setState(() {
          isLoggedIn = true;
          user = u;
          if (u.addresses.isNotEmpty) {
            shippingAddress = u.addresses.firstWhere(
                  (a) => a.isDefault,
              orElse: () => u.addresses.first,
            );
          }
        });
      } catch (_) {
        setState(() {
          isLoggedIn = false;
        });
      }
    } else {
      setState(() {
        isLoggedIn = false;
      });
    }
  }

  double get shippingFee => 30000;
  double get subtotal => widget.products.fold<double>(
    0, (sum, item) => sum + (item['product'].price * item['quantity']),
  );
  double get voucherDiscount {
    if (widget.voucher == null) return 0.0;
    if (widget.voucher!.discountValue != null) {
      return subtotal - widget.voucher!.discountValue!;
    }
    return widget.voucher!.discountValue?.toDouble() ?? 0.0;
  }

  double get loyaltyDiscount => (widget.loyaltyPointsToUse * 1000);
  double get total => subtotal + shippingFee - voucherDiscount - loyaltyDiscount;

  void _placeOrder() {
    // Kiểm tra địa chỉ giao hàng
    if (!isLoggedIn) {
      if (guestName.isEmpty || guestPhone.isEmpty || guestAddress.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin giao hàng')),
        );
        return;
      }
      shippingAddress = Address(
        receiverName: guestName,
        phone: guestPhone,
        addressLine: guestAddress,
        city: '', district: '', commune: '', isDefault: true,
      );
    } else {
      if (shippingAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vui lòng chọn địa chỉ giao hàng')),
        );
        return;
      }
    }

    // Tạo OrderItems (nếu muốn gửi backend, xử lý tiếp ở đây)
    final List<OrderItem> orderItems = widget.products.map((item) {
      final product = item['product'];
      final qty = item['quantity'] as int;
      final variant = item['variant']?.toString() ?? 'Không có biến thể';
      return OrderItem(
        productId: product.id ?? const Uuid().v4(),
        productVariantId: null,
        productName: product.name,
        variantName: variant,
        quantity: qty,
        price: product.price,
      );
    }).toList();

    // Xử lý tiếp tạo Order gửi backend, hoặc show màn hình xác nhận
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Đặt hàng thành công!'),
        content: Text('Đơn hàng của bạn đã được ghi nhận.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isWeb
          ? null
          : AppBar(
        title: const Text('Thanh toán',
            style: TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            constraints: BoxConstraints(maxWidth: isWeb ? 700 : double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isWeb) ...[
                  WebHeader(isLoggedIn: isLoggedIn),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Địa chỉ giao hàng',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                if (isLoggedIn && shippingAddress != null)
                  Card(
                    child: ListTile(
                      title: Text(shippingAddress!.receiverName ?? 'Chưa có tên'),
                      subtitle: Text(
                        '${shippingAddress!.addressLine ?? ''}'
                            '${shippingAddress!.commune != null ? ', ${shippingAddress!.commune}' : ''}'
                            '${shippingAddress!.district != null ? ', ${shippingAddress!.district}' : ''}'
                            '${shippingAddress!.city != null ? ', ${shippingAddress!.city}' : ''}',
                      ),
                      trailing: Icon(Icons.check_circle, color: Colors.green),
                    ),
                  )
                else ...[
                  TextField(
                    decoration: InputDecoration(labelText: 'Tên người nhận'),
                    onChanged: (v) => guestName = v,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Số điện thoại'),
                    keyboardType: TextInputType.phone,
                    onChanged: (v) => guestPhone = v,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: 'Địa chỉ giao hàng'),
                    onChanged: (v) => guestAddress = v,
                  ),
                ],
                const SizedBox(height: 20),
                Text('Sản phẩm', style: TextStyle(fontWeight: FontWeight.bold)),
                ...widget.products.map((item) {
                  final product = item['product'];
                  final qty = item['quantity'];
                  final variant = item['variant'];
                  return ListTile(
                    leading: Icon(Icons.shopping_bag),
                    title: Text(product.name),
                    subtitle: Text('Số lượng: $qty'
                        '${variant != null ? '\nBiến thể: $variant' : ''}'),
                    trailing: Text('${(product.price * qty).toStringAsFixed(0)}đ'),
                  );
                }),
                Divider(),
                ListTile(
                  title: Text('Tạm tính'), trailing: Text('${subtotal.toStringAsFixed(0)}đ'),
                ),
                ListTile(
                  title: Text('Voucher'),
                  trailing: Text('-${voucherDiscount.toStringAsFixed(0)}đ'),
                ),
                ListTile(
                  title: Text('Điểm thưởng sử dụng'),
                  trailing: Text('-${loyaltyDiscount.toStringAsFixed(0)}đ'),
                ),
                ListTile(
                  title: Text('Phí vận chuyển'), trailing: Text('${shippingFee.toStringAsFixed(0)}đ'),
                ),
                Divider(),
                ListTile(
                  title: Text('Tổng cộng', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text('${total.toStringAsFixed(0)}đ', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5A4FCF),
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: _placeOrder,
                    child: Text('ĐẶT HÀNG', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
