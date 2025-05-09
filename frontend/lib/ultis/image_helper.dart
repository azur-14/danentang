// lib/utils/image_helper.dart

import 'dart:convert';
import 'package:flutter/material.dart';

/// Decode a Base64 string into an Image widget.
/// If [base64String] is null or empty, returns the [placeholder] instead.
Image imageFromBase64String(
    String? base64String, {
      double? width,
      double? height,
      BoxFit fit = BoxFit.cover,
      ImageProvider? placeholder,
    }) {
  if (base64String == null || base64String.isEmpty) {
    return Image(
      image: placeholder ?? const AssetImage('assets/placeholder.png'),
      width: width,
      height: height,
      fit: fit,
    );
  }
  final bytes = base64Decode(base64String);
  return Image.memory(
    bytes,
    width: width,
    height: height,
    fit: fit,
  );
}

/// Return an [ImageProvider] (e.g. for use in DecorationImage)
MemoryImage memoryImageProvider(String base64String) {
  return MemoryImage(base64Decode(base64String));
}
