import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:danentang/models/User.dart';
import 'package:danentang/Screens/Customer/Payment/shipping_selection_screen.dart';
import 'package:danentang/Screens/Customer/Payment/voucher_selection_screen.dart';
import 'package:danentang/models/ship.dart';
import 'package:danentang/models/voucher.dart';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final double total;

  const PaymentScreen({
    super.key,
    required this.products,
    required this.total,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  ShippingMethod? selectedShippingMethod;
  String selectedPaymentMethod = 'Credit Card';
  String? sellerNote;
  Voucher? selectedVoucher;

  @override
  void initState() {
    super.initState();
    // Default to Economy shipping
    selectedShippingMethod = ShippingMethod(
      name: 'Economy',
      estimatedArrival: '25 August 2023',
      price: 20000,
    );
  }

  void _showNoteDialog() async {
    final noteController = TextEditingController(text: sellerNote);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lời nhắn liên hệ với Shop'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Nhập lời nhắn cho người bán...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              setState(() {
                sellerNote = noteController.text.isNotEmpty ? noteController.text : null;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    // compute subtotal
    final subtotal = widget.products.fold<double>(
      0,
          (sum, item) => sum + (item['product'].price * item['quantity']),
    );

    // delivery charge
    final deliveryCharge = selectedShippingMethod?.price ?? 20000;

    // voucher discount
    double discount = 0;
    if (selectedVoucher != null) {
      if (selectedVoucher!.discount < 1) {
        discount = subtotal * selectedVoucher!.discount;
      } else {
        discount = selectedVoucher!.discount;
      }
    }

    // final total
    final total = subtotal + deliveryCharge - discount;

    // pick first address or fallback
    final addressLine = user.addresses.isNotEmpty
        ? user.addresses.first.addressLine
        : 'Chưa có địa chỉ';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Shipping Address ──
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.userName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        addressLine,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.edit, color: Colors.grey),
              ],
            ),
            const Divider(height: 32),

            // ── Product List ──
            const Text(
              'Danh sách hàng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...widget.products.map((item) {
              final product = item['product'];
              final qty = item['quantity'] as int;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.watch, size: 30)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Qty: $qty',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₫${(product.price * qty).toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const Divider(height: 32),

            // ── Seller Note ──
            const Text(
              'Lời nhắn liên hệ với Shop',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(sellerNote ?? 'Nhấn để thêm lời nhắn'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showNoteDialog,
              ),
            ),
            const SizedBox(height: 8),

            // ── Shipping Method ──
            const Text(
              'Phương thức vận chuyển',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(selectedShippingMethod?.name ?? ''),
                subtitle: Text(selectedShippingMethod?.estimatedArrival ?? ''),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final chosen = await Navigator.push<ShippingMethod>(
                    context,
                    MaterialPageRoute(builder: (_) => const ShippingSelectionScreen()),
                  );
                  if (chosen != null) setState(() => selectedShippingMethod = chosen);
                },
              ),
            ),
            const Divider(height: 32),

            // ── Voucher ──
            const Text(
              'Hoàn tất Voucher',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(selectedVoucher?.code ?? 'Chọn mã giảm giá'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final chosen = await Navigator.push<Voucher>(
                    context,
                    MaterialPageRoute(builder: (_) => VoucherSelectionScreen()),
                  );
                  if (chosen != null) setState(() => selectedVoucher = chosen);
                },
              ),
            ),
            const Divider(height: 32),

            // ── Payment Method ──
            const Text(
              'Chọn phương thức thanh toán',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.paypal, color: Colors.blue),
                    title: const Text('Paypal'),
                    trailing: Radio<String>(
                      value: 'Paypal',
                      groupValue: selectedPaymentMethod,
                      onChanged: (v) => setState(() => selectedPaymentMethod = v!),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.credit_card, color: Colors.blue),
                    title: const Text('Credit Card'),
                    trailing: Radio<String>(
                      value: 'Credit Card',
                      groupValue: selectedPaymentMethod,
                      onChanged: (v) => setState(() => selectedPaymentMethod = v!),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.money, color: Colors.green),
                    title: const Text('Cash'),
                    trailing: Radio<String>(
                      value: 'Cash',
                      groupValue: selectedPaymentMethod,
                      onChanged: (v) => setState(() => selectedPaymentMethod = v!),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),

            // ── Order Summary ──
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSummaryRow('Subtotal', subtotal),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Discount', discount),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Delivery', deliveryCharge),
                    const Divider(height: 16),
                    _buildSummaryRow('Total', total, isBold: true),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, {
                    'shippingMethod': selectedShippingMethod,
                    'paymentMethod': selectedPaymentMethod,
                    'sellerNote': sellerNote,
                    'voucher': selectedVoucher,
                    'total': total,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text(
                  'Đặt hàng',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: isBold ? const TextStyle(fontWeight: FontWeight.bold) : null),
        Text(
          '₫${amount.toStringAsFixed(0)}',
          style: isBold ? const TextStyle(fontWeight: FontWeight.bold) : null,
        ),
      ],
    );
  }
}
