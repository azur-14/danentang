import 'package:danentang/models/User.dart';
import 'package:flutter/material.dart';

class GenderDialog {
  static Future<String?> show(BuildContext context, User? userModel) async {
    return await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chọn giới tính'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Nam'),
                onTap: () => Navigator.pop(context, 'Nam'),
              ),
              ListTile(
                title: const Text('Nữ'),
                onTap: () => Navigator.pop(context, 'Nữ'),
              ),
              ListTile(
                title: const Text('Khác'),
                onTap: () => Navigator.pop(context, 'Khác'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }
}