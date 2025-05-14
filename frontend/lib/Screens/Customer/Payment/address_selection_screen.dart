import 'package:flutter/material.dart';
import 'package:danentang/models/User.dart';
import 'package:danentang/models/Address.dart';

class AddressSelectionScreen extends StatefulWidget {
  final User user;

  const AddressSelectionScreen({Key? key, required this.user}) : super(key: key);

  @override
  _AddressSelectionScreenState createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  Address? _selectedAddress;

  @override
  void initState() {
    super.initState();
    // Pre-select the default address if it exists
    _selectedAddress = widget.user.addresses.firstWhere(
          (addr) => addr.isDefault,
      //kiem tra lai thu cai nay nha
      //orElse: () => widget.user.addresses.isNotEmpty ? widget.user.addresses.first : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn địa chỉ giao hàng'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _selectedAddress), // Returns Address? (can be null)
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.user.addresses.isEmpty
            ? const Center(child: Text('Chưa có địa chỉ nào. Vui lòng thêm địa chỉ.'))
            : ListView.builder(
          itemCount: widget.user.addresses.length,
          itemBuilder: (context, index) {
            final address = widget.user.addresses[index];
            final fullAddress = [
              address.addressLine,
              address.commune,
              address.district,
              address.city,
            ].where((part) => part != null && part.isNotEmpty).join(', ');

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: RadioListTile<Address>(
                value: address,
                groupValue: _selectedAddress,
                onChanged: (Address? value) {
                  setState(() {
                    _selectedAddress = value;
                  });
                },
                title: Text(
                  address.receiverName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fullAddress),
                    Text('Phone: ${address.phone}'),
                    if (address.isDefault)
                      const Text(
                        'Mặc định',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}