import 'package:danentang/models/user_model.dart';
import 'package:flutter/material.dart';

class ProfileDatePickerDialog {
  static void show(BuildContext context, UserModel userModel) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate != null) {
        final formattedDate = '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
        userModel.updateUser(dateOfBirth: formattedDate);
      }
    });
  }
}