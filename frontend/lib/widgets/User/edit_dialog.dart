import 'package:danentang/models/User.dart';
import 'package:flutter/material.dart';

class EditDialog extends StatefulWidget {
  final String field;
  final String title;
  final String? initialValue;
  final Function(String) onSave;

  const EditDialog({
    required this.field,
    required this.title,
    required this.initialValue,
    required this.onSave,
    super.key,
  });

  static void show(BuildContext context, User userModel, String field, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return EditDialog(
          field: field,
          title: title,
          initialValue: field == 'phoneNumber' ? userModel.phoneNumber : userModel.email,
          onSave: (value) {
            if (field == 'phoneNumber') {
              userModel.updateUser(phoneNumber: value);
            } else {
              userModel.updateUser(email: value);
            }
          },
        );
      },
    );
  }

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  late final TextEditingController _controller;
  String? _errorMessage;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _validateInput(widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validateInput(String value) {
    setState(() {
      value = value.trim();
      if (widget.field == 'phoneNumber') {
        // Phone number validation
        if (value.isEmpty) {
          _errorMessage = 'Vui lòng nhập số điện thoại';
          _isValid = false;
        } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
          _errorMessage = 'Số điện thoại chỉ được chứa chữ số';
          _isValid = false;
        } else if (value.length != 10) {
          _errorMessage = 'Số điện thoại phải có đúng 10 chữ số';
          _isValid = false;
        } else {
          _errorMessage = null;
          _isValid = true;
        }
      } else {
        // Email validation
        if (value.isEmpty) {
          _errorMessage = 'Vui lòng nhập email';
          _isValid = false;
        } else if (!value.contains('@')) {
          _errorMessage = 'Email phải chứa ký tự @';
          _isValid = false;
        } else if (!value.contains('.')) {
          _errorMessage = 'Email phải chứa tên miền (ví dụ: .com)';
          _isValid = false;
        } else if (RegExp(r'\s').hasMatch(value)) {
          _errorMessage = 'Email không được chứa khoảng trắng';
          _isValid = false;
        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          _errorMessage = 'Email không hợp lệ (ví dụ: example@domain.com)';
          _isValid = false;
        } else {
          _errorMessage = null;
          _isValid = true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cập nhật ${widget.title}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: widget.title,
              errorText: _errorMessage,
            ),
            onChanged: _validateInput,
            keyboardType: widget.field == 'phoneNumber' ? TextInputType.phone : TextInputType.emailAddress,
            maxLength: widget.field == 'phoneNumber' ? 10 : 100,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isValid
              ? () {
            widget.onSave(_controller.text.trim());
            Navigator.pop(context);
          }
              : null,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          child: const Text('Xác nhận'),
        ),
      ],
    );
  }
}