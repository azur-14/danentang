import 'package:flutter/material.dart';
import '../../widgets/Footer/mobile_navigation_bar.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NoInternetScreen(),
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600; // Check if the screen is mobile-sized

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'No data',
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
            AnimatedOptionCard(
              delay: 200,
              icon: Icons.rocket_launch_outlined,
              title: 'Launch product',
              subtitle: 'If you haven’t launched your product yet, come back when you do.',
            ),
            AnimatedOptionCard(
              delay: 400,
              icon: Icons.access_time,
              title: 'Waiting for data',
              subtitle: 'Wait for your product running data.',
            ),
            AnimatedOptionCard(
              delay: 600,
              icon: Icons.add,
              title: 'Adding data',
              subtitle: 'Please add data manually on other pages.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: isMobile
          ? MobileNavigationBar(
        selectedIndex: 0, // Adjust the selected index based on your needs
        onItemTapped: (index) {
          // Handle navigation or state change when tapping on an item
          print("Tapped on item: $index");
        },
        isLoggedIn: true, // Set based on your app's login status
      )
          : null,
    );
  }
}

class AnimatedOptionCard extends StatefulWidget {
  final int delay;
  final IconData icon;
  final String title;
  final String subtitle;

  const AnimatedOptionCard({
    required this.delay,
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  _AnimatedOptionCardState createState() => _AnimatedOptionCardState();
}

class _AnimatedOptionCardState extends State<AnimatedOptionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _offsetAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: OptionCard(
          icon: widget.icon,
          title: widget.title,
          subtitle: widget.subtitle,
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
