import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:danentang/data/user_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:danentang/Screens/Customer/Product/ProductCatalogPage.dart';
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
  List<Product> promoProducts = [];
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
        promoProducts = prods
            .where((p) => p.discountPercentage != null && p.discountPercentage! > 0)
            .toList();
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
    setState(() => selectedIndex = idx);
    switch (idx) {
      case 0:
        context.go('/');
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
    if (allProducts.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Không có sản phẩm nào để hiển thị')),
      );
    }
    final w = MediaQuery.of(context).size.width;
    return w > 800 ? _buildWebLayout(context, w) : _buildMobileLayout(context, w);
  }

  Widget _buildMobileLayout(BuildContext context, double w) {
    const iconSize = 80.0, iconSpacing = 8.0, iconPadding = 16.0;
    final maxCats = _calculateItemsPerRow(w, iconSize, iconSpacing, iconPadding);
    final visibleCats = showAllCategories ? categories : categories.take(maxCats).toList();

    return Scaffold(
      appBar: MobileHeader(
        isLoggedIn: _isLoggedIn,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MobileSearchBar(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: iconPadding, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Loại sản phẩm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => setState(() => showAllCategories = !showAllCategories),
                    child: Text(
                      showAllCategories ? 'Thu lại' : 'Xem tất cả',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            BannerSection(isWeb: false, screenWidth: w),
            const SizedBox(height: 20),
            categories.isEmpty
                ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: iconPadding, vertical: 8),
              child: Text('Không có danh mục nào'),
            )
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: iconPadding),
              child: Row(
                children: visibleCats.map((cat) {
                  final icon = _iconMap[cat.name] ?? Icons.category;
                  return Padding(
                    padding: const EdgeInsets.only(right: iconSpacing),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductCatalogPage(categoryId: cat.id),
                          ),
                        );
                      },
                      child: CategoryIcon(icon: icon, label: cat.name),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            if (promoProducts.isNotEmpty)
              ProductSection(
                title: 'Khuyến mãi',
                products: promoProducts,
                isWeb: false,
                screenWidth: w,
                onTap: (p) => context.goNamed('product', pathParameters: {'id': p.id}),
              ),
            const SizedBox(height: 20),
            for (final cat in categories)
              if (allProducts.any((p) => p.categoryId == cat.id))
                ProductSection(
                  title: cat.name,
                  products: allProducts.where((p) => p.categoryId == cat.id).toList(),
                  isWeb: false,
                  screenWidth: w,
                  onTap: (p) => context.goNamed('product', pathParameters: {'id': p.id}),
                ),
            const SizedBox(height: 20),
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
        isLoggedIn: _isLoggedIn,
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
    final visibleCats = showAllCategories ? categories : categories.take(maxCats).toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: WebHeader(
          isLoggedIn: _isLoggedIn,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            WebSearchBar(isLoggedIn: _isLoggedIn),
            const SizedBox(height: 8),
            BannerSection(isWeb: true, screenWidth: w),
            const SizedBox(height: 16),
            _buildPromoIcons(),
            const SizedBox(height: 16),
            categories.isEmpty
                ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: iconPadding, vertical: 8),
              child: Text('Không có danh mục nào'),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: iconPadding, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Loại sản phẩm',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => showAllCategories = !showAllCategories),
                        child: Text(
                          showAllCategories ? 'Thu lại' : 'Xem tất cả',
                          style: const TextStyle(color: Colors.blue, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: visibleCats.map((cat) {
                      final icon = _iconMap[cat.name] ?? Icons.category;
                      return Padding(
                        padding: const EdgeInsets.only(right: iconSpacing),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductCatalogPage(categoryId: cat.id),
                              ),
                            );
                          },
                          child: CategoryIcon(icon: icon, label: cat.name),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (promoProducts.isNotEmpty)
              ProductSection(
                title: 'Khuyến mãi',
                products: promoProducts,
                isWeb: true,
                screenWidth: w,
                onTap: (p) => context.goNamed('product', pathParameters: {'id': p.id}),
              ),
            const SizedBox(height: 16),
            for (final tag in tags)
              if ((productsByTag[tag.id] ?? []).isNotEmpty)
                ProductSection(
                  title: tag.name,
                  products: productsByTag[tag.id]!,
                  isWeb: true,
                  screenWidth: w,
                  onTap: (p) => context.goNamed('product', pathParameters: {'id': p.id}),
                ),
            const SizedBox(height: 16),
            for (final cat in categories)
              if (allProducts.any((p) => p.categoryId == cat.id))
                ProductSection(
                  title: cat.name,
                  products: allProducts.where((p) => p.categoryId == cat.id).toList(),
                  isWeb: true,
                  screenWidth: w,
                  onTap: (p) => context.goNamed('product', pathParameters: {'id': p.id}),
                ),
            const SizedBox(height: 16),
            Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoIcons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPromoItem(Icons.local_shipping, 'Giao Hỏa Tốc'),
          const SizedBox(width: 24),
          _buildPromoItem(Icons.discount, 'Mã Giảm Giá'),
          const SizedBox(width: 24),
          _buildPromoItem(Icons.category, 'Danh Mục Hàng'),
          const SizedBox(width: 24),
          _buildPromoItem(Icons.chat, 'Trò Chuyện'),
        ],
      ),
    );
  }

  Widget _buildPromoItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 24, color: const Color(0xFF0251CD)),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A0056),
          ),
        ),
      ],
    );
  }
}