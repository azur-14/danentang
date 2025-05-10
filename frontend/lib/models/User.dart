// lib/models/user_model.dart

import 'package:flutter/foundation.dart';
import 'address.dart';

class User extends ChangeNotifier {
  bool _isLoggedIn;
  String _userName;
  String _email;
  String? _role;
  String _status;            // "Active", "Suspended", "Banned"
  int _loyaltyPoints;
  String? _gender;
  String? _dateOfBirth;      // ISO string
  String? _phoneNumber;
  String? _avatarUrl;
  bool _isEmailVerified;
  List<Address> _addresses;

  User({
    required bool isLoggedIn,
    required String userName,
    required String email,
    String? role,
    String status = 'Active',
    int loyaltyPoints = 0,
    String? gender,
    String? dateOfBirth,
    String? phoneNumber,
    String? avatarUrl,
    bool isEmailVerified = false,
    List<Address>? addresses,
  })  : _isLoggedIn = isLoggedIn,
        _userName = userName,
        _email = email,
        _role = role,
        _status = status,
        _loyaltyPoints = loyaltyPoints,
        _gender = gender,
        _dateOfBirth = dateOfBirth,
        _phoneNumber = phoneNumber,
        _avatarUrl = avatarUrl,
        _isEmailVerified = isEmailVerified,
        _addresses = addresses ?? [];

  // getters
  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get email => _email;
  String? get role => _role;
  String get status => _status;
  int get loyaltyPoints => _loyaltyPoints;
  String? get gender => _gender;
  String? get dateOfBirth => _dateOfBirth;
  String? get phoneNumber => _phoneNumber;
  String? get avatarUrl => _avatarUrl;
  bool get isEmailVerified => _isEmailVerified;
  List<Address> get addresses => List.unmodifiable(_addresses);

  /// Update any subset of fields
  void updateUser({
    bool? isLoggedIn,
    String? userName,
    String? email,
    String? role,
    String? status,
    int? loyaltyPoints,
    String? gender,
    String? dateOfBirth,
    String? phoneNumber,
    String? avatarUrl,
    bool? isEmailVerified,
    List<Address>? addresses,
  }) {
    _isLoggedIn = isLoggedIn ?? _isLoggedIn;
    _userName = userName ?? _userName;
    _email = email ?? _email;
    _role = role ?? _role;
    _status = status ?? _status;
    _loyaltyPoints = loyaltyPoints ?? _loyaltyPoints;
    _gender = gender ?? _gender;
    _dateOfBirth = dateOfBirth ?? _dateOfBirth;
    _phoneNumber = phoneNumber ?? _phoneNumber;
    _avatarUrl = avatarUrl ?? _avatarUrl;
    _isEmailVerified = isEmailVerified ?? _isEmailVerified;
    if (addresses != null) {
      _addresses = List.from(addresses);
    }
    notifyListeners();
  }
}
