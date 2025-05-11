import 'package:danentang/models/User.dart';
import 'package:flutter/material.dart';
class ProfileDatePickerDialog {
  static Future<String?> show(BuildContext context, User? userModel) async {
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