import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'add_product.dart';
import 'delete_product.dart';
import 'product_detail_screen.dart';
import 'package:danentang/Service/product_service.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/models/Category.dart';
import 'package:danentang/models/tag.dart';
import 'package:danentang/widgets/Footer/mobile_navigation_bar.dart';

class Product_Management extends StatelessWidget {
  const Product_Management({super.key});
  @override
  Widget build(BuildContext context) => const ProductManagementScreen();
}

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});
  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim, _scaleAnim;

  late Future<List<Product>> _fProducts;
  late Future<List<Category>> _fCategories;
  late Future<List<Tag>> _fTags;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scaleAnim = Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    _loadData();
  }

  void _loadData() {
    _fProducts = ProductService.fetchAllProducts();
    _fCategories = ProductService.fetchAllCategories();
    _fTags = ProductService.fetchAllTags();
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: isMobile
              ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context))
              : null,
          title: const Text('Quản lý sản phẩm', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
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
                if (snap.hasError || !snap.hasData) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Lỗi tải dữ liệu: ${snap.error ?? "Không có dữ liệu"}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(_loadData),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }
                final products = (snap.data![0] as List<Product>).where((p) => p.id.isNotEmpty && p.name.isNotEmpty && p.price >= 0).toList();
                final cats = (snap.data![1] as List<Category>).where((c) => c.id!.isNotEmpty && c.name.isNotEmpty).toList();
                final tags = (snap.data![2] as List<Tag>).where((t) => t.id.isNotEmpty && t.name.isNotEmpty).toList();

                if (products.isEmpty && cats.isEmpty && tags.isEmpty) {
                  return const Center(child: Text('Không có dữ liệu để hiển thị'));
                }

                return TabBarView(
                  children: [
                    // Theo danh mục
                    RefreshIndicator(
                      onRefresh: () async => setState(_loadData),
                      child: cats.isEmpty
                          ? const Center(child: Text('Không có danh mục'))
                          : ListView.builder(
                        itemCount: cats.length,
                        itemBuilder: (ctx, i) {
                          final cat = cats[i];
                          final prods = products.where((p) => p.categoryId == cat.id).toList();
                          return ExpansionTile(
                            title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            children: prods.isEmpty
                                ? [
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('— Không có sản phẩm —', textAlign: TextAlign.center),
                              )
                            ]
                                : prods.map(_buildProductTile).toList(),
                          );
                        },
                      ),
                    ),
                    // Theo thẻ
                    RefreshIndicator(
                      onRefresh: () async => setState(_loadData),
                      child: tags.isEmpty
                          ? const Center(child: Text('Không có thẻ'))
                          : ListView.builder(
                        itemCount: tags.length,
                        itemBuilder: (ctx, i) {
                          final tag = tags[i];
                          return ExpansionTile(
                            title: Text(tag.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            children: [
                              FutureBuilder<List<Product>>(
                                future: ProductService.fetchProductsByTag(tag.id),
                                builder: (c2, psnap) {
                                  if (psnap.connectionState != ConnectionState.done) {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                  if (psnap.hasError) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text('Lỗi tải sản phẩm', textAlign: TextAlign.center),
                                    );
                                  }
                                  final list = (psnap.data ?? [])
                                      .where((p) => p.id.isNotEmpty && p.name.isNotEmpty && p.price >= 0)
                                      .toList();
                                  if (list.isEmpty) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Text('— Không có sản phẩm —', textAlign: TextAlign.center),
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
            final created = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const Add_Product()),
            );
            if (created == true) setState(_loadData);
          },
        ),
        bottomNavigationBar: isMobile
            ? MobileNavigationBar(
          selectedIndex: _currentIndex,
          onItemTapped: (i) => setState(() => _currentIndex = i),
          isLoggedIn: true,
          role: 'manager',
        )
            : null,
      ),
    );
  }

  Widget _buildProductTile(Product p) {
    // Validate product data
    final productName = p.name.isNotEmpty ? p.name : 'Sản phẩm không tên';
    final productPrice = p.price >= 0 ? p.price : 0.0;
    final imageUrl = p.images.isNotEmpty && _isValidUrl(p.images.first.url) ? p.images.first.url : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (p.id.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(productId: p.id),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ID sản phẩm không hợp lệ')),
            );
          }
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
                  image: imageUrl != null
                      ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) => const Icon(Icons.broken_image),
                  )
                      : null,
                ),
                child: imageUrl == null ? const Icon(Icons.image_not_supported, color: Colors.grey) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(productName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('\$${productPrice.toStringAsFixed(2)}', style: TextStyle(color: Colors.green.shade700)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () async {
                  final edited = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => Add_Product(product: p)),
                  );
                  if (edited == true) setState(_loadData);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final deleted = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => Delete_Product(product: p)),
                  );
                  if (deleted == true) setState(_loadData);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
  }
}