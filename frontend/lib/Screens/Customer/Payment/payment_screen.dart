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
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:danentang/models/Order.dart';
import 'package:danentang/models/OrderItem.dart';
import 'package:danentang/models/OrderStatusHistory.dart';
import 'package:danentang/models/ShippingAddress.dart';
import 'package:danentang/widgets/Payment/address_card.dart';
import 'package:danentang/widgets/Payment/product_list.dart';
import 'package:danentang/widgets/Payment/seller_note_card.dart';
import 'package:danentang/widgets/Payment/shipping_method_card.dart';
import 'package:danentang/widgets/Payment/voucher_card.dart';
import 'package:danentang/widgets/Payment/payment_method_card.dart';
import 'package:danentang/widgets/Payment/order_summary.dart';
import 'package:danentang/widgets/Payment/place_order_button.dart';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final double total;
  final User user;
  final ShippingMethod? shippingMethod;
  final String? paymentMethod;
  final String? sellerNote;
  final Voucher? voucher;
  final Address? address;
  final CardInfo? card;

  const PaymentScreen({
    super.key,
    required this.products,
    required this.total,
    required this.user,
    this.shippingMethod,
    this.paymentMethod,
    this.sellerNote,
    this.voucher,
    this.address,
    this.card,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  ShippingMethod? selectedShippingMethod;
  String? selectedPaymentMethod;
  String? sellerNote;
  Voucher? selectedVoucher;
  Address? selectedAddress;
  bool _isHovered = false;
  List<CardInfo> cards = [];
  CardInfo? selectedCard;
  final _storage = const FlutterSecureStorage();
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    selectedShippingMethod = widget.shippingMethod ??
        ShippingMethod(
          name: 'Tiết kiệm',
          estimatedArrival: DateTime.now().add(const Duration(days: 7)).toString().split(' ')[0],
          price: 20000,
        );
    selectedPaymentMethod = widget.paymentMethod ?? 'Credit Card';
    sellerNote = widget.sellerNote;
    selectedVoucher = widget.voucher;
    selectedAddress = widget.address ??
        (widget.user.addresses.isNotEmpty
            ? widget.user.addresses.firstWhere(
              (addr) => addr.isDefault,
          orElse: () => widget.user.addresses.first,
        )
            : null);
    selectedCard = widget.card;
    _init();
    _loadCards();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getString('token') != null;
    });
  }

  Future<void> _loadCards() async {
    final cardsJson = await _storage.read(key: 'cards');
    if (cardsJson != null) {
      final List<dynamic> cardsList = jsonDecode(cardsJson);
      setState(() {
        cards = cardsList.map((cardJson) => CardInfo.fromJson(cardJson)).toList();
        if (cards.isNotEmpty && selectedCard == null) {
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
        if (selectedCard == null) {
          selectedCard = cards.first;
        }
        _saveCards();
      });
    }
  }

  Future<void> _saveCards() async {
    final cardsJson = jsonEncode(cards.map((card) => card.toJson()).toList());
    await _storage.write(key: 'cards', value: cardsJson);
  }

  void _updateAddress(Address? newAddress) {
    if (newAddress != null) {
      setState(() {
        selectedAddress = newAddress;
      });
    }
  }

  void _updateSellerNote(String? newNote) {
    setState(() {
      sellerNote = newNote?.isNotEmpty == true ? newNote : null;
    });
  }

  void _updateShippingMethod(dynamic result) {
    if (result != null) {
      if (result is ShippingMethod) {
        setState(() => selectedShippingMethod = result);
      } else if (result is Address) {
        setState(() => selectedAddress = result);
      }
    }
  }

  void _updateVoucher(Voucher? newVoucher) {
    if (newVoucher != null) {
      setState(() => selectedVoucher = newVoucher);
    }
  }

  void _updatePaymentMethod(Map<String, dynamic>? result) {
    if (result != null) {
      setState(() {
        selectedPaymentMethod = result['paymentMethod'];
        selectedCard = result['card'];
        cards = result['cards'];
        _saveCards();
      });
    }
  }

  double _calculateSubtotal() {
    return widget.products.fold<double>(
      0,
          (sum, item) => sum + (item['product'].price * item['quantity']),
    );
  }

  double _calculateDiscount() {
    double discount = 0;
    final subtotal = _calculateSubtotal();
    if (selectedVoucher != null) {
      if (selectedVoucher!.discount < 1) {
        discount = subtotal * selectedVoucher!.discount;
      } else {
        discount = selectedVoucher!.discount;
      }
    }
    return discount;
  }

  double _calculateTotal() {
    final subtotal = _calculateSubtotal();
    final deliveryCharge = selectedShippingMethod?.price ?? 20000;
    final discount = _calculateDiscount();
    return subtotal + deliveryCharge - discount;
  }

  void _placeOrder() {
    if (selectedPaymentMethod == 'Credit Card' && selectedCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn hoặc thêm thẻ để thanh toán')),
      );
      return;
    }
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn địa chỉ giao hàng')),
      );
      return;
    }

    final List<OrderItem> orderItems = widget.products.map((item) {
      final product = item['product'];
      final qty = item['quantity'] as int;
      final variant = item['color']?.toString() ?? 'Không có biến thể';
      return OrderItem(
        productId: product.id ?? const Uuid().v4(),
        productVariantId: null,
        productName: product.name,
        variantName: variant,
        quantity: qty,
        price: product.price,
      );
    }).toList();

    final shippingAddress = ShippingAddress(
      receiverName: selectedAddress!.receiverName ?? 'Người nhận',
      phoneNumber: selectedAddress!.phone ?? '0000000000',
      addressLine: selectedAddress!.addressLine ?? 'No address',
      ward: selectedAddress!.commune ?? 'No ward',
      district: selectedAddress!.district ?? 'No district',
      city: selectedAddress!.city ?? 'No city',
    );

    final order = Order(
      id: const Uuid().v4(),
      userId: widget.user.id ?? const Uuid().v4(),
      orderNumber: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      shippingAddress: shippingAddress,
      items: orderItems,
      totalAmount: _calculateTotal(),
      discountAmount: _calculateDiscount(),
      couponCode: selectedVoucher?.code,
      loyaltyPointsUsed: 0,
      status: 'pending',
      statusHistory: [
        OrderStatusHistory(
          status: 'pending',
          timestamp: DateTime.now(),
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderSuccessScreen(
          products: widget.products,
          total: _calculateTotal(),
          shippingMethod: selectedShippingMethod,
          paymentMethod: selectedPaymentMethod!,
          sellerNote: sellerNote,
          voucher: selectedVoucher,
          address: selectedAddress!,
          card: selectedCard,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: Colors.white,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFF5F9FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            if (isWeb) WebHeader(isLoggedIn: _isLoggedIn),
            Expanded(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: contentWidth),
                  padding: EdgeInsets.symmetric(horizontal: isWeb ? 24 : 16, vertical: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(12),
                          child: AddressCard(
                            selectedAddress: selectedAddress,
                            isHovered: _isHovered,
                            onHover: (hovered) => setState(() => _isHovered = hovered),
                            onAddressSelected: _updateAddress,
                            user: widget.user,
                            cardMaxWidth: cardMaxWidth,
                            cardMinHeight: cardMinHeight,
                          ),
                        ),
                        Center(
                          child: Container(
                            constraints: BoxConstraints(maxWidth: cardMaxWidth),
                            child: const Divider(height: 32, color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(12),
                          child: ProductList(
                            products: widget.products,
                            cardMaxWidth: cardMaxWidth,
                            cardMinHeight: cardMinHeight,
                          ),
                        ),
                        Center(
                          child: Container(
                            constraints: BoxConstraints(maxWidth: cardMaxWidth),
                            child: const Divider(height: 32, color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(12),
                          child: SellerNoteCard(
                            sellerNote: sellerNote,
                            onNoteUpdated: _updateSellerNote,
                            cardMaxWidth: cardMaxWidth,
                            cardMinHeight: cardMinHeight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(12),
                          child: ShippingMethodCard(
                            selectedShippingMethod: selectedShippingMethod,
                            selectedAddress: selectedAddress,
                            user: widget.user,
                            onShippingMethodUpdated: _updateShippingMethod,
                            cardMaxWidth: cardMaxWidth,
                            cardMinHeight: cardMinHeight,
                          ),
                        ),
                        Center(
                          child: Container(
                            constraints: BoxConstraints(maxWidth: cardMaxWidth),
                            child: const Divider(height: 32, color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(12),
                          child: VoucherCard(
                            selectedVoucher: selectedVoucher,
                            onVoucherSelected: _updateVoucher,
                            cardMaxWidth: cardMaxWidth,
                            cardMinHeight: cardMinHeight,
                          ),
                        ),
                        Center(
                          child: Container(
                            constraints: BoxConstraints(maxWidth: cardMaxWidth),
                            child: const Divider(height: 32, color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(12),
                          child: PaymentMethodCard(
                            selectedPaymentMethod: selectedPaymentMethod,
                            selectedCard: selectedCard,
                            cards: cards,
                            onPaymentMethodUpdated: _updatePaymentMethod,
                            cardMaxWidth: cardMaxWidth,
                          ),
                        ),
                        Center(
                          child: Container(
                            constraints: BoxConstraints(maxWidth: cardMaxWidth),
                            child: const Divider(height: 32, color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(12),
                          child: OrderSummary(
                            subtotal: _calculateSubtotal(),
                            discount: _calculateDiscount(),
                            deliveryCharge: selectedShippingMethod?.price ?? 20000,
                            total: _calculateTotal(),
                            cardMaxWidth: cardMaxWidth,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(12),
                          child: PlaceOrderButton(
                            isHovered: _isHovered,
                            onHover: (hovered) => setState(() => _isHovered = hovered),
                            onPressed: _placeOrder,
                            cardMaxWidth: cardMaxWidth,
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
      ),
    );
  }
}