import 'package:flutter/material.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NoDataScreen(),
    );
  }
}

class NoDataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'No date',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Image.asset('assets/no_data.png', height: 100),
            const SizedBox(height: 20),
            const Text(
              'You may need',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            OptionCard(
              icon: Icons.rocket_launch_outlined,
              title: 'Launch product',
              subtitle: 'If you haven’t launched your product yet, come back when you do.',
            ),
            OptionCard(
              icon: Icons.access_time,
              title: 'Waiting for data',
              subtitle: 'Wait for your product running data.',
            ),
            OptionCard(
              icon: Icons.add,
              title: 'Adding data',
              subtitle: 'Please add data manually on other pages.',
            ),
          ],
        ),
      ),
    );
  }
}

class OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
