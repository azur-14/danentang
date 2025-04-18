import 'package:flutter/material.dart';

class Order_List extends StatelessWidget {
  const Order_List({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OrdersListScreen(),
    );
  }
}

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  _OrdersListScreenState createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  int _currentIndex = 0;

  final List<Order> orders = [
    Order("#CM9801", "Natali Craig", "Landing Page", "Meadow Lane Oakland", "Just now", "In Progress", Colors.purple.shade100, Colors.purple),
    Order("#CM9802", "Kate Morrison", "CRM Admin pages", "Larry San Francisco", "A minute ago", "Complete", Colors.green.shade100, Colors.green),
    Order("#CM9803", "Drew Cano", "Client Project", "Bagwell Avenue Ocala", "1 hour ago", "Pending", Colors.blue.shade100, Colors.blue),
    Order("#CM9804", "Orlando Diggs", "Admin Dashboard", "Washburn Baton Rouge", "Yesterday", "Approved", Colors.yellow.shade100, Colors.yellow),
    Order("#CM9805", "Andi Lane", "App Landing Page", "Nest Lane Olivette", "Feb 2, 2024", "Rejected", Colors.grey.shade300, Colors.grey),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(
        title: Text("Order List", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade100,
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return OrderCard(order: orders[index]);
        },
      ),
      bottomNavigationBar: isMobile ? BottomNavigationBar(
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
      ) : null,
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(order.id, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: order.statusColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(order.status, style: TextStyle(color: order.statusTextColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/avatar.png'),
                radius: 12,
              ),
              SizedBox(width: 8),
              Text(order.user, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8),
          _buildInfoRow("Project", order.project),
          _buildInfoRow("Address", order.address),
          _buildInfoRow("Date", order.date),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("$title: ", style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}

class Order {
  final String id, user, project, address, date, status;
  final Color statusColor, statusTextColor;

  Order(this.id, this.user, this.project, this.address, this.date, this.status, this.statusColor, this.statusTextColor);
}