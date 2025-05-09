import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:danentang/models/user_model.dart';
import 'package:danentang/Screens/Customer/Payment/shipping_selection_screen.dart';
import 'package:danentang/Screens/Customer/Payment/voucher_selection_screen.dart';
import 'package:danentang/models/ship.dart';
import 'package:danentang/models/voucher.dart';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final double total;

  const PaymentScreen({super.key, required this.products, required this.total});

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
    selectedShippingMethod = ShippingMethod(name: 'Economy', estimatedArrival: '25 August 2023', price: 20000);
  }

  void _showNoteDialog() async {
    final TextEditingController noteController = TextEditingController(text: sellerNote);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Lời nhắn liên hệ với Shop'),
          content: TextField(
            controller: noteController,
            decoration: const InputDecoration(
              hintText: 'Nhập lời nhắn cho người bán...',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  sellerNote = noteController.text.isNotEmpty ? noteController.text : null;
                });
                Navigator.pop(context);
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);
    final double subtotal = widget.products.fold(0.0, (sum, item) => sum + (item['product'].price * item['quantity']));
    final double deliveryCharge = selectedShippingMethod?.price ?? 20000;
    double discount = 0.0;

    if (selectedVoucher != null) {
      if (selectedVoucher!.discount < 1) {
        // Percentage discount
        discount = subtotal * selectedVoucher!.discount;
      } else {
        // Fixed amount discount
        discount = selectedVoucher!.discount;
      }
    }

    final double total = subtotal + deliveryCharge - discount;

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
                        user.address ?? 'No address provided',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.edit, color: Colors.grey),
              ],
            ),
            const Divider(height: 32),
            const Text(
              'Danh sách hàng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...widget.products.map((item) {
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
                              item['product'].name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Color: ${item['color']}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              'Qty: ${item['quantity']}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₫${(item['product'].price * item['quantity']).toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const Divider(height: 32),
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
            const Text(
              'Phương thức vận chuyển',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(selectedShippingMethod?.name ?? 'Economy'),
                subtitle: Text(selectedShippingMethod?.estimatedArrival ?? '25 August 2023'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final selected = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShippingSelectionScreen(),
                    ),
                  );
                  if (selected != null) {
                    setState(() {
                      selectedShippingMethod = selected;
                    });
                  }
                },
              ),
            ),
            const Divider(height: 32),
            const Text(
              'Hoàn tất Voucher',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(selectedVoucher?.code ?? 'Mời bạn nhập mã giảm giá hoặc chọn mã top deal'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final selected = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VoucherSelectionScreen(),
                    ),
                  );
                  if (selected != null) {
                    setState(() {
                      selectedVoucher = selected;
                    });
                  }
                },
              ),
            ),
            const Divider(height: 32),
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
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value!;
                        });
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.credit_card, color: Colors.blue),
                    title: const Text('Credit Card'),
                    trailing: Radio<String>(
                      value: 'Credit Card',
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value!;
                        });
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.money, color: Colors.yellow),
                    title: const Text('Cash'),
                    trailing: Radio<String>(
                      value: 'Cash',
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal'),
                        Text('₫${subtotal.toStringAsFixed(0)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Discount'),
                        Text('₫${discount.toStringAsFixed(0)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Delivery Charges'),
                        Text('₫${deliveryCharge.toStringAsFixed(0)}'),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₫${total.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Return shipping, payment method, seller note, and voucher
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
}