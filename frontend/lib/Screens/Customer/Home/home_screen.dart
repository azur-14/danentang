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

  final TextEditingController searchController = TextEditingController();

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
        context.go('/cart');
        break;
      case 2:
        context.go('/profile');
        break;
      case 3:
        context.go('/chat');
        break;
    }
  }

  int _calculateItemsPerRow(double screenWidth, double itemWidth, double spacing, double horizontalPadding) {
    double availableWidth = screenWidth - (horizontalPadding * 2);
    return ((availableWidth + spacing) / (itemWidth + spacing)).floor();
  }

  void _onSearchSubmitted(String value) {
    // Optional: Navigate to search result screen or filter products
    print('User searched: $value');
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

    final categories = _getCategories();
    int itemsPerRow = _calculateItemsPerRow(screenWidth, 80, 4, 16);
    int categoryItemCount = showAllCategories ? categories.length : itemsPerRow.clamp(0, categories.length);

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
            MobileSearchBar(controller: searchController, onSubmitted: _onSearchSubmitted),
            _buildCategoryHeader(),
            _buildCategoryGrid(categories, categoryItemCount),
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

    final categories = _getCategories();
    int itemsPerRow = _calculateItemsPerRow(screenWidth, 80, 4, 32);
    int categoryItemCount = showAllCategories ? categories.length : itemsPerRow.clamp(0, categories.length);

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
            _buildCategoryHeader(),
            _buildCategoryGrid(categories, categoryItemCount),
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

  List<CategoryIcon> _getCategories() {
    return const [
      CategoryIcon(icon: Icons.laptop, label: "Laptops"),
      CategoryIcon(icon: Icons.sports_esports, label: "Gaming"),
      CategoryIcon(icon: Icons.laptop_mac, label: "Ultrabooks"),
      CategoryIcon(icon: Icons.work, label: "Workstations"),
      CategoryIcon(icon: Icons.money_off, label: "Budget"),
      CategoryIcon(icon: Icons.tablet, label: "2-in-1"),
      CategoryIcon(icon: Icons.desktop_windows, label: "Desktops"),
      CategoryIcon(icon: Icons.assessment, label: "Accessories"),
    ];
  }

  Widget _buildCategoryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            child: Text(
              showAllCategories ? "Show less" : "See all",
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(List<CategoryIcon> categories, int itemCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: categories.take(itemCount).toList(),
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
