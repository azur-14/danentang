import 'package:flutter/material.dart';

class User_Details extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: UserDetailsScreen(),
    );
  }
}

class UserDetailsScreen extends StatelessWidget {
  final List<User> users = [
    User("#CM9801", "Natali Craig", "smith@kpmg.com", "Meadow Lane Oakland", "Just now", "assets/avatar1.png"),
    User("#CM9802", "Kate Morrison", "melody@altbox.com", "Larry San Francisco", "A minute ago", "assets/avatar2.png"),
    User("#CM9803", "Drew Cano", "max@kt.com", "Bagwell Avenue Ocala", "1 hour ago", "assets/avatar3.png"),
    User("#CM9804", "Orlando Diggs", "sean@dellito.com", "Washburn Baton Rouge", "Yesterday", "assets/avatar4.png"),
    User("#CM9805", "Andi Lane", "brian@exchange.com", "Nest Lane Olivette", "Feb 2, 2024", "assets/avatar5.png"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "User List",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: users.length,
        itemBuilder: (context, index) {
          return UserCard(user: users[index]);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {},
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.filter_list), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.swap_vert), label: ''),
        ],
      ),
    );
  }
}

class User {
  final String id, name, email, address, date, avatar;

  User(this.id, this.name, this.email, this.address, this.date, this.avatar);
}

class UserCard extends StatelessWidget {
  final User user;

  UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(user.id, style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage(user.avatar),
                ),
                SizedBox(width: 8),
                Text(user.name),
              ],
            ),
            SizedBox(height: 8),
            UserInfoRow(label: "Email", value: user.email),
            UserInfoRow(label: "Address", value: user.address),
            UserInfoRow(label: "Date", value: user.date),
          ],
        ),
      ),
    );
  }
}

class UserInfoRow extends StatelessWidget {
  final String label;
  final String value;

  UserInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("$label ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Expanded(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}