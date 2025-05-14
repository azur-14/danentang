import 'package:flutter/material.dart';
import 'package:danentang/models/User.dart';
import 'package:danentang/Screens/Customer/Payment/shipping_selection_screen.dart';
import 'package:danentang/Screens/Customer/Payment/voucher_selection_screen.dart';
import 'package:danentang/Screens/Customer/Payment/address_selection_screen.dart';
import 'package:danentang/Screens/Customer/Payment/payment_method_screen.dart';
import 'package:danentang/Screens/Customer/Payment/order_success_screen.dart';
import 'package:danentang/models/ship.dart';
import 'package:danentang/models/voucher.dart';
import 'package:danentang/models/Address.dart';
import 'package:danentang/models/card_info.dart';
import 'package:danentang/widgets/Header/web_header.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final double total;
  final User user;

  const PaymentScreen({
    super.key,
    required this.products,
    required this.total,
    required this.user,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  ShippingMethod? selectedShippingMethod;
  String selectedPaymentMethod = 'Credit Card';
  String? sellerNote;
  Voucher? selectedVoucher;
  Address? selectedAddress;
  bool _isHovered = false;
  List<CardInfo> cards = [];
  CardInfo? selectedCard;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    selectedShippingMethod = ShippingMethod(
      name: 'Tiết kiệm',
      estimatedArrival: DateTime.now().add(const Duration(days: 7)).toString().split(' ')[0], // 2025-05-21
      price: 20000,
    );
    selectedAddress = widget.user.addresses.firstWhere(
          (addr) => addr.isDefault,
      //orElse: () => widget.user.addresses.isNotEmpty ? widget.user.addresses.first : null,
    );
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cardsJson = await _storage.read(key: 'cards');
    if (cardsJson != null) {
      final List<dynamic> cardsList = jsonDecode(cardsJson);
      setState(() {
        cards = cardsList.map((cardJson) => CardInfo.fromJson(cardJson)).toList();
        if (cards.isNotEmpty) {
          selectedCard = cards.first;
        }
      });
    } else {
      setState(() {
        cards = [
          CardInfo(
            cardNumber: '**** **** **** 1234',
            expiryDate: '12/26',
            cardHolderName: 'Nguyen Van A',
          ),
        ];
        selectedCard = cards.first;
        _saveCards();
      });
    }
  }

  Future<void> _saveCards() async {
    final cardsJson = jsonEncode(cards.map((card) => card.toJson()).toList());
    await _storage.write(key: 'cards', value: cardsJson);
  }

  void _showNoteDialog() async {
    final noteController = TextEditingController(text: sellerNote);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lời nhắn liên hệ với Shop', style: TextStyle(color: Color(0xFF2D3748))),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: 'Nhập lời nhắn cho người bán...',
            hintStyle: TextStyle(color: Color(0xFF718096)),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF718096))),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                sellerNote = noteController.text.isNotEmpty ? noteController.text : null;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Xác nhận', style: TextStyle(color: Color(0xFF5A4FCF))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;
    final contentWidth = isWeb ? 800.0 : double.infinity;
    final cardMaxWidth = isWeb ? 600.0 : double.infinity;
    final cardMinHeight = 80.0;

    if (widget.products.isEmpty) {
      return Scaffold(
        appBar: isWeb
            ? null
            : AppBar(
          title: const Text('Thanh toán', style: TextStyle(color: Color(0xFF2D3748))),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text(
            'Không có sản phẩm để thanh toán',
            style: TextStyle(color: Color(0xFF2D3748), fontSize: 16),
          ),
        ),
      );
    }

    final subtotal = widget.products.fold<double>(
      0,
          (sum, item) => sum + (item['product'].price * item['quantity']),
    );

    final deliveryCharge = selectedShippingMethod?.price ?? 20000;

    double discount = 0;
    if (selectedVoucher != null) {
      if (selectedVoucher!.discount < 1) {
        discount = subtotal * selectedVoucher!.discount;
      } else {
        discount = selectedVoucher!.discount;
      }
    }

    final total = subtotal + deliveryCharge - discount;

    final fullAddress = [
      selectedAddress?.addressLine,
      selectedAddress?.commune,
      selectedAddress?.district,
      selectedAddress?.city,
    ].where((part) => part != null && part.isNotEmpty).join(', ');

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: isWeb
          ? null
          : AppBar(
        title: const Text('Thanh toán', style: TextStyle(color: Color(0xFF2D3748), fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          if (isWeb) const WebHeader(userData: {}),
          Expanded(
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: contentWidth),
                padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: 16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MouseRegion(
                        onEnter: (_) => setState(() => _isHovered = true),
                        onExit: (_) => setState(() => _isHovered = false),
                        child: Card(
                          elevation: _isHovered ? 6 : 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: _isHovered ? Colors.white.withOpacity(0.95) : Colors.white,
                          child: InkWell(
                            onTap: () async {
                              final chosenAddress = await Navigator.push<Address?>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddressSelectionScreen(user: widget.user),
                                ),
                              );
                              if (chosenAddress != null) {
                                setState(() {
                                  selectedAddress = chosenAddress;
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: cardMinHeight, maxWidth: cardMaxWidth),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.location_on, color: Color(0xFF718096)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Địa chỉ giao hàng',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF2D3748),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            selectedAddress?.receiverName ?? 'Không có tên người nhận',
                                            style: const TextStyle(fontSize: 14, color: Color(0xFF2D3748)),
                                          ),
                                          Text(
                                            fullAddress.isEmpty ? 'Chưa có địa chỉ' : fullAddress,
                                            style: const TextStyle(fontSize: 14, color: Color(0xFF718096)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Thay đổi',
                                      style: TextStyle(
                                        color: _isHovered ? const Color(0xFF5A4FCF) : const Color(0xFF718096),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: cardMaxWidth),
                          child: const Divider(height: 32, color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      const Text(
                        'Danh sách hàng',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
                      ),
                      const SizedBox(height: 8),
                      ...widget.products.map((item) {
                        final product = item['product'];
                        final qty = item['quantity'] as int;
                        final variant = item['color']?.toString() ?? 'Không có biến thể';
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: cardMinHeight, maxWidth: cardMaxWidth),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(child: Icon(Icons.watch, size: 30, color: Color(0xFF718096))),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF2D3748),
                                          ),
                                        ),
                                        Text(
                                          'Biến thể: $variant',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
                                        ),
                                        Text(
                                          'Số lượng: $qty',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '₫${(product.price * qty).toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Color(0xFFF56565),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      Center(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: cardMaxWidth),
                          child: const Divider(height: 32, color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      const Text(
                        'Lời nhắn liên hệ với Shop',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
                      ),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: InkWell(
                          onTap: _showNoteDialog,
                          borderRadius: BorderRadius.circular(12),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: cardMinHeight, maxWidth: cardMaxWidth),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                sellerNote ?? 'Nhấn để thêm lời nhắn',
                                style: const TextStyle(color: Color(0xFF2D3748)),
                              ),
                              trailing: const Icon(Icons.chevron_right, color: Color(0xFF718096)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Phương thức vận chuyển',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
                      ),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ShippingSelectionScreen(
                                  user: widget.user,
                                  selectedAddress: selectedAddress,
                                  selectedShippingMethod: selectedShippingMethod,
                                ),
                              ),
                            );
                            if (result != null) {
                              if (result is ShippingMethod) {
                                setState(() => selectedShippingMethod = result);
                              } else if (result is Address) {
                                setState(() => selectedAddress = result);
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: cardMinHeight, maxWidth: cardMaxWidth),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: selectedShippingMethod != null
                                  ? const Icon(Icons.check_circle, color: Color(0xFF38B2AC))
                                  : null,
                              title: Text(
                                selectedShippingMethod?.name ?? 'Chọn phương thức',
                                style: const TextStyle(color: Color(0xFF2D3748)),
                              ),
                              subtitle: Text(
                                selectedShippingMethod?.estimatedArrival != null
                                    ? 'Ước tính giao hàng: ${selectedShippingMethod!.estimatedArrival}'
                                    : '',
                                style: const TextStyle(color: Color(0xFF718096)),
                              ),
                              trailing: const Icon(Icons.chevron_right, color: Color(0xFF718096)),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: cardMaxWidth),
                          child: const Divider(height: 32, color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      const Text(
                        'Hoàn tất Voucher',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
                      ),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: InkWell(
                          onTap: () async {
                            final chosen = await Navigator.push<Voucher>(
                              context,
                              MaterialPageRoute(builder: (_) => VoucherSelectionScreen()),
                            );
                            if (chosen != null) setState(() => selectedVoucher = chosen);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: cardMinHeight, maxWidth: cardMaxWidth),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                selectedVoucher?.code ?? 'Chọn mã giảm giá',
                                style: const TextStyle(color: Color(0xFF2D3748)),
                              ),
                              trailing: const Icon(Icons.chevron_right, color: Color(0xFF718096)),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: cardMaxWidth),
                          child: const Divider(height: 32, color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentMethodScreen(
                                initialPaymentMethod: selectedPaymentMethod,
                                initialCard: selectedCard,
                                cards: cards,
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              selectedPaymentMethod = result['paymentMethod'];
                              selectedCard = result['card'];
                              cards = result['cards'];
                              _saveCards();
                            });
                          }
                        },
                        child: const Text(
                          'Chọn phương thức thanh toán',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
                        ),
                      ),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: cardMinHeight, maxWidth: cardMaxWidth),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Icon(
                              selectedPaymentMethod == 'Paypal'
                                  ? Icons.paypal
                                  : selectedPaymentMethod == 'Credit Card'
                                  ? Icons.credit_card
                                  : Icons.money,
                              color: selectedPaymentMethod == 'Paypal'
                                  ? const Color(0xFF4299E1)
                                  : selectedPaymentMethod == 'Credit Card'
                                  ? const Color(0xFF4299E1)
                                  : const Color(0xFF38B2AC),
                            ),
                            title: Text(
                              selectedPaymentMethod == 'Credit Card' && selectedCard != null
                                  ? 'Thẻ tín dụng ${selectedCard!.cardNumber}'
                                  : selectedPaymentMethod == 'Paypal'
                                  ? 'Paypal'
                                  : 'Tiền mặt',
                              style: const TextStyle(color: Color(0xFF2D3748)),
                            ),
                            subtitle: selectedPaymentMethod == 'Credit Card' && selectedCard != null
                                ? Text(
                              'Hết hạn: ${selectedCard!.expiryDate}',
                              style: const TextStyle(color: Color(0xFF718096)),
                            )
                                : null,
                            trailing: const Icon(Icons.chevron_right, color: Color(0xFF718096)),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: cardMaxWidth),
                          child: const Divider(height: 32, color: Color(0xFFE2E8F0)),
                        ),
                      ),
                      const Text(
                        'Tóm tắt đơn hàng',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Container(
                          constraints: BoxConstraints(maxWidth: cardMaxWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Tạm tính', style: TextStyle(color: Color(0xFF2D3748))),
                                    Text('₫${subtotal.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF2D3748))),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Giảm giá', style: TextStyle(color: Color(0xFF2D3748))),
                                    Text('₫${discount.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF2D3748))),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Phí vận chuyển', style: TextStyle(color: Color(0xFF2D3748))),
                                    Text('₫${deliveryCharge.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF2D3748))),
                                  ],
                                ),
                              ),
                              const Divider(height: 16, color: Color(0xFFE2E8F0)),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Tổng cộng', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D3748))),
                                    Text('₫${total.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D3748))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Container(
                          constraints: BoxConstraints(maxWidth: cardMaxWidth),
                          child: MouseRegion(
                            onEnter: (_) => setState(() => _isHovered = true),
                            onExit: (_) => setState(() => _isHovered = false),
                            child: AnimatedScale(
                              scale: _isHovered ? 1.05 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (selectedPaymentMethod == 'Credit Card' && selectedCard == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Vui lòng chọn hoặc thêm thẻ để thanh toán')),
                                      );
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OrderSuccessScreen(
                                          products: widget.products,
                                          total: total,
                                          shippingMethod: selectedShippingMethod,
                                          paymentMethod: selectedPaymentMethod,
                                          sellerNote: sellerNote,
                                          voucher: selectedVoucher,
                                          address: selectedAddress,
                                          card: selectedCard,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF5A4FCF),
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    elevation: _isHovered ? 8 : 4,
                                  ),
                                  child: const Text(
                                    'Đặt hàng',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}