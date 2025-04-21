import 'package:flutter/material.dart';

class User_Details extends StatelessWidget {
  const User_Details({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const UserDetailsScreen(),
    );
  }
}

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<User> users = [
    User("#CM9801", "Natali Craig", "smith@kpmg.com", "Meadow Lane Oakland", "Just now", "assets/Manager/Avatar/avatar01.jpg"),
    User("#CM9802", "Kate Morrison", "melody@altbox.com", "Larry San Francisco", "A minute ago", "assets/Manager/Avatar/avatar02.jpg"),
    User("#CM9803", "Drew Cano", "max@kt.com", "Bagwell Avenue Ocala", "1 hour ago", "assets/Manager/Avatar/avatar03.jpg"),
    User("#CM9804", "Orlando Diggs", "sean@dellito.com", "Washburn Baton Rouge", "Yesterday", "assets/Manager/Avatar/avatar04.jpg"),
    User("#CM9805", "Andi Lane", "brian@exchange.com", "Nest Lane Olivette", "Feb 2, 2024", "assets/Manager/Avatar/avatar05.jpg"),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text("User List", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SizeTransition(
        sizeFactor: _animation,
        axisAlignment: -1,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (isMobile) {
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return UserCard(user: users[index]);
                  },
                );
              } else {
                return GridView.builder(
                  itemCount: users.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    return UserCard(user: users[index]);
                  },
                );
              }
            },
          ),
        ),
      ),
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.purple,
              unselectedItemColor: Colors.grey,
              currentIndex: 0,
              onTap: (index) {},
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.filter_list), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.swap_vert), label: ''),
              ],
            )
          : null,
    );
  }
}

class User {
  final String id, name, email, address, date, avatar;

  User(this.id, this.name, this.email, this.address, this.date, this.avatar);
}

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(user.id, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage(user.avatar),
                ),
                const SizedBox(width: 8),
                Text(user.name),
              ],
            ),
            const SizedBox(height: 8),
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

  const UserInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("$label ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Expanded(child: Text(value, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}