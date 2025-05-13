import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = 'https://your-api-domain.com/api';

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/users/reset-password');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      // Reset password thành công
      return;
    } else {
      // Thất bại, trả về lỗi
      final responseBody = jsonDecode(response.body);
      final errorMessage = responseBody['message'] ?? 'Đã xảy ra lỗi';
      throw Exception(errorMessage);
    }
  }
}