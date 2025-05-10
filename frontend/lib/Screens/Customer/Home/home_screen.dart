// lib/Screens/Customer/Home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../models/product.dart';
import '../../../models/category.dart';
import '../../../models/tag.dart';
import '../../../models/user.dart';

import '../../../Service/product_service.dart';

import '../../../widgets/banner_section.dart';
import '../../../widgets/product_section.dart';
import '../../../widgets/category_icon.dart';
import '../../../widgets/Header/mobile_header.dart';
import '../../../widgets/Header/web_header.dart';
import '../../../widgets/Search/mobile_search_bar.dart';
import '../../../widgets/Search/web_search_bar.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';
import '../../../widgets/footer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  bool showAllCategories = false;
  bool isLoading = true;

  List<Product> allProducts = [];
  List<Category> categories = [];
  List<Tag> tags = [];
  Map<String, List<Product>> productsByTag = {};

  // map category name -> icon
  static const _iconMap = {
    'Laptops': Icons.laptop,
    'Gaming': Icons.sports_esports,
    'Ultrabooks': Icons.laptop_mac,
    'Workstations': Icons.work,
    'Budget': Icons.money_off,
    '2-in-1': Icons.tablet,
    'Desktops': Icons.desktop_windows,
    'Accessories': Icons.assessment,
  };

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => isLoading = true);
    try {
      final prods = await ProductService.fetchAllProducts();
      final cats  = await ProductService.fetchAllCategories();
      final tgs   = await ProductService.fetchAllTags();

      // fetch products by tag
      final mapByTag = <String, List<Product>>{};
      for (final t in tgs) {
        mapByTag[t.id] = await ProductService.fetchProductsByTag(t.id);
      }

      setState(() {
        allProducts   = prods;
        categories    = cats;
        tags          = tgs;
        productsByTag = mapByTag;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải dữ liệu: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _onNavTapped(int idx) {
    final user = Provider.of<User>(context, listen: false);
    if (!user.isLoggedIn && idx != 0) {
      context.go('/login');
      return;
    }
    setState(() => selectedIndex = idx);
    switch (idx) {
      case 0:
        context.go('/homepage');
        break;
      case 1:
        context.go('/checkout');
        break;
      case 2:
        context.go('/profile');
        break;
      case 3:
        context.go('/chat');
        break;
    }
  }

  int _calculateItemsPerRow(double screenWidth, double itemWidth, double spacing, double pad) {
    final avail = screenWidth - pad * 2;
    return ((avail + spacing) / (itemWidth + spacing)).floor();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final w = MediaQuery.of(context).size.width;
    return w > 800
        ? _buildWebLayout(context, w)
        : _buildMobileLayout(context, w);
  }

  Widget _buildMobileLayout(BuildContext context, double w) {
    final user = Provider.of<User>(context, listen: false);

    // how many categories fit
    const iconSize = 80.0, iconSpacing = 8.0, iconPadding = 16.0;
    final maxCats = _calculateItemsPerRow(w, iconSize, iconSpacing, iconPadding);
    final visibleCats = showAllCategories ? categories : categories.take(maxCats).toList();

    return Scaffold(
      appBar: const MobileHeader(),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Search bar
          const MobileSearchBar(),

          // Categories row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: iconPadding, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => setState(() => showAllCategories = !showAllCategories),
                  child: Text(showAllCategories ? 'Show less' : 'See all', style: const TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: iconPadding),
            child: Row(
              children: visibleCats.map((cat) {
                final icon = _iconMap[cat.name] ?? Icons.category;
                return Padding(
                  padding: const EdgeInsets.only(right: iconSpacing),
                  child: CategoryIcon(icon: icon, label: cat.name),
                );
              }).toList(),
            ),
          ),

          // Banner
          BannerSection(isWeb: false, screenWidth: w),

          // Promo icons
          _buildPromoIcons(),

          // Static sections
          ProductSection(
            title: 'Promotional Products',
            products: allProducts.where((p) => p.discountPercentage > 0).toList(),
            isWeb: false,
            screenWidth: w,
            onTap: (p) => context.goNamed('product', pathParameters: {'id': p.id}),
          ),
          ProductSection(
            title: 'New Products',
            products: [
              ...allProducts..sort((a, b) => b.createdAt.compareTo(a.createdAt))
            ],
            isWeb: false,
            screenWidth: w,
            onTap: (p) => context.goNamed('product', pathParameters: {'id': p.id}),
          ),

          // Dynamic by category
          for (final cat in categories)
            if (allProducts.any((p) => p.categoryId == cat.id))
              ProductSection(
                title: cat.name,
                products: allProducts.where((p) => p.categoryId == cat.id).toList(),
                isWeb: false,
                screenWidth: w,
                onTap: (p) => context.goNamed('product', pathParameters: {'id': p.id}),
              ),

          // Dynamic by tag
          for (final tag in tags)
            if ((productsByTag[tag.id] ?? []).isNotEmpty)
              ProductSection(
                title: tag.name,
                products: productsByTag[tag.id]!,
                isWeb: false,
                screenWidth: w,
                onTap: (p) => context.goNamed('product', pathParameters: {'id': p.id}),
              ),
        ]),
      ),
      bottomNavigationBar: MobileNavigationBar(
        selectedIndex: selectedIndex,
        onItemTapped: _onNavTapped,
        isLoggedIn: user.isLoggedIn,
        role: 'user',
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, double w) {
    final user = Provider.of<User>(context, listen: false);

    const iconSize = 80.0, iconSpacing = 16.0, iconPadding = 32.0;
    final maxCats = _calculateItemsPerRow(w, iconSize, iconSpacing, iconPadding);
    final visibleCats = categories.take(maxCats).toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          const WebHeader(),
          WebSearchBar(isLoggedIn: user.isLoggedIn),

          BannerSection(isWeb: true, screenWidth: w),
          _buildPromoIcons(),

          // Category icons row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: iconPadding, vertical: 16),
            child: Row(
              children: visibleCats.map((cat) {
                final icon = _iconMap[cat.name] ?? Icons.category;
                return Padding(
                  padding: const EdgeInsets.only(right: iconSpacing),
                  child: CategoryIcon(icon: icon, label: cat.name),
                );
              }).toList(),
            ),
          ),

          // Dynamic by category
          for (final cat in categories)
            if (allProducts.any((p) => p.categoryId == cat.id))
              ProductSection(
                title: cat.name,
                products: allProducts.where((p) => p.categoryId == cat.id).toList(),
                isWeb: true,
                screenWidth: w,
                onTap: (p) => context.goNamed('product', pathParameters: {'id': p.id}),
              ),

          // Dynamic by tag
          for (final tag in tags)
            if ((productsByTag[tag.id] ?? []).isNotEmpty)
              ProductSection(
                title: tag.name,
                products: productsByTag[tag.id]!,
                isWeb: true,
                screenWidth: w,
                onTap: (p) => context.goNamed('product', pathParameters: {'id': p.id}),
              ),

          Footer(),
        ]),
      ),
    );
  }

  Widget _buildPromoIcons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPromoItem(Icons.local_shipping, 'Giao Hỏa Tốc'),
          const SizedBox(width: 40),
          _buildPromoItem(Icons.discount, 'Mã Giảm Giá'),
          const SizedBox(width: 40),
          _buildPromoItem(Icons.category, 'Danh Mục Hàng'),
          const SizedBox(width: 40),
          _buildPromoItem(Icons.chat, 'Trò Chuyện'),
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
