import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';

class Customer_Service extends StatelessWidget {
  const Customer_Service({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CustomerServiceScreen(),
    );
  }
}

class CustomerServiceScreen extends StatefulWidget {
  const CustomerServiceScreen({super.key});

  @override
  _CustomerServiceScreenState createState() => _CustomerServiceScreenState();
}

class _CustomerServiceScreenState extends State<CustomerServiceScreen> {
  // Initialize selectedIndex
  int _selectedIndex = 0;

  // Handle navigation item tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Customer Support",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Icon(Icons.more_horiz, color: Colors.black),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: const [
                Text(
                  "Natali Craig",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "Mã Đơn Hàng: #CM9801",
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10),
              children: const [
                ChatBubble(isUser: false, message: "Xin chào, tôi cần hỗ trợ về đơn hàng của mình."),
                ChatBubble(isUser: true, message: "Chào bạn, bạn cần hỗ trợ gì ạ?"),
              ],
            ),
          ),
          const ChatInputField(),
        ],
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return MobileNavigationBar(
              selectedIndex: _selectedIndex, // Pass selectedIndex
              onItemTapped: _onItemTapped, // Pass the callback for item taps
              isLoggedIn: true, // Set the login status (you can update this based on your actual logic)
            );
          } else {
            return SizedBox.shrink(); // Ẩn BottomNavigationBar trên web
          }
        },
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final bool isUser;
  final String message;

  const ChatBubble({super.key, required this.isUser, required this.message});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => SlideTransition(
        position: Tween<Offset>(begin: Offset(isUser ? 1 : -1, 0), end: Offset.zero)
            .animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      ),
      child: Align(
        key: ValueKey<String>(message),
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          decoration: BoxDecoration(
            color: isUser ? Colors.blueAccent : Colors.grey.shade300,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 0),
              bottomRight: Radius.circular(isUser ? 0 : 16),
            ),
          ),
          child: Text(
            message,
            style: TextStyle(color: isUser ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}

class ChatInputField extends StatelessWidget {
  const ChatInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.grey.shade200,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Nhập tin nhắn...",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              // TODO: Gửi tin nhắn
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}