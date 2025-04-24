import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(Filter_Order());
}

class Filter_Order extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OrderListScreen(),
    );
  }
}

class OrderListScreen extends StatefulWidget {
  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  String filter = "Day";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitConfirmation(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Order List"),
          actions: [
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => FilterSheet(
                    onSelectFilter: (selectedFilter) {
                      setState(() {
                        filter = selectedFilter;
                      });
                    },
                  ),
                );
              },
            )
          ],
          leading: _buildBackButton(context),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('orders').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                return OrderCard(
                  orderId: doc['id'],
                  user: doc['user'],
                  project: doc['project'],
                  address: doc['address'],
                  status: doc['status'],
                  date: doc['date'],
                );
              }).toList(),
            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }

  // Function to build the back button only on mobile devices
  Widget _buildBackButton(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        if (isMobile) {
          return IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () async {
              bool shouldPop = await _showExitConfirmation(context);
              if (shouldPop) {
                Navigator.pop(context);
              }
            },
          );
        } else {
          return SizedBox();  // Do not show back button on web
        }
      },
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Xác nhận"),
        content: Text("Bạn có muốn thoát khỏi màn hình này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Không"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Có"),
          ),
        ],
      ),
    ) ?? false;
  }
}

class OrderCard extends StatelessWidget {
  final String orderId, user, project, address, status, date;

  OrderCard({required this.orderId, required this.user, required this.project, required this.address, required this.status, required this.date});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text("#$orderId"),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("User: $user"),
            Text("Project: $project"),
            Text("Address: $address"),
            Text("Date: $date"),
          ],
        ),
        trailing: Chip(
          label: Text(status),
          backgroundColor: status == "Complete" ? Colors.green : Colors.purple,
        ),
      ),
    );
  }
}

class FilterSheet extends StatelessWidget {
  final Function(String) onSelectFilter;

  FilterSheet({required this.onSelectFilter});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilterButton(label: "Day", onPressed: () => onSelectFilter("Day")),
          FilterButton(label: "Week", onPressed: () => onSelectFilter("Week")),
          FilterButton(label: "Month", onPressed: () => onSelectFilter("Month")),
          FilterButton(label: "Year", onPressed: () => onSelectFilter("Year")),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  FilterButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(Icons.filter_alt),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}