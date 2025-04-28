import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/widgets/category_icon.dart';
import 'package:danentang/widgets/footer.dart';
import 'package:danentang/widgets/product_section.dart';
import 'package:danentang/widgets/Header/mobile_header.dart';
import 'package:danentang/widgets/Header/web_header.dart';
import 'package:danentang/widgets/Search/mobile_search_bar.dart';
import 'package:danentang/widgets/Search/web_search_bar.dart';
import 'package:danentang/widgets/Footer/mobile_navigation_bar.dart';
import 'package:danentang/widgets/banner_section.dart';
import 'package:provider/provider.dart';
import 'package:danentang/models/user_model.dart';
import 'package:danentang/service/product_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  bool showAllCategories = false;

  List<Product> allProducts = [];
  bool isLoading = true;

  void _onItemTapped(int index, BuildContext context) {
    final user = Provider.of<UserModel>(context, listen: false);
    if (!user.isLoggedIn) {
      context.go('/login');
      return;
    }
    setState(() {
      selectedIndex = index;
    });
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/cart', extra: user.isLoggedIn);
        break;
      case 2:
        context.go('/profile', extra: user.isLoggedIn);
        break;
      case 3:
        context.go('/chat');
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ProductService.fetchAllProducts();
      setState(() {
        allProducts = products;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  int _calculateItemsPerRow(double screenWidth, double itemWidth, double spacing, double horizontalPadding) {
    double availableWidth = screenWidth - (horizontalPadding * 2);
    return ((availableWidth + spacing) / (itemWidth + spacing)).floor();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 800 ? _buildWebLayout(context, screenWidth) : _buildMobileLayout(context, screenWidth);
  }

  Widget _buildMobileLayout(BuildContext context, double screenWidth) {
    final user = Provider.of<UserModel>(context);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    const double categoryItemWidth = 80;
    const double categorySpacing = 4;
    const double categoryHorizontalPadding = 16;
    int categoryItemsPerRow = _calculateItemsPerRow(
      screenWidth,
      categoryItemWidth,
      categorySpacing,
      categoryHorizontalPadding,
    );

    final categories = [
      const CategoryIcon(icon: Icons.laptop, label: "Laptops"),
      const CategoryIcon(icon: Icons.sports_esports, label: "Gaming"),
      const CategoryIcon(icon: Icons.laptop_mac, label: "Ultrabooks"),
      const CategoryIcon(icon: Icons.work, label: "Workstations"),
      const CategoryIcon(icon: Icons.money_off, label: "Budget"),
      const CategoryIcon(icon: Icons.tablet, label: "2-in-1"),
      const CategoryIcon(icon: Icons.desktop_windows, label: "Desktops"),
      const CategoryIcon(icon: Icons.assessment, label: "Accessories"),
    ];

    int categoryItemCount = showAllCategories
        ? categories.length
        : (categoryItemsPerRow < categories.length ? categoryItemsPerRow : categories.length);

    final promotionalProducts = allProducts.where((p) => p.discountPercentage > 0).toList();
    final newProducts = List<Product>.from(allProducts)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final bestSellers = List<Product>.from(allProducts);
    final laptops = allProducts.where((p) => p.categoryId == 'laptop').toList();
    final budgetLaptops = allProducts.where((p) => p.price < 10000000).toList();

    return Scaffold(
      appBar: const MobileHeader(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MobileSearchBar(),
            _buildCategorySection(categories, categoryItemCount),
            BannerSection(isWeb: false, screenWidth: screenWidth),
            ProductSection(title: "Promotional Products", products: promotionalProducts, isWeb: false, screenWidth: screenWidth),
            ProductSection(title: "New Products", products: newProducts, isWeb: false, screenWidth: screenWidth),
            ProductSection(title: "Best Sellers", products: bestSellers, isWeb: false, screenWidth: screenWidth),
            ProductSection(title: "Laptops", products: laptops, isWeb: false, screenWidth: screenWidth),
            ProductSection(title: "Budget Laptops", products: budgetLaptops, isWeb: false, screenWidth: screenWidth),
          ],
        ),
      ),
      bottomNavigationBar: MobileNavigationBar(
        selectedIndex: selectedIndex,
        onItemTapped: (index) => _onItemTapped(index, context),
        isLoggedIn: user.isLoggedIn,
        role: 'user',
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, double screenWidth) {
    final user = Provider.of<UserModel>(context);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    const double categoryItemWidth = 80;
    const double categorySpacing = 4;
    const double categoryHorizontalPadding = 32;
    int categoryItemsPerRow = _calculateItemsPerRow(
      screenWidth,
      categoryItemWidth,
      categorySpacing,
      categoryHorizontalPadding,
    );

    final categories = [
      const CategoryIcon(icon: Icons.laptop, label: "Laptops"),
      const CategoryIcon(icon: Icons.sports_esports, label: "Gaming"),
      const CategoryIcon(icon: Icons.laptop_mac, label: "Ultrabooks"),
      const CategoryIcon(icon: Icons.work, label: "Workstations"),
      const CategoryIcon(icon: Icons.money_off, label: "Budget"),
      const CategoryIcon(icon: Icons.tablet, label: "2-in-1"),
      const CategoryIcon(icon: Icons.desktop_windows, label: "Desktops"),
      const CategoryIcon(icon: Icons.assessment, label: "Accessories"),
    ];

    int categoryItemCount = showAllCategories
        ? categories.length
        : (categoryItemsPerRow < categories.length ? categoryItemsPerRow : categories.length);

    final promotionalProducts = allProducts.where((p) => p.discountPercentage > 0).toList();
    final newProducts = List<Product>.from(allProducts)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final bestSellers = List<Product>.from(allProducts);
    final laptops = allProducts.where((p) => p.categoryId == 'laptop').toList();
    final budgetLaptops = allProducts.where((p) => p.price < 10000000).toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const WebHeader(),
            WebSearchBar(isLoggedIn: user.isLoggedIn),
            BannerSection(isWeb: true, screenWidth: screenWidth),
            _buildPromoIcons(),
            _buildCategorySection(categories, categoryItemCount),
            ProductSection(title: "Promotional Products", products: promotionalProducts, isWeb: true, screenWidth: screenWidth),
            ProductSection(title: "New Products", products: newProducts, isWeb: true, screenWidth: screenWidth),
            ProductSection(title: "Best Sellers", products: bestSellers, isWeb: true, screenWidth: screenWidth),
            ProductSection(title: "Laptops", products: laptops, isWeb: true, screenWidth: screenWidth),
            ProductSection(title: "Budget Laptops", products: budgetLaptops, isWeb: true, screenWidth: screenWidth),
            Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoIcons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPromoItem(Icons.local_shipping, "Giao Hỏa Tốc"),
          const SizedBox(width: 40),
          _buildPromoItem(Icons.discount, "Mã Giảm Giá"),
          const SizedBox(width: 40),
          _buildPromoItem(Icons.category, "Danh Mục Hàng"),
          const SizedBox(width: 40),
          _buildPromoItem(Icons.chat, "Trò Chuyện"),
        ],
      ),
    );
  }

  Widget _buildCategorySection(List<CategoryIcon> categories, int categoryItemCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Categories", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () {
              setState(() {
                showAllCategories = !showAllCategories;
              });
            },
            child: Text(showAllCategories ? "Show less" : "See all", style: const TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.orange),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
