import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:danentang/models/User.dart';
import 'package:danentang/Service/user_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // Thêm import cho image_picker
import 'dart:io'; // Để xử lý file hình ảnh
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
  WebSocketChannel? _channel;
  final ImagePicker _picker = ImagePicker(); // Khởi tạo ImagePicker

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

      List<Map<String, dynamic>> messages = await service.getMessages(currentUser.id, peerUser.id);

      // Kết nối WebSocket
      _channel = WebSocketChannel.connect(Uri.parse("ws://localhost:5012/ws/complaint"));
      print('[WS] Đã kết nối WebSocket');

      _channel!.stream.listen((data) {
        final msg = jsonDecode(data);
        if (msg['senderId'] == _peerUser!.id &&
            msg['receiverId'] == _currentUser!.id) {
          setState(() {
            _messages.add({
              'sender': msg['isFromCustomer'] ? 'customer' : 'admin',
              'content': msg['content'],
              'isFromCustomer': msg['isFromCustomer'],
              'createdAt': msg['createdAt'],
              'image': msg['imageUrl'], // lấy đúng trường imageUrl
              // Hỗ trợ hình ảnh từ WebSocket
            });
          });
        }
      });

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
    if (text.isEmpty || _currentUser == null || _peerUser == null) return;

    final msg = {
      'senderId': _currentUser!.id,
      'receiverId': _peerUser!.id,
      'content': text,
      'isFromCustomer': !isAdmin,
    };

    _channel?.sink.add(jsonEncode(msg));

    setState(() {
      _messages.add({
        'sender': isAdmin ? 'admin' : _currentUser!.email,
        'content': text,
        'isFromCustomer': !isAdmin,
        'createdAt': DateTime.now().toIso8601String(),
      });
      _controller.clear();
    });
  }

  Future<void> _pickAndSendImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null || _currentUser == null || _peerUser == null) return;

      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      final msg = {
        'senderId': _currentUser!.id,
        'receiverId': _peerUser!.id,
        'content': '', // hoặc null
        'isFromCustomer': !isAdmin,
        'imageUrl': base64Image, // đúng tên trường imageUrl
      };
      _channel?.sink.add(jsonEncode(msg));


      // 2. Gửi qua API để lưu lịch sử (tùy backend, dùng imageUrl/ image base64)
      await UserService().sendMessage(
        userId: _peerUser!.id,
        senderId: _currentUser!.id,
        content: '',        // gửi trống vì đây là ảnh
        isFromCustomer: !isAdmin,
        imageUrl: base64Image, // truyền base64 vào đây
      );

      setState(() {
        _messages.add({
          'sender': isAdmin ? 'admin' : _currentUser!.email,
          'content': '',
          'isFromCustomer': !isAdmin,
          'createdAt': DateTime.now().toIso8601String(),
          'imageUrl': base64Image,
        });
      });
    } catch (e) {
      print('[ERROR] Lỗi khi chọn hình ảnh: $e');
    }
  }


  @override
  void dispose() {
    _channel?.sink.close();
    _controller.dispose();
    super.dispose();
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
                    final createdAt = msg['createdAt'];
                    return ChatBubble(
                      isUser: isUser,
                      message: msg['content'] ?? '',
                      time: createdAt != null
                          ? DateFormat('hh:mm a').format(DateTime.parse(createdAt).toLocal())
                          : '',
                      image: msg['imageUrl'], // lấy đúng trường imageUrl
// Truyền image vào ChatBubble
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
          IconButton(
            onPressed: _pickAndSendImage, // Gọi hàm chọn và gửi hình ảnh
            icon: const Icon(Icons.image),
            color: Colors.white,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
              shape: MaterialStateProperty.all(CircleBorder()),
              padding: MaterialStateProperty.all(const EdgeInsets.all(16)),
            ),
          ),
          const SizedBox(width: 10),
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
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final bool isUser;
  final String message;
  final String time;
  final String? image; // Thêm thuộc tính image

  const ChatBubble({
    super.key,
    required this.isUser,
    required this.message,
    required this.time,
    this.image,
  });

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
        key: ValueKey<String>(message + time + (image ?? '')),
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
          child: Column(
            crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (image != null)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullImageScreen(base64Image: image!),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Image.memory(
                      base64Decode(image!),
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 100, color: Colors.red),
                    ),
                  ),
                ),

              if (message.isNotEmpty) // Hiển thị tin nhắn nếu có
                Text(
                  message,
                  style: TextStyle(color: isUser ? Colors.white : Colors.black),
                ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  color: isUser ? Colors.white70 : Colors.black54,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}class FullImageScreen extends StatelessWidget {
  final String base64Image;
  const FullImageScreen({Key? key, required this.base64Image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.memory(
            base64Decode(base64Image),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
