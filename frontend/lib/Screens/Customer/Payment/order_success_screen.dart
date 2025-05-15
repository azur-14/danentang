import 'package:flutter/material.dart';
import 'package:danentang/models/ship.dart';
import 'package:danentang/models/voucher.dart';
import 'package:danentang/models/Address.dart';
import 'package:danentang/models/card_info.dart';
import 'package:danentang/Screens/Customer/Order/MyOrdersScreen.dart'; // Import new screen
import 'package:danentang/models/Order.dart'; // Import Order model

class OrderSuccessScreen extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final double total;
  final ShippingMethod? shippingMethod;
  final String paymentMethod;
  final String? sellerNote;
  final Voucher? voucher;
  final Address? address;
  final CardInfo? card;
  final Order? order; // Add order parameter

  const OrderSuccessScreen({
    super.key,
    required this.products,
    required this.total,
    this.shippingMethod,
    required this.paymentMethod,
    this.sellerNote,
    this.voucher,
    this.address,
    this.card,
    this.order,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;
    final contentWidth = isWeb ? 800.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: isWeb
          ? null
          : AppBar(
        title: const Text('Đặt hàng thành công', style: TextStyle(color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: contentWidth),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF38B2AC),
                  size: 100,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Đặt hàng thành công!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chi tiết đơn hàng',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
                        ),
                        const SizedBox(height: 8),
                        Text('Tổng cộng: ₫${total.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF2D3748))),
                        const SizedBox(height: 8),
                        Text('Phương thức thanh toán: $paymentMethod', style: const TextStyle(color: Color(0xFF2D3748))),
                        if (paymentMethod == 'Credit Card' && card != null) ...[
                          const SizedBox(height: 8),
                          Text('Thẻ: ${card!.cardNumber}', style: const TextStyle(color: Color(0xFF2D3748))),
                        ],
                        if (shippingMethod != null) ...[
                          const SizedBox(height: 8),
                          Text('Phương thức vận chuyển: ${shippingMethod!.name}', style: const TextStyle(color: Color(0xFF2D3748))),
                          Text('Ước tính giao hàng: ${shippingMethod!.estimatedArrival}', style: const TextStyle(color: Color(0xFF2D3748))),
                        ],
                        if (address != null) ...[
                          const SizedBox(height: 8),
                          const Text('Địa chỉ giao hàng:', style: TextStyle(color: Color(0xFF2D3748))),
                          Text(
                            [
                              address?.addressLine,
                              address?.commune,
                              address?.district,
                              address?.city,
                            ].where((part) => part != null && part.isNotEmpty).join(', '),
                            style: const TextStyle(color: Color(0xFF718096)),
                          ),
                        ] else ...[
                          const SizedBox(height: 8),
                          const Text('Địa chỉ giao hàng: Chưa có thông tin', style: TextStyle(color: Color(0xFF718096))),
                        ],
                        if (sellerNote != null) ...[
                          const SizedBox(height: 8),
                          Text('Lời nhắn cho người bán: $sellerNote', style: const TextStyle(color: Color(0xFF2D3748))),
                        ],
                        if (voucher != null) ...[
                          const SizedBox(height: 8),
                          Text('Mã giảm giá: ${voucher!.code}', style: const TextStyle(color: Color(0xFF2D3748))),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyOrdersScreen(orders: order != null ? [order!] : []), // Pass the current order
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A4FCF),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                    'Đến đơn hàng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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