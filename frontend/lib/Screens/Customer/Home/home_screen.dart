import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:danentang/data/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/product.dart';
import '../../../models/Category.dart';
import '../../../models/tag.dart';
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
  bool _isLoggedIn = false;
  int selectedIndex = 0;
  bool showAllCategories = false;
  bool isLoading = true;

  List<Product> allProducts = [];
  List<Category> categories = [];
  List<Tag> tags = [];
  Map<String, List<Product>> productsByTag = {};

  final Map<String, dynamic> userData = UserData.userData;

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
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getString('token') != null;
    });
    await _loadAllData();
  }


  Future<void> _loadAllData() async {
    setState(() => isLoading = true);
    try {
      final prods = await ProductService.fetchAllProducts();
      final cats = await ProductService.fetchAllCategories();
      final tgs = await ProductService.fetchAllTags();

      final mapByTag = <String, List<Product>>{};
      for (final t in tgs) {
        mapByTag[t.id] = await ProductService.fetchProductsByTag(t.id);
      }

      setState(() {
        allProducts = prods;
        categories = cats;
        tags = tgs;
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
    final bool isLoggedIn = userData['isLoggedIn'] as bool;
    if (!isLoggedIn && idx != 0) {
      context.go('/login-signup');
      return;
    }
    setState(() => selectedIndex = idx);
    final extraData = {'isLoggedIn': isLoggedIn, 'userData': userData};
    switch (idx) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/cart', extra: extraData);
        break;
      case 2:
        context.go('/profile', extra: extraData);
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
    return w > 800 ? _buildWebLayout(context, w) : _buildMobileLayout(context, w);
  }

  Widget _buildMobileLayout(BuildContext context, double w) {
    // 1. Dùng state login thật sự
    final bool isLoggedIn = _isLoggedIn;

    // 2. Tính danh sách sản phẩm khuyến mãi
    final promoProducts = allProducts
        .where((p) => p.discountPercentage != null && p.discountPercentage! > 0)
        .toList();

    // 3. Category icons
    const iconSize = 80.0, iconSpacing = 8.0, iconPadding = 16.0;
    final maxCats = _calculateItemsPerRow(w, iconSize, iconSpacing, iconPadding);
    final visibleCats = showAllCategories ? categories : categories.take(maxCats).toList();

    return Scaffold(
// trong Scaffold:
      appBar: MobileHeader(
        isLoggedIn: _isLoggedIn,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MobileSearchBar(),

            // Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: iconPadding, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => setState(() => showAllCategories = !showAllCategories),
                    child: Text(
                      showAllCategories ? 'Show less' : 'See all',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            // Banner
            BannerSection(isWeb: false, screenWidth: w),

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


            // *** Phần Khuyến mãi ***
            if (promoProducts.isNotEmpty)
              ProductSection(
                title: 'Khuyến mãi',
                products: promoProducts,
                isWeb: false,
                screenWidth: w,
                onTap: (p) => context.goNamed('product', pathParameters: {'id': p.id}),
              ),

            // By Category
            for (final cat in categories)
              if (allProducts.any((p) => p.categoryId == cat.id))
                ProductSection(
                  title: cat.name,
                  products: allProducts.where((p) => p.categoryId == cat.id).toList(),
                  isWeb: false,
                  screenWidth: w,
                  onTap: (p) => context.goNamed('product', pathParameters: {'id': p.id}),
                ),

            // By Tag
            for (final tag in tags)
              if ((productsByTag[tag.id] ?? []).isNotEmpty)
                ProductSection(
                  title: tag.name,
                  products: productsByTag[tag.id]!,
                  isWeb: false,
                  screenWidth: w,
                  onTap: (p) => context.goNamed('product', pathParameters: {'id': p.id}),
                ),
          ],
        ),
      ),
      bottomNavigationBar: MobileNavigationBar(
        selectedIndex: selectedIndex,
        onItemTapped: _onNavTapped,
        isLoggedIn: isLoggedIn,
        role: 'user',
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, double w) {
    final bool isLoggedIn = _isLoggedIn;
    final promoProducts = allProducts
        .where((p) => p.discountPercentage != null && p.discountPercentage! > 0)
        .toList();

    const iconSize = 80.0, iconSpacing = 16.0, iconPadding = 32.0;
    final maxCats = _calculateItemsPerRow(w, iconSize, iconSpacing, iconPadding);
    final visibleCats = categories.take(maxCats).toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        // Truyền avatarBase64 vào đây
        child: WebHeader(
          isLoggedIn:   _isLoggedIn,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header hoặc nút Login

            // Search
            WebSearchBar(isLoggedIn: isLoggedIn),

            // Banner
            BannerSection(isWeb: true, screenWidth: w),

            // Promo icons (nếu vẫn muốn)
            _buildPromoIcons(),
// Category icons
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

            // *** Phần Khuyến mãi ***
            if (promoProducts.isNotEmpty)
              ProductSection(
                title: 'Khuyến mãi',
                products: promoProducts,
                isWeb: true,
                screenWidth: w,
                onTap: (p) => context.goNamed('product', pathParameters: {'id': p.id}),
              ),


            for (final tag in tags)
              if ((productsByTag[tag.id] ?? []).isNotEmpty)
                ProductSection(
                  title: tag.name,
                  products: productsByTag[tag.id]!,
                  isWeb: true,
                  screenWidth: w,
                  onTap: (p) => context.goNamed('product', pathParameters: {'id': p.id}),
                ),

            // By Category
            for (final cat in categories)
              if (allProducts.any((p) => p.categoryId == cat.id))
                ProductSection(
                  title: cat.name,
                  products: allProducts.where((p) => p.categoryId == cat.id).toList(),
                  isWeb: true,
                  screenWidth: w,
                  onTap: (p) => context.goNamed('product', pathParameters: {'id': p.id}),
                ),
            // Footer
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