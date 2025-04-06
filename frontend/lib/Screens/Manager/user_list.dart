import 'package:flutter/material.dart';
import 'package:danentang/Screens/Manager/user_details.dart';

class User_List extends StatelessWidget {
  const User_List({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UserListScreen(),
    );
  }
}

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  int _currentIndex = 0;

  final List<User> users = [
    User("ByeWind", "byewind@twitter.com", "Meadow Lane Oakland", "Just now", "assets/avatar1.png"),
    User("Kate Morrison", "melody@altbox.com", "Larry San Francisco", "A minute ago", "assets/avatar2.png"),
    User("Drew Cano", "max@kt.com", "Bagwell Avenue Ocala", "1 hour ago", "assets/avatar3.png"),
    User("Orlando Diggs", "sean@delito.com", "Washburn Baton Rouge", "Yesterday", "assets/avatar4.png"),
    User("Andi Lane", "brian@exchange.com", "Nest Lane Olivette", "Feb 2, 2024", "assets/avatar5.png"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User List", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Thông tin"),
                  content: Text("Đây là danh sách người dùng với thông tin chi tiết của họ."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Đóng AlertDialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserDetailsScreen()),
                        );
                      },
                      child: Text("OK"),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade100,
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          return UserCard(user: users[index]);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
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
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
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
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.email, size: 16, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(user.email, style: TextStyle(color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(user.address, style: TextStyle(color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(user.time, style: TextStyle(color: Colors.grey)),
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