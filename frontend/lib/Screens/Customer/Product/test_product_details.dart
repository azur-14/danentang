import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/models/ProductRating.dart';
import 'package:danentang/Service/product_service.dart';
import 'package:danentang/widgets/Header/web_header.dart';
import 'package:danentang/widgets/Product/product_image_carousel.dart';
import 'package:danentang/widgets/Product/product_info.dart';
import 'package:danentang/widgets/Product/product_tabs.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with SingleTickerProviderStateMixin {
  late Future<Product> _productFuture;
  late Future<ProductRating> _ratingFuture;
  late TabController _tabController;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _productFuture = ProductService.getById(widget.productId);
    _ratingFuture  = ProductService.getRating(widget.productId);
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getString('token') != null;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const maxContentWidth = 1200.0;

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([_productFuture, _ratingFuture]),
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasError || snap.data == null) {
          return const Scaffold(body: Center(child: Text('Không tải được dữ liệu sản phẩm.')));
        }

        final product       = snap.data![0] as Product;
        final productRating = snap.data![1] as ProductRating;

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: screenWidth <= 800
              ? AppBar(title: const Text("Chi tiết sản phẩm"))
              : null,
          body: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenWidth > 800 ? maxContentWidth : 600.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (screenWidth > 800) WebHeader(isLoggedIn: _isLoggedIn),
                    if (screenWidth > 800)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 400,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: ProductImageCarousel(product: product),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: ProductInfo(
                                product: product,
                                productRating: productRating,
                              ),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      ProductImageCarousel(product: product),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ProductInfo(
                          product: product,
                          productRating: productRating,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    ProductTabs(
                      tabController: _tabController,
                      product: product,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
