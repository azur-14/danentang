// lib/Screens/Manager/Product/product_detail_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/models/tag.dart';
import 'package:danentang/Service/product_service.dart';
import 'package:danentang/widgets/Footer/mobile_navigation_bar.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
        if (snap.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snap.error}')),
          );
        }
        final product = snap.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text(product.name),
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
        final imgs = snap.data ?? [];
        if (imgs.isEmpty) {
          return const Center(child: Text('No images'));
        }
        final crossCount = MediaQuery.of(context).size.width ~/ 120;
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount >= 2 ? crossCount : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: imgs.length,
          itemBuilder: (ctx, i) {
            final img = imgs[i];
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _safeBase64Image(
                    img.url,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
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
        final vars = snap.data ?? [];
        if (vars.isEmpty) {
          return const Center(child: Text('No variants'));
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
                'Additional \$${v.additionalPrice.toStringAsFixed(2)} • Stock: ${v.inventory}',
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
        final tags = snap.data ?? [];
        if (tags.isEmpty) {
          return const Center(child: Text('No tags assigned'));
        }
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((t) {
              return Chip(
                label: Text(t.name),
                backgroundColor: Colors.purple.shade50,
                avatar: const Icon(Icons.label, size: 18, color: Colors.purple),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _safeBase64Image(
      String base64String, {
        double? width,
        double? height,
        BoxFit? fit,
      }) {
    try {
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
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
