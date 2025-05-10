import 'package:danentang/models/user_model.dart';
import 'package:flutter/material.dart';
class ProfileDatePickerDialog {
  static Future<String?> show(BuildContext context, UserModel? userModel) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      return '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}';
    }
    return null;
  }
}