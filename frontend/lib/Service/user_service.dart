import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service class to handle user authentication API calls.
class UserService {
  /// Base URL for authentication endpoints.
  final String _baseUrl;

  UserService({String baseUrl = 'http://localhost:5012/api/auth'})
      : _baseUrl = baseUrl;

  /// Checks if an email is already registered.
  /// Returns true if exists, false otherwise.
  Future<bool> checkEmailExists(String email) async {
    final url = Uri.parse('$_baseUrl/check-email?email=$email');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['exists'] as bool;
    } else {
      throw Exception('Failed to check email: ${response.statusCode}');
    }
  }

  /// Registers a new user with the provided details.
  Future<void> register({
    required String email,
    required String fullName,
    required String password,
    required String addressLine1,
    String addressLine2 = '',
    String city = 'Hanoi',
    String state = 'HN',
    String zipCode = '10000',
    String country = 'Vietnam',
  }) async {
    final url = Uri.parse('$_baseUrl/register');
    final body = jsonEncode({
      'email': email,
      'fullName': fullName,
      'password': password,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  /// Logs in a user, returning an authentication token on success.
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/login');
    final body = jsonEncode({'email': email, 'password': password});

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['token'] as String;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }
}
