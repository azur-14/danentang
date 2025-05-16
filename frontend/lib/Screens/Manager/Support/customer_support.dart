import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:danentang/models/User.dart';
import 'package:danentang/Service/user_service.dart';
import 'package:danentang/Screens/Manager/Support/customer_service.dart';
import '../../../ultis/image_helper.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';

class Customer_Support extends StatelessWidget {
  const Customer_Support({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CustomerSupportScreen(),
    );
  }
}

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  _CustomerSupportScreenState createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  int _selectedIndex = 0;
  List<User> _users = [];
  List<bool> _selectedTickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final userService = UserService();
      final users = await userService.getComplainingUsers();
      setState(() {
        _users = users;
        _selectedTickets = List.generate(users.length, (_) => false);
        _isLoading = false;
      });
    } catch (e) {
      print("Lỗi khi tải danh sách người dùng khiếu nại: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleTicketSelection(int index) {
    setState(() {
      _selectedTickets[index] = !_selectedTickets[index];
    });
  }

  void _selectAllTickets() {
    setState(() {
      for (int i = 0; i < _selectedTickets.length; i++) {
        _selectedTickets[i] = true;
      }
    });
  }

  void _deselectAllTickets() {
    setState(() {
      for (int i = 0; i < _selectedTickets.length; i++) {
        _selectedTickets[i] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: isMobile
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
            : const SizedBox(),
        title: const Text(
          "Hỗ trợ người dùng",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'select_all':
                  _selectAllTickets();
                  break;
                case 'deselect_all':
                  _deselectAllTickets();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'select_all',
                child: Text('Chọn tất cả'),
              ),
              const PopupMenuItem<String>(
                value: 'deselect_all',
                child: Text('Bỏ chọn tất cả'),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          return AnimatedSupportTicketItem(
            delay: index * 200,
            isSelected: _selectedTickets[index],
            onTap: () => _toggleTicketSelection(index),
            user: _users[index],
          );
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return MobileNavigationBar(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              isLoggedIn: true,
              role: 'manager',
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class AnimatedSupportTicketItem extends StatefulWidget {
  final int delay;
  final bool isSelected;
  final VoidCallback onTap;
  final User user;

  const AnimatedSupportTicketItem({
    super.key,
    required this.delay,
    required this.isSelected,
    required this.onTap,
    required this.user,
  });

  @override
  State<AnimatedSupportTicketItem> createState() =>
      _AnimatedSupportTicketItemState();
}

class _AnimatedSupportTicketItemState extends State<AnimatedSupportTicketItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _offsetAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );
    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _opacity,
        child: GestureDetector(
          onLongPress: widget.onTap,
          child: SupportTicketItem(
            isSelected: widget.isSelected,
            user: widget.user,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SupportTicketItem extends StatelessWidget {
  final bool isSelected;
  final User user;

  const SupportTicketItem({
    super.key,
    required this.isSelected,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("#${user.id.substring(user.id.length - 5)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text("Đang thực hiện",
                    style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                    ? memoryImageProvider(user.avatarUrl!)
                    : const AssetImage('assets/Manager/Avatar/avatar.jpg') as ImageProvider,
                radius: 14,
              ),
              const SizedBox(width: 10),
              Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          _buildInfoRow("Email", user.email),
          _buildInfoRow("Mã người dùng", user.id),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerServiceScreen(userId: user.id)
                ),
              );
            },
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text("Đã Gửi Đến Bạn Một Tin Nhắn",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
