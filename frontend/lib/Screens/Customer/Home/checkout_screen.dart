import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  final bool isLoggedIn;

  const CheckoutScreen({required this.isLoggedIn});

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  String defaultAddress = "123 Default St, City";

  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn) {
      _addressController.text = defaultAddress;
    }
  }

  void _placeOrder() {
    if (!widget.isLoggedIn) {
      print("Creating account for guest user...");
    }
    print("Order placed with address: ${_addressController.text}");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order placed successfully!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Checkout"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: "Shipping Address",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _placeOrder,
              child: Text("Place Order"),
            ),
          ],
        ),
      ),
    );
  }
}