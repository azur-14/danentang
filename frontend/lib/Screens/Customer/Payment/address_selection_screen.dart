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
    // Pre-select the default address if it exists, otherwise select the first address
    _selectedAddress = widget.user.addresses.firstWhere(
          (addr) => addr.isDefault,
      //orElse: () => widget.user.addresses.isNotEmpty ? widget.user.addresses.first : null,
    );
  }

  // Function to show the add address dialog with responsive design
  void _showAddAddressDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _receiverNameController = TextEditingController(text: widget.user.fullName);
    final _phoneNumberController = TextEditingController();
    final _addressLineController = TextEditingController();
    final _communeController = TextEditingController();
    final _districtController = TextEditingController();
    final _cityController = TextEditingController();
    bool _isDefault = false;

    // Get screen size for responsive dialog
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width > 600 ? 400.0 : screenSize.width * 0.9;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm địa chỉ mới'),
        content: Container(
          width: dialogWidth,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _receiverNameController,
                    decoration: const InputDecoration(labelText: 'Tên người nhận'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(labelText: 'Số điện thoại'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập số điện thoại';
                      }
                      if (!RegExp(r'^\d{10,11}$').hasMatch(value)) {
                        return 'Số không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _addressLineController,
                    decoration: const InputDecoration(labelText: 'Địa chỉ (số nhà, đường)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập địa chỉ';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _communeController,
                    decoration: const InputDecoration(labelText: 'Xã/Phường'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập xã/phường';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _districtController,
                    decoration: const InputDecoration(labelText: 'Quận/Huyện'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập quận/huyện';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'Tỉnh/Thành phố'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tỉnh/thành phố';
                      }
                      return null;
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Đặt làm mặc định'),
                    value: _isDefault,
                    onChanged: (value) {
                      setState(() {
                        _isDefault = value ?? false;
                      });
                    },
                    dense: true,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newAddress = Address(
                  receiverName: _receiverNameController.text,
                  phone: _phoneNumberController.text,
                  addressLine: _addressLineController.text,
                  commune: _communeController.text,
                  district: _districtController.text,
                  city: _cityController.text,
                  isDefault: _isDefault,
                );

                // If the new address is default, clear other defaults
                if (_isDefault) {
                  for (var addr in widget.user.addresses) {
                    addr.isDefault = false;
                  }
                }

                // Add the new address and update the UI
                setState(() {
                  widget.user.addresses.add(newAddress);
                  _selectedAddress = newAddress; // Auto-select the new address
                });

                Navigator.pop(context); // Close the dialog
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    ).then((_) {
      // Dispose controllers after dialog is closed
      _receiverNameController.dispose();
      _phoneNumberController.dispose();
      _addressLineController.dispose();
      _communeController.dispose();
      _districtController.dispose();
      _cityController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width > 600 ? 32.0 : 16.0;
    final fontSize = screenSize.width > 600 ? 18.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chọn địa chỉ giao hàng',
          style: TextStyle(fontSize: fontSize),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _selectedAddress),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.all(padding),
            child: widget.user.addresses.isEmpty
                ? Center(
              child: Text(
                'Chưa có địa chỉ nào. Vui lòng thêm địa chỉ.',
                style: TextStyle(fontSize: fontSize),
              ),
            )
                : ListView.builder(
              itemCount: widget.user.addresses.length + 1, // +1 for the add button
              itemBuilder: (context, index) {
                if (index == widget.user.addresses.length) {
                  // Add Address button as a ListTile
                  return ListTile(
                    leading: const Icon(Icons.add_location, color: Colors.blue),
                    title: Text(
                      'Thêm địa chỉ mới',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    onTap: () => _showAddAddressDialog(context),
                  );
                }

                final address = widget.user.addresses[index];
                final fullAddress = [
                  address.addressLine,
                  address.commune,
                  address.district,
                  address.city,
                ].where((part) => part != null && part.isNotEmpty).join(', ');

                return Card(
                  margin: EdgeInsets.symmetric(vertical: padding / 2),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullAddress,
                          style: TextStyle(fontSize: fontSize - 2),
                        ),
                        Text(
                          'Phone: ${address.phone}',
                          style: TextStyle(fontSize: fontSize - 2),
                        ),
                        if (address.isDefault)
                          Text(
                            'Mặc định',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: fontSize - 4,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}