import 'package:flutter/material.dart';
import 'package:danentang/Screens/Customer/Payment/add_card_screen.dart';
import 'package:danentang/models/card_info.dart'; // Import the shared CardInfo model

class PaymentMethodScreen extends StatefulWidget {
  final String initialPaymentMethod;
  final CardInfo? initialCard;
  final List<CardInfo> cards;

  const PaymentMethodScreen({
    super.key,
    required this.initialPaymentMethod,
    this.initialCard,
    required this.cards,
  });

  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  late String selectedPaymentMethod;
  late List<CardInfo> cards;
  CardInfo? selectedCard;

  @override
  void initState() {
    super.initState();
    selectedPaymentMethod = widget.initialPaymentMethod;
    cards = widget.cards;
    selectedCard = widget.initialCard;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 800;
    final cardMaxWidth = isWeb ? 600.0 : double.infinity;
    final cardMinHeight = 80.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: const Text('Chọn phương thức thanh toán', style: TextStyle(color: Color(0xFF2D3748))),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context, {
            'paymentMethod': selectedPaymentMethod,
            'card': selectedCard,
            'cards': cards,
          }),
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isWeb ? 800.0 : double.infinity),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: cardMaxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...cards.map((card) {
                          return InkWell(
                            onTap: () => setState(() {
                              selectedPaymentMethod = 'Credit Card';
                              selectedCard = card;
                            }),
                            child: Opacity(
                              opacity: selectedCard == card ? 1.0 : 0.7,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minHeight: cardMinHeight),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: const Icon(Icons.credit_card, color: Color(0xFF4299E1)),
                                  title: Text(
                                    'Thẻ tín dụng ${card.cardNumber}',
                                    style: const TextStyle(color: Color(0xFF2D3748)),
                                  ),
                                  subtitle: Text(
                                    'Hết hạn: ${card.expiryDate}',
                                    style: const TextStyle(color: Color(0xFF718096)),
                                  ),
                                  trailing: Radio<CardInfo?>(
                                    value: card,
                                    groupValue: selectedCard,
                                    onChanged: (v) => setState(() {
                                      selectedCard = v;
                                      selectedPaymentMethod = 'Credit Card';
                                    }),
                                    activeColor: const Color(0xFF5A4FCF),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        InkWell(
                          onTap: () async {
                            final newCard = await Navigator.push<CardInfo>(
                              context,
                              MaterialPageRoute(builder: (_) => const AddCardScreen()),
                            );
                            if (newCard != null) {
                              setState(() {
                                cards.add(newCard);
                                selectedCard = newCard;
                                selectedPaymentMethod = 'Credit Card';
                              });
                            }
                          },
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: cardMinHeight),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: const Icon(Icons.add_card, color: Color(0xFF4299E1)),
                              title: const Text(
                                'Thêm thẻ mới',
                                style: TextStyle(color: Color(0xFF2D3748)),
                              ),
                              trailing: const Icon(Icons.chevron_right, color: Color(0xFF718096)),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        InkWell(
                          onTap: () => setState(() {
                            selectedPaymentMethod = 'Paypal';
                            selectedCard = null;
                          }),
                          child: Opacity(
                            opacity: selectedPaymentMethod == 'Paypal' ? 1.0 : 0.7,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: cardMinHeight),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: const Icon(Icons.paypal, color: Color(0xFF4299E1)),
                                title: const Text('Paypal', style: TextStyle(color: Color(0xFF2D3748))),
                                trailing: Radio<String>(
                                  value: 'Paypal',
                                  groupValue: selectedPaymentMethod,
                                  onChanged: (v) => setState(() {
                                    selectedPaymentMethod = v!;
                                    selectedCard = null;
                                  }),
                                  activeColor: const Color(0xFF5A4FCF),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        InkWell(
                          onTap: () => setState(() {
                            selectedPaymentMethod = 'Cash';
                            selectedCard = null;
                          }),
                          child: Opacity(
                            opacity: selectedPaymentMethod == 'Cash' ? 1.0 : 0.7,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: cardMinHeight),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: const Icon(Icons.money, color: Color(0xFF38B2AC)),
                                title: const Text('Tiền mặt', style: TextStyle(color: Color(0xFF2D3748))),
                                trailing: Radio<String>(
                                  value: 'Cash',
                                  groupValue: selectedPaymentMethod,
                                  onChanged: (v) => setState(() {
                                    selectedPaymentMethod = v!;
                                    selectedCard = null;
                                  }),
                                  activeColor: const Color(0xFF5A4FCF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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