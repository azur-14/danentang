import 'package:flutter/foundation.dart'; // To use defaultTargetPlatform
import 'package:flutter/material.dart';
import 'package:danentang/Screens/Manager/User/user_details.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  int _currentIndex = 0;

  final List<User> users = [
    User("ByeWind", "byewind@twitter.com", "Meadow Lane Oakland", "Just now", "assets/Manager/Avatar/avatar01.jpg"),
    User("Kate Morrison", "melody@altbox.com", "Larry San Francisco", "A minute ago", "assets/Manager/Avatar/avatar02.jpg"),
    User("Drew Cano", "max@kt.com", "Bagwell Avenue Ocala", "1 hour ago", "assets/Manager/Avatar/avatar03.png"),
    User("Orlando Diggs", "sean@delito.com", "Washburn Baton Rouge", "Yesterday", "assets/Manager/Avatar/avatar04.jpg"),
    User("Andi Lane", "brian@exchange.com", "Nest Lane Olivette", "Feb 2, 2024", "assets/Manager/Avatar/avatar05.jpg"),
  ];

  Future<bool> confirmBackDialog() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn quay lại?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Có'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android;

    return WillPopScope(
      onWillPop: () async {
        if (await confirmBackDialog()) {
          return true;
        }
        return false;
      },
      child: Scaffold(
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
                          onPressed: () async {
                            if (await confirmBackDialog()) {
                              Navigator.of(context).maybePop();
                            }
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
                            builder: (context) => AlertDialog(
                              title: const Text("Thông tin"),
                              content: const Text("Đây là danh sách người dùng với thông tin chi tiết của họ."),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const UserDetailsScreen()),
                                    );
                                  },
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz, color: Colors.black),
                        onPressed: () {},
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
              return UserCard(user: users[index]);
            },
          ),
        ),
        bottomNavigationBar: isMobile
            ? BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.purple,
                unselectedItemColor: Colors.grey,
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
                  BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
                  BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                ],
              )
            : null, // Ẩn BottomNavigationBar trên web
      ),
    );
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