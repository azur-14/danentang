import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/models/Category.dart';
import 'package:danentang/models/tag.dart';
import 'package:danentang/Service/product_service.dart';
import 'add_product.dart';
import 'delete_product.dart';
import 'package:danentang/widgets/Footer/mobile_navigation_bar.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({Key? key}) : super(key: key);
  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim, _scaleAnim;

  late Future<List<Product>> _fProducts;
  late Future<List<Category>> _fCategories;
  late Future<List<Tag>> _fTags;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scaleAnim = Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    _loadData();
    _loadTabIndex();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');
    if (token == null || role != 'admin') {
      context.go('/login');
    }
  }

  Future<void> _loadTabIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTabIndex = prefs.getInt('product_management_tab') ?? 0;
    });
  }

  Future<void> _saveTabIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('product_management_tab', index);
  }

  void _loadData() {
    setState(() {
      _fProducts = ProductService.fetchAllProducts();
      _fCategories = ProductService.fetchAllCategories();
      _fTags = ProductService.fetchAllTags();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android);

    return PopScope(
      canPop: true, // Allow default back navigation
      child: DefaultTabController(
        length: 2,
        initialIndex: _selectedTabIndex,
        child: Builder(
          builder: (context) {
            DefaultTabController.of(context).addListener(() {
              final index = DefaultTabController.of(context).index;
              if (index != _selectedTabIndex) {
                setState(() {
                  _selectedTabIndex = index;
                });
                _saveTabIndex(index);
              }
            });
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => context.pop(), // Navigate back to previous screen
                ),
                title: const Text(
                  'Quản lý sản phẩm',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.white,
                centerTitle: false, // Left-align title for back button to appear before
                elevation: 0,
                bottom: const TabBar(
                  tabs: [Tab(text: 'Theo danh mục'), Tab(text: 'Theo thẻ')],
                  labelColor: Colors.black,
                  indicatorColor: Colors.purple,
                ),
              ),
              body: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: FutureBuilder<List<dynamic>>(
                    future: Future.wait([_fProducts, _fCategories, _fTags]),
                    builder: (ctx, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Lỗi: ${snap.error}'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadData,
                                child: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        );
                      }
                      final products = snap.data![0] as List<Product>;
                      final cats = snap.data![1] as List<Category>;
                      final tags = snap.data![2] as List<Tag>;
                      return TabBarView(
                        children: [
                          RefreshIndicator(
                            onRefresh: () async => _loadData(),
                            child: ListView.builder(
                              itemCount: cats.length,
                              itemBuilder: (ctx, i) {
                                final cat = cats[i];
                                final prods = products.where((p) => p.categoryId == cat.id).toList();
                                return ExpansionTile(
                                  title: Text(
                                    cat.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  children: prods.isEmpty
                                      ? [
                                    const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text(
                                        '— Không có sản phẩm —',
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  ]
                                      : prods.map(_buildProductTile).toList(),
                                );
                              },
                            ),
                          ),
                          RefreshIndicator(
                            onRefresh: () async => _loadData(),
                            child: ListView.builder(
                              itemCount: tags.length,
                              itemBuilder: (ctx, i) {
                                final tag = tags[i];
                                return ExpansionTile(
                                  title: Text(
                                    tag.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  children: [
                                    FutureBuilder<List<Product>>(
                                      future: ProductService.fetchProductsByTag(tag.id),
                                      builder: (c2, psnap) {
                                        if (psnap.connectionState != ConnectionState.done) {
                                          return const Center(child: CircularProgressIndicator());
                                        }
                                        if (psnap.hasError) {
                                          return Center(
                                            child: Text('Lỗi: ${psnap.error}'),
                                          );
                                        }
                                        final list = psnap.data!;
                                        if (list.isEmpty) {
                                          return const Padding(
                                            padding: EdgeInsets.all(16),
                                            child: Text(
                                              '— Không có sản phẩm —',
                                              textAlign: TextAlign.center,
                                            ),
                                          );
                                        }
                                        return Column(children: list.map(_buildProductTile).toList());
                                      },
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                child: const Icon(FontAwesomeIcons.plus),
                onPressed: () async {
                  final created = await context.push<bool>('/manager/products/edit');
                  if (created == true) _loadData();
                },
              ),
              bottomNavigationBar: isMobile
                  ? MobileNavigationBar(
                selectedIndex: 0,
                onItemTapped: (_) {},
                isLoggedIn: true,
                role: 'admin',
              )
                  : null,
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductTile(Product p) {
    final cheapest = p.variants.isNotEmpty
        ? p.variants.reduce((a, b) => a.additionalPrice < b.additionalPrice ? a : b)
        : null;
    final price = cheapest?.additionalPrice ?? 0.0;
    final discounted = price * (1 - p.discountPercentage / 100);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.push('/manager/products/${p.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: p.images.isNotEmpty
                    ? Image.network(
                  p.images.first.url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 32,
                  ),
                )
                    : const Icon(
                  Icons.image,
                  color: Colors.grey,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₫${discounted.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final edited = await context.push<bool>(
                    '/manager/products/edit',
                    extra: {'product': p},
                  );
                  if (edited == true) _loadData();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final deleted = await context.push<bool>(
                    '/manager/products/delete',
                    extra: {'product': p},
                  );
                  if (deleted == true) _loadData();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}