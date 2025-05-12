// lib/services/user_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/User.dart';
import '../models/Address.dart';

class UserService {
  /// AuthController base URL
  final String _authBase;

  /// UserController base URL
  final String _userBase;

  UserService({
    // use 10.0.2.2 on Android emulator, localhost on web/desktop
    String authBase = kIsWeb ? 'http://localhost:5012/api/auth' : 'http://10.0.2.2:5012/api/auth',
    String userBase = kIsWeb ? 'http://localhost:5012/api/user' : 'http://10.0.2.2:5012/api/user',
  })  : _authBase = authBase,
        _userBase = userBase;

  // ─── AuthController ─────────────────────────────────────────────────────────

  /// 1. Check if an email exists
  Future<bool> checkEmailExists(String email) async {
    final res = await http.get(Uri.parse('$_authBase/check-email?email=$email'));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as Map<String, dynamic>)['exists'] as bool;
    }
    throw Exception('checkEmailExists failed: ${res.statusCode}');
  }

  /// 2. Register a new user (with initial address)
  Future<void> register({
    required String email,
    required String fullName,
    required String password,
    String? receiverName,
    String? phone,
    String? addressLine,
    String? commune,
    String? district,
    String? city,
  }) async {
    final body = {
      'email': email,
      'fullName': fullName,
      'password': password,
      'receiverName': receiverName,
      'phone': phone,
      'addressLine': addressLine,
      'commune': commune,
      'district': district,
      'city': city,
    }..removeWhere((_, v) => v == null);

    final res = await http.post(
      Uri.parse('$_authBase/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception('register failed: ${res.body}');
    }
  }

  /// 3. Login, returns JWT token
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$_authBase/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as Map<String, dynamic>)['token'] as String;
    }
    throw Exception('login failed: ${res.body}');
  }

  /// 4. Fetch users via AuthController (DTO)
  Future<List<User>> fetchAuthUsers({String? excludeRole}) async {
    final uri = excludeRole != null && excludeRole.isNotEmpty
        ? Uri.parse('$_authBase/users?excludeRole=$excludeRole')
        : Uri.parse('$_authBase/users');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((j) => User.fromJson(j)).toList();
    }
    throw Exception('fetchAuthUsers failed: ${res.statusCode}');
  }

  /// 5. Fetch a single user via AuthController
  Future<User> fetchAuthUserById(String id) async {
    final res = await http.get(Uri.parse('$_authBase/users/$id'));
    if (res.statusCode == 200) {
      return User.fromJson(jsonDecode(res.body));
    }
    throw Exception('fetchAuthUserById failed: ${res.statusCode}');
  }

  // ─── UserController ─────────────────────────────────────────────────────────

  /// 6. Fetch all users (full model)
  Future<List<User>> fetchUsers() async {
    final res = await http.get(Uri.parse(_userBase));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((j) => User.fromJson(j)).toList();
    }
    throw Exception('fetchUsers failed: ${res.statusCode}');
  }

  /// 7. Fetch a single user by ID (full model)
  Future<User> fetchUserById(String id) async {
    final res = await http.get(Uri.parse('$_userBase/$id'));
    if (res.statusCode == 200) {
      return User.fromJson(jsonDecode(res.body));
    }
    throw Exception('fetchUserById failed: ${res.statusCode}');
  }

  /// Fetches the raw JSON map for the user.
  Future<Map<String, dynamic>> _fetchRawUserJson(String id) async {
    final res = await http.get(Uri.parse('$_userBase/$id'));
    if (res.statusCode != 200) {
      throw Exception('fetchRawUserJson failed: ${res.statusCode}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Replaces the entire user document, preserving server-only fields.
  Future<void> updateUserFull(User edited) async {
    final url = Uri.parse('$_userBase/${edited.id}');

    // 1) Pull down the existing JSON (includes passwordHash, createdAt, updatedAt, etc.)
    final payload = await _fetchRawUserJson(edited.id!);

    // 2) Overwrite only the fields the UI allows editing:
    payload['fullName']    = edited.fullName;
    payload['phoneNumber'] = edited.phoneNumber;
    payload['avatarUrl']   = edited.avatarUrl;
    payload['gender']      = edited.gender;
    payload['dateOfBirth'] = edited.dateOfBirth?.toIso8601String();
    payload['status']      = edited.status;
    // role/email/loyaltyPoints/etc. are left untouched

    // 3) Replace addresses array wholesale:
    payload['addresses'] = edited.addresses.map((a) => a.toJson()).toList();

    // 4) Send back the full payload
    final res = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode != 204) {
      throw Exception('updateUserFull failed: ${res.statusCode}');
    }
  }

  /// 9. Delete a user
  Future<void> deleteUser(String id) async {
    final res = await http.delete(Uri.parse('$_userBase/$id'));
    if (res.statusCode != 204) {
      throw Exception('deleteUser failed: ${res.statusCode}');
    }
  }

  /// 10. Change status (Active/Suspended/Banned)
  Future<void> changeStatus(String id, String status) async {
    final res = await http.put(
      Uri.parse('$_userBase/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    if (res.statusCode != 204) {
      throw Exception('changeStatus failed: ${res.statusCode}');
    }
  }
  Future<void> banUser(String id) => changeStatus(id, 'Banned');
  Future<void> suspendUser(String id) => changeStatus(id, 'Suspended');
  Future<void> activateUser(String id) => changeStatus(id, 'Active');

  // ─── Address CRUD ────────────────────────────────────────────────────────────

  /// 11. Fetch all addresses of a user
  Future<List<Address>> fetchAddresses(String userId) async {
    final res = await http.get(Uri.parse('$_userBase/$userId/addresses'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((j) => Address.fromJson(j)).toList();
    }
    throw Exception('fetchAddresses failed: ${res.statusCode}');
  }

  /// 12. Add a new address
  Future<void> addAddress(String userId, Address a) async {
    final res = await http.post(
      Uri.parse('$_userBase/$userId/addresses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(a.toJson()),
    );
    if (res.statusCode != 204) {
      throw Exception('addAddress failed: ${res.statusCode}');
    }
  }

  /// 13. Update an address by index
  Future<void> updateAddress(String userId, int index, Address a) async {
    final res = await http.put(
      Uri.parse('$_userBase/$userId/addresses/$index'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(a.toJson()),
    );
    if (res.statusCode != 204) {
      throw Exception('updateAddress failed: ${res.statusCode}');
    }
  }

  /// 14. Delete an address by index
  Future<void> deleteAddress(String userId, int index) async {
    final res = await http.delete(
      Uri.parse('$_userBase/$userId/addresses/$index'),
    );
    if (res.statusCode != 204) {
      throw Exception('deleteAddress failed: ${res.statusCode}');
    }
  }
}
