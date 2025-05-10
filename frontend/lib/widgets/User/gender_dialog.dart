import 'package:danentang/models/User.dart';
import 'package:flutter/material.dart';

class GenderDialog {
  static void show(BuildContext context, User userModel) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Giới tính'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Nam'),
                onTap: () {
                  userModel.updateUser(gender: 'Nam');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Nữ'),
                onTap: () {
                  userModel.updateUser(gender: 'Nữ');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}