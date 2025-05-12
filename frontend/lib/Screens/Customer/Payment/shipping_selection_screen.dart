// lib/Screens/Manager/Checkout/shipping_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:danentang/models/ship.dart';
import 'package:danentang/models/User.dart';      // <-- updated
import 'package:danentang/models/address.dart';         // <-- if you need the type

class ShippingSelectionScreen extends StatefulWidget {
  const ShippingSelectionScreen({super.key});

  @override
  _ShippingSelectionScreenState createState() =>
      _ShippingSelectionScreenState();
}

class _ShippingSelectionScreenState extends State<ShippingSelectionScreen> {
  late ShippingMethod selectedMethod;

  @override
  void initState() {
    super.initState();
    // default selection
    selectedMethod = ShippingMethod(
      name: 'Tiết kiệm',
      estimatedArrival: '25 Tháng 8 2023',
      price: 20000,
    );
  }

  void _selectShippingMethod(ShippingMethod? method) {
    if (method == null) return;
    setState(() => selectedMethod = method);
    Navigator.pop(context, selectedMethod);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    // grab the first addressLine if available
    final addrLine = user.addresses.isNotEmpty
        ? user.addresses.first.addressLine
        : 'Chưa có địa chỉ';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn phương thức giao hàng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Phương thức giao hàng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          RadioListTile<ShippingMethod>(
            title: const Text('Tiết kiệm'),
            subtitle: const Text('Dự kiến giao: 25 Tháng 8 2023'),
            value: ShippingMethod(
                name: 'Tiết kiệm',
                estimatedArrival: '25 Tháng 8 2023',
                price: 20000),
            groupValue: selectedMethod,
            onChanged: _selectShippingMethod,
            secondary: const Icon(Icons.local_shipping),
            activeColor: Colors.brown,
          ),
          RadioListTile<ShippingMethod>(
            title: const Text('Thông thường'),
            subtitle: const Text('Dự kiến giao: 24 Tháng 8 2023'),
            value: ShippingMethod(
                name: 'Thông thường',
                estimatedArrival: '24 Tháng 8 2023',
                price: 30000),
            groupValue: selectedMethod,
            onChanged: _selectShippingMethod,
            secondary: const Icon(Icons.local_shipping),
            activeColor: Colors.brown,
          ),
          RadioListTile<ShippingMethod>(
            title: const Text('Hỏa tốc'),
            subtitle: const Text('Dự kiến giao: 22 Tháng 8 2023'),
            value: ShippingMethod(
                name: 'Hỏa tốc',
                estimatedArrival: '22 Tháng 8 2023',
                price: 50000),
            groupValue: selectedMethod,
            onChanged: _selectShippingMethod,
            secondary: const Icon(Icons.local_shipping),
            activeColor: Colors.brown,
          ),

          const Divider(height: 32),

          ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(user.fullName),
            subtitle: Text(addrLine),
            trailing: const Icon(Icons.check_circle_outline),
            onTap: () {
              // Perhaps navigate to edit/add address screen
              Navigator.pushNamed(context, '/addresses');
            },
          ),
        ],
      ),
    );
  }
}
