import 'package:flutter/material.dart';

class User_Infomartion extends StatelessWidget {
  const User_Infomartion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UserDetailScreen(),
    );
  }
}

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key});

  void _banUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Xác nhận"),
          content: const Text("Bạn có chắc chắn muốn ban user này không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, "/banned"); // Chuyển sang BannedScreen
              },
              child: const Text("Ban", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "User Information",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/avatar1.png"),
            ),
            const SizedBox(height: 10),
            const Text(
              "ByeWind",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _userInfoTile("Serial", "#CM9801", false),
            _userInfoTile("Name", "ByeWind", false),
            _userInfoTile("Email", "byewind@twitter.com", true),
            _userInfoTile("Address", "Meadow Lane Oakland", true),
            _userInfoTile("Registration date", "Feb 2, 2024, 8:00 AM", false),
            _userInfoTile("Note", "Enter note here...", true),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => _banUser(context),
              child: const Text("Ban User", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.black),
                    onPressed: () {}, // Thêm chức năng xóa user tại đây
                  ),
                  IconButton(
                    icon: const Icon(Icons.save, color: Colors.black),
                    onPressed: () {}, // Thêm chức năng lưu thông tin tại đây
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _userInfoTile(String label, String value, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          isEditable
              ? Expanded(
                  child: TextField(
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      hintText: value,
                      border: InputBorder.none,
                    ),
                  ),
                )
              : Text(value, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}

class UserInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isEditable;

  const UserInfoTile({super.key, required this.label, required this.value, required this.isEditable});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: TextEditingController(text: value),
        readOnly: !isEditable,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}