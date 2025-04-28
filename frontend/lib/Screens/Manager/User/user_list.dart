import 'package:danentang/Screens/Manager/User/user_information.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:danentang/Screens/Manager/User/user_details.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  int _currentIndex = 0;

  final List<User> users = [
    User("ByeWind", "byewind@twitter.com", "Meadow Lane Oakland", "Just now",
        "assets/Manager/Avatar/avatar01.jpg"),
    User("Kate Morrison", "melody@altbox.com", "Larry San Francisco",
        "A minute ago", "assets/Manager/Avatar/avatar02.jpg"),
    User("Drew Cano", "max@kt.com", "Bagwell Avenue Ocala", "1 hour ago",
        "assets/Manager/Avatar/avatar03.png"),
    User(
        "Orlando Diggs", "sean@delito.com", "Washburn Baton Rouge", "Yesterday",
        "assets/Manager/Avatar/avatar04.jpg"),
    User("Andi Lane", "brian@exchange.com", "Nest Lane Olivette", "Feb 2, 2024",
        "assets/Manager/Avatar/avatar05.jpg"),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Center(
                child: Text(
                  "User List",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: (defaultTargetPlatform == TargetPlatform.android ||
                    defaultTargetPlatform == TargetPlatform.iOS)
                    ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
                    : const SizedBox(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.black),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              AlertDialog(
                                title: const Text("Thông tin"),
                                content: const Text(
                                    "Đây là danh sách người dùng với thông tin chi tiết của họ."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (
                                            context) => const UserDetailsScreen()),
                                      );
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                        );
                      },
                    ),
                    PopupMenuButton<int>(
                      icon: const Icon(Icons.more_horiz, color: Colors.black),
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) {
                        if (value == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Select selected')),
                          );
                        } else if (value == 1) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Select and edit selected')),
                          );
                        } else if (value == 2) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Larger avatar layout selected')),
                          );
                        }
                      },
                      itemBuilder: (context) =>
                      [
                        PopupMenuItem(
                          value: 0,
                          child: Row(
                            children: const [
                              Expanded(child: Text('Select')),
                              Icon(Icons.check, size: 18, color: Colors.grey),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 1,
                          child: Row(
                            children: const [
                              Expanded(child: Text('Select and edit')),
                              Icon(Icons.edit, size: 18, color: Colors.grey),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Row(
                            children: const [
                              Expanded(child: Text('Larger avatar layout')),
                              Icon(Icons.person, size: 18, color: Colors.grey),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            return AnimatedUserCard(user: users[index], delay: index * 150);
          },
        ),
      ),
      bottomNavigationBar: isMobile
          ? MobileNavigationBar(
        selectedIndex: _currentIndex,
        onItemTapped: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        isLoggedIn: true,
        role: 'manager',
      )
          : null,
    );
  }
}

    class AnimatedUserCard extends StatefulWidget {
  final User user;
  final int delay;

  const AnimatedUserCard({super.key, required this.user, required this.delay});

  @override
  _AnimatedUserCardState createState() => _AnimatedUserCardState();
}

class _AnimatedUserCardState extends State<AnimatedUserCard> with SingleTickerProviderStateMixin {
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

    _offsetAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserInformation()),
            );
          },
          child: UserCard(user: widget.user),
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

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(user.avatar),
            radius: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.email, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(user.email, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(user.address, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(user.time, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class User {
  final String name, email, address, time, avatar;

  User(this.name, this.email, this.address, this.time, this.avatar);
}