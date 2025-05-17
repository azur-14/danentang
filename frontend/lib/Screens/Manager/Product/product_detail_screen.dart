// lib/Screens/Manager/Product/product_detail_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/models/tag.dart';
import 'package:danentang/Service/product_service.dart';
import '../../../widgets/Footer/mobile_navigation_bar.dart';
import 'add_product.dart';
import 'delete_product.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({
    required this.productId,
    Key? key,
  }) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  late Future<Product> _futureProduct;
  late Future<List<ProductImage>> _futureImages;
  late Future<List<ProductVariant>> _futureVariants;
  late Future<List<Tag>> _futureTags;

  @override
  void initState() {
    super.initState();
    if (widget.productId.isEmpty || widget.productId.trim().isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID sản phẩm không hợp lệ')),
        );
        Navigator.of(context).pop();
      });
    }
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
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

    return FutureBuilder<Product>(
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
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Lỗi: ${snap.error ?? "Sản phẩm không tồn tại"}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
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
                  final edited = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddProductScreen(product: product),
                    ),
                  );
                  await _onEditedOrDeleted(edited);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: () async {
                  final deleted = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DeleteProductScreen(product: product),
                    ),
                  );
                  if (deleted == true) Navigator.pop(context, true);
                },
              ),
            ],
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
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
            role: 'manager',
          )
              : null,
        );
      },
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
          return Center(child: Text('Lỗi tải hình ảnh: ${snap.error}'));
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
          return Center(child: Text('Lỗi tải biến thể: ${snap.error}'));
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
          return Center(child: Text('Lỗi tải thẻ: ${snap.error}'));
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

  /// Xử lý image: Nếu là base64 thì decode, còn lại là network
  Widget _smartImage(String urlOrBase64, {double? width, double? height, BoxFit? fit}) {
    if (urlOrBase64.isEmpty || urlOrBase64.trim().isEmpty) {
      return _fallbackImage(width, height);
    }
    // Nếu là link http(s) thì dùng Image.network
    if (urlOrBase64.startsWith('http')) {
      return Image.network(
        urlOrBase64,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackImage(width, height),
      );
    }
    // Nếu là base64 (thường dài và không có "http")
    try {
      final bytes = base64Decode(urlOrBase64);
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackImage(width, height),
      );
    } catch (_) {
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
