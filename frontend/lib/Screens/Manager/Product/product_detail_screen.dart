import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/models/tag.dart';
import 'package:danentang/Service/product_service.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';
import 'add_product.dart';
import 'delete_product.dart';

class ProductDetailScreenManager extends StatefulWidget {
  final String productId;
  const ProductDetailScreenManager({
    required this.productId,
    Key? key,
  }) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreenManager>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late Future<Product> _futureProduct;
  late Future<List<ProductImage>> _futureImages;
  late Future<List<ProductVariant>> _futureVariants;
  late Future<List<Tag>> _futureTags;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.productId.isEmpty || widget.productId.trim().isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID sản phẩm không hợp lệ')),
        );
        context.go('/manager/products');
      });
    }
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
        _saveTabIndex(_selectedTabIndex);
      }
    });
    _loadTabIndex();
    _loadAll();
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
      _selectedTabIndex = prefs.getInt('product_detail_tab_${widget.productId}') ?? 0;
      _tabController.index = _selectedTabIndex;
    });
  }

  Future<void> _saveTabIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('product_detail_tab_${widget.productId}', index);
  }

  void _loadAll() {
    _futureProduct = ProductService.getById(widget.productId);
    _futureImages = ProductService.fetchImages(widget.productId);
    _futureVariants = ProductService.fetchVariants(widget.productId);
    _futureTags = ProductService.fetchTagsOfProduct(widget.productId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onEditedOrDeleted(bool? result) async {
    if (result == true) {
      setState(_loadAll);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          context.go('/manager/products'); // Quay lại danh sách sản phẩm
        }
      },
      child: FutureBuilder<Product>(
        future: _futureProduct,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snap.hasError || !snap.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Lỗi'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/manager/products'),
                ),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Lỗi: ${snap.error ?? "Sản phẩm không tồn tại"}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(_loadAll); // Thử lại
                      },
                      child: const Text('Thử lại'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => context.go('/manager/products'),
                      child: const Text('Quay lại'),
                    ),
                  ],
                ),
              ),
            );
          }
          final product = snap.data!;
          final productName = product.name.isNotEmpty ? product.name : 'Sản phẩm không tên';
          return Scaffold(
            appBar: AppBar(
              title: Text(productName),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () async {
                    final edited = await context.push<bool>(
                      '/manager/products/edit',
                      extra: {'product': product},
                    );
                    await _onEditedOrDeleted(edited);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () async {
                    final deleted = await context.push<bool>(
                      '/manager/products/delete',
                      extra: {'product': product},
                    );
                    if (deleted == true) {
                      context.go('/manager/products', extra: {'refresh': true});
                    }
                  },
                ),
              ],
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/manager/products'),
              ),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Images'),
                  Tab(text: 'Variants'),
                  Tab(text: 'Tags'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildImagesTab(),
                _buildVariantsTab(),
                _buildTagsTab(),
              ],
            ),
            bottomNavigationBar: isMobile
                ? MobileNavigationBar(
              selectedIndex: 0,
              onItemTapped: (_) {},
              isLoggedIn: true,
              role: 'admin', // Đồng bộ với vai trò admin
            )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildImagesTab() {
    return FutureBuilder<List<ProductImage>>(
      future: _futureImages,
      builder: (c, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lỗi tải hình ảnh: ${snap.error}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(_loadAll),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }
        final imgs = snap.data ?? [];
        if (imgs.isEmpty) {
          return const Center(child: Text('Không có hình ảnh'));
        }
        final crossCount = (MediaQuery.of(context).size.width ~/ 120).clamp(2, 6);
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: imgs.length,
          itemBuilder: (ctx, i) {
            final img = imgs[i];
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _smartImage(img.url),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Order ${img.sortOrder}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildVariantsTab() {
    return FutureBuilder<List<ProductVariant>>(
      future: _futureVariants,
      builder: (c, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lỗi tải biến thể: ${snap.error}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(_loadAll),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }
        final vars = snap.data ?? [];
        if (vars.isEmpty) {
          return const Center(child: Text('Không có biến thể'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: vars.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (ctx, i) {
            final v = vars[i];
            return ListTile(
              leading: const Icon(Icons.settings_input_component),
              title: Text(v.variantName),
              subtitle: Text(
                'Giá: \$${v.additionalPrice.toStringAsFixed(2)} • Tồn kho: ${v.inventory}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTagsTab() {
    return FutureBuilder<List<Tag>>(
      future: _futureTags,
      builder: (c, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Lỗi tải thẻ: ${snap.error}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(_loadAll),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }
        final tags = snap.data ?? [];
        if (tags.isEmpty) {
          return const Center(child: Text('Chưa có thẻ nào được gán'));
        }
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((t) {
              final tagName = t.name.isNotEmpty ? t.name : 'Thẻ không tên';
              return Chip(
                label: Text(tagName),
                backgroundColor: Colors.purple.shade50,
                avatar: const Icon(Icons.label, size: 18, color: Colors.purple),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _smartImage(String urlOrBase64, {double? width, double? height, BoxFit? fit}) {
    if (urlOrBase64.isEmpty || urlOrBase64.trim().isEmpty) {
      return _fallbackImage(width, height);
    }
    if (urlOrBase64.startsWith('http')) {
      return Image.network(
        urlOrBase64,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackImage(width, height),
      );
    }
    try {
      final bytes = base64Decode(urlOrBase64);
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Lỗi giải mã base64: $error'); // Ghi log lỗi
          return _fallbackImage(width, height);
        },
      );
    } catch (e) {
      print('Lỗi xử lý ảnh: $e'); // Ghi log lỗi
      return _fallbackImage(width, height);
    }
  }

  Widget _fallbackImage(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
    );
  }
}