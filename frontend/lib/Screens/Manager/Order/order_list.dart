import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';

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
  bool _isLoggedIn = true;  // Assuming the user is logged in

  final List<Order> orders = [
    Order("#CM9801", "Natali Craig", "Landing Page", "Meadow Lane Oakland", "Just now", "In Progress", Colors.purple.shade100, Colors.purple),
    Order("#CM9802", "Kate Morrison", "CRM Admin pages", "Larry San Francisco", "A minute ago", "Complete", Colors.green.shade100, Colors.green),
    Order("#CM9803", "Drew Cano", "Client Project", "Bagwell Avenue Ocala", "1 hour ago", "Pending", Colors.blue.shade100, Colors.blue),
    Order("#CM9804", "Orlando Diggs", "Admin Dashboard", "Washburn Baton Rouge", "Yesterday", "Approved", Colors.yellow.shade100, Colors.yellow),
    Order("#CM9805", "Andi Lane", "App Landing Page", "Nest Lane Olivette", "Feb 2, 2024", "Rejected", Colors.grey.shade300, Colors.grey),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Order List",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);  // Directly pop without confirmation
          },
        )
            : const SizedBox(),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.grey.shade100,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return FadeInOrderCard(order: orders[index], index: index);
        },
      ),
      bottomNavigationBar: isMobile
          ? MobileNavigationBar(
        selectedIndex: _currentIndex,
        onItemTapped: _onItemTapped,
        isLoggedIn: _isLoggedIn,  // Add this argument
      )
          : null,
    );
  }
}

class FadeInOrderCard extends StatefulWidget {
  final Order order;
  final int index;

  const FadeInOrderCard({super.key, required this.order, required this.index});

  @override
  _FadeInOrderCardState createState() => _FadeInOrderCardState();
}

class _FadeInOrderCardState extends State<FadeInOrderCard> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    )..addListener(() {
      setState(() {});
    });
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _fadeAnimation.value,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
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
                Text(widget.order.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.order.statusColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(widget.order.status, style: TextStyle(color: widget.order.statusTextColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/Manager/Avatar/avatar.jpg'),
                  radius: 12,
                ),
                const SizedBox(width: 8),
                Text(widget.order.user, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow("Project", widget.order.project),
            _buildInfoRow("Address", widget.order.address),
            _buildInfoRow("Date", widget.order.date),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Order {
  final String id, user, project, address, date, status;
  final Color statusColor, statusTextColor;

  Order(this.id, this.user, this.project, this.address, this.date, this.status, this.statusColor, this.statusTextColor);
}