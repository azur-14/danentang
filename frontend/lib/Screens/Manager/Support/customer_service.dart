import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:danentang/models/User.dart';
import 'package:danentang/Service/user_service.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';

class CustomerServiceScreen extends StatefulWidget {
  final String? userId;

  const CustomerServiceScreen({super.key, this.userId});

  @override
  State<CustomerServiceScreen> createState() => _CustomerServiceScreenState();
}

class _CustomerServiceScreenState extends State<CustomerServiceScreen> {
  late Future<void> _init;
  User? _currentUser;
  User? _peerUser;
  String? _role;
  List<Map<String, dynamic>> _messages = [];

  final TextEditingController _controller = TextEditingController();
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _init = _initializeUserAndMessages();
  }

  Future<void> _initializeUserAndMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? '';
      final role = prefs.getString('role') ?? 'customer';

      final service = UserService();
      final currentUser = await service.fetchUserByEmail(email);

      User peerUser;
      if (role == 'admin') {
        if (widget.userId == null) throw Exception('Thiếu userId cho admin');
        peerUser = await service.fetchUserById(widget.userId!);
      } else {
        peerUser = await service.fetchUserById("6826a468061b990b3152e9d2");
      }

      List<Map<String, dynamic>> messages = [];
      try {
        messages = await service.getMessages(currentUser.id, peerUser.id);
      } catch (_) {
        if (role != 'admin') {
          messages.add({
            'sender': 'admin',
            'content': 'Chào bạn! Hãy đặt câu hỏi nếu cần hỗ trợ.',
            'isFromCustomer': false,
            'createdAt': DateTime.now().toIso8601String(),
          });
        }
      }

      setState(() {
        _currentUser = currentUser;
        _peerUser = peerUser;
        _role = role;
        _messages = messages;
        _isLoading = false;
      });
    } catch (e) {
      print('[FATAL] Lỗi khởi tạo: $e');
      setState(() => _isLoading = false);
    }
  }

  bool get isAdmin => _role == 'admin';

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();

    print('[DEBUG] Bấm gửi: "$text"');
    print('[DEBUG] currentUser: ${_currentUser?.email}, peerUser: ${_peerUser?.email}');

    if (text.isEmpty || _currentUser == null || _peerUser == null) {
      print('[DEBUG] Không gửi: thiếu dữ liệu');
      return;
    }

    try {
      await UserService().sendMessage(
        userId: _peerUser!.id,
        senderId: _currentUser!.id,
        content: text,
        isFromCustomer: !isAdmin,
      );

      setState(() {
        _messages.add({
          'sender': isAdmin ? 'admin' : _currentUser!.email,
          'content': text,
          'isFromCustomer': !isAdmin,
          'createdAt': DateTime.now().toIso8601String(),
        });
        _controller.clear();
      });
      print('[DEBUG] Gửi thành công');
    } catch (e) {
      print("❌ Gửi tin nhắn lỗi: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done || _isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_peerUser == null || _currentUser == null) {
          return const Scaffold(
            body: Center(child: Text("Không thể tải nội dung. Vui lòng thử lại.")),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            title: Text(
              _peerUser!.fullName,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: isAdmin
                ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            )
                : null,
            actions: const [
              Icon(Icons.more_horiz, color: Colors.black),
              SizedBox(width: 10),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = isAdmin
                        ? !(msg['isFromCustomer'] ?? false)
                        : (msg['isFromCustomer'] ?? true);
                    return ChatBubble(
                      isUser: isUser,
                      message: msg['content'] ?? '',
                    );
                  },
                ),
              ),
              _buildChatInput(),
            ],
          ),
          bottomNavigationBar: isAdmin
              ? LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return MobileNavigationBar(
                  selectedIndex: _selectedIndex,
                  onItemTapped: (i) => setState(() => _selectedIndex = i),
                  isLoggedIn: true,
                  role: 'manager',
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          )
              : null,
        );
      },
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.grey.shade200,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Nhập tin nhắn...",
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send),
            color: Colors.white,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
              shape: MaterialStateProperty.all(CircleBorder()),
              padding: MaterialStateProperty.all(const EdgeInsets.all(16)),
            ),
          )
        ],
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
        position: Tween<Offset>(
          begin: Offset(isUser ? 1 : -1, 0),
          end: Offset.zero,
        ).animate(animation),
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
