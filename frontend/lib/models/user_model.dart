import 'package:flutter/foundation.dart';

class UserModel extends ChangeNotifier {
  bool _isLoggedIn;
  String _userName;
  String? _gender;
  String? _dateOfBirth;
  String? _phoneNumber;
  String? _email;
  String? _address;
  String? _avatarUrl;

  UserModel({
    required bool isLoggedIn,
    required String userName,
    String? gender,
    String? dateOfBirth,
    String? phoneNumber,
    String? email,
    String? address,
    String? avatarUrl,
  })  : _isLoggedIn = isLoggedIn,
        _userName = userName,
        _gender = gender,
        _dateOfBirth = dateOfBirth,
        _phoneNumber = phoneNumber,
        _email = email,
        _address = address,
        _avatarUrl = avatarUrl;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String? get gender => _gender;
  String? get dateOfBirth => _dateOfBirth;
  String? get phoneNumber => _phoneNumber;
  String? get email => _email;
  String? get address => _address;
  String? get avatarUrl => _avatarUrl;

  // Update method
  void updateUser({
    bool? isLoggedIn,
    String? userName,
    String? gender,
    String? dateOfBirth,
    String? phoneNumber,
    String? email,
    String? address,
    String? avatarUrl,
  }) {
    _isLoggedIn = isLoggedIn ?? _isLoggedIn;
    _userName = userName ?? _userName;
    _gender = gender ?? _gender;
    _dateOfBirth = dateOfBirth ?? _dateOfBirth;
    _phoneNumber = phoneNumber ?? _phoneNumber;
    _email = email ?? _email;
    _address = address ?? _address;
    _avatarUrl = avatarUrl ?? _avatarUrl;
    notifyListeners();
  }
}