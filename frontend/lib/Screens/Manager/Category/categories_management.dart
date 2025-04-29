import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';

class CategoriesManagement extends StatelessWidget {
  const CategoriesManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveCategoriesScreen();
  }
}

//================================//
//       Responsive Wrapper       //
//================================//
class ResponsiveCategoriesScreen extends StatelessWidget {
  const ResponsiveCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return PageTransitionSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation, secondaryAnimation) => FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          ),
          child: isMobile
              ? const MobileCategoriesScreen(key: ValueKey("Mobile"))
              : const WebCategoriesScreen(key: ValueKey("Web")),
        );
      },
    );
  }
}

//===========================//
//        Mobile Layout      //
//===========================//
class MobileCategoriesScreen extends StatefulWidget {
  const MobileCategoriesScreen({super.key});

  @override
  _MobileCategoriesScreenState createState() => _MobileCategoriesScreenState();
}

class _MobileCategoriesScreenState extends State<MobileCategoriesScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Categories Management",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => _handleBack(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _categoryTile("Laptop", Icons.laptop),
            _categoryTile("Điện Thoại", Icons.phone_android),
            _categoryTile("Phụ Kiện", Icons.build),
            const SizedBox(height: 20),
            const CategoryForm(),
          ],
        ),
      ),
      bottomNavigationBar: MobileNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        isLoggedIn: true,
        role: 'manager',
      ),
    );
  }

  Widget _categoryTile(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 50),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Text("Xem Chi Tiết", style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

//===========================//
//         Web Layout        //
//===========================//
class WebCategoriesScreen extends StatelessWidget {
  const WebCategoriesScreen({super.key});

  void _handleBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Widget _categoryTile(String title, IconData icon) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8),
      child: ListTile(
        leading: Icon(icon, size: 40, color: Colors.purple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        trailing: const Text("Xem Chi Tiết"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categories Management", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => _handleBack(context),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[100],
              child: ListView(
                children: [
                  _categoryTile("Laptop", Icons.laptop),
                  _categoryTile("Điện Thoại", Icons.phone_android),
                  _categoryTile("Phụ Kiện", Icons.build),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: const CategoryForm(),
            ),
          ),
        ],
      ),
    );
  }
}

//===========================//
//      Category Form        //
//===========================//
class CategoryForm extends StatelessWidget {
  const CategoryForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Thêm Mới Danh Mục", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        const Text("Tên Danh Mục"),
        const SizedBox(height: 5),
        const TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10),
          ),
        ),
        const SizedBox(height: 10),
        const Text("Ảnh Danh Mục"),
        ElevatedButton(onPressed: () {}, child: const Text("Browse")),
        const SizedBox(height: 10),
        const Text("Mô Tả"),
        const TextField(
          maxLines: 3,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            onPressed: () {},
            child: const Text("Tạo Danh Mục", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}