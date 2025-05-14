import 'package:danentang/models/User.dart';
import 'package:danentang/models/Address.dart';

class UserData {
  static Map<String, dynamic> userData = {
    'isLoggedIn': true,
    'userName': 'Diew Ne',
    'gender': 'Nữ',
    'dateOfBirth': '2023-05-09',
    'phoneNumber': '0901234567',
    'email': 'example@gmail.com',
    'address': '1901 Thornridge Cir, Shiloh, Hawaii 81063',
    'avatarUrl': 'https://example.com/avatar.jpg',
  };

  static User toUser() {
    return User(
      id: 'user_001', // ID tĩnh để test
      email: userData['email'] as String? ?? 'example@gmail.com',
      fullName: userData['userName'] as String? ?? 'Diew Ne',
      role: 'customer', // Role mặc định
      status: 'active', // Status mặc định
      loyaltyPoints: 0, // Mặc định
      gender: userData['gender'] as String? ?? 'Nữ',
      dateOfBirth: DateTime.tryParse(userData['dateOfBirth'] as String? ?? ''),
      phoneNumber: userData['phoneNumber'] as String? ?? '0901234567',
      avatarUrl: userData['avatarUrl'] as String? ?? 'https://example.com/avatar.jpg',
      isEmailVerified: true, // Mặc định
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      addresses: [
        Address(
          receiverName: 'Diew Ne',
          phone: '0901234567',
          addressLine: userData['address'] as String? ?? '1901 Thornridge Cir, Shiloh, Hawaii 81063',
          commune: 'Shiloh',
          district: null,
          city: 'Hawaii',
          isDefault: true,
          createdAt: DateTime(2025, 5, 1),
        ),
        Address(
          receiverName: 'Tran Thi B',
          phone: '0912345678',
          addressLine: '123 Le Loi St',
          commune: 'District 1',
          district: 'Ho Chi Minh City',
          city: null,
          isDefault: false,
          createdAt: DateTime(2025, 5, 5),
        ),
        Address(
          receiverName: 'Le Van C',
          phone: '0923456789',
          addressLine: '456 Hai Ba Trung St',
          commune: 'Ba Dinh',
          district: 'Ha Noi',
          city: null,
          isDefault: false,
          createdAt: DateTime(2025, 5, 10),
        ),
      ],
    );
  }
}