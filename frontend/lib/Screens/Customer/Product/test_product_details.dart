import 'package:flutter/material.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/models/ProductRating.dart';
import 'package:danentang/models/Review.dart';
import 'package:danentang/widgets/Header/web_header.dart';
import 'package:danentang/widgets/Product/product_image_carousel.dart';
import 'package:danentang/widgets/Product/product_info.dart';
import 'package:danentang/widgets/Product/product_tabs.dart';
import 'package:danentang/widgets/Product/recommended_products.dart';
import '../../../Service/product_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  const ProductDetailsScreen({super.key, required this.productId});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> with SingleTickerProviderStateMixin {
  late Future<Product> _productFuture;
  late Future<ProductRating> _ratingFuture;
  late Future<List<Review>> _reviewsFuture;
  late Future<List<Product>> _recommendedFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _productFuture = ProductService.getById(widget.productId);
    _ratingFuture = ProductService.getRating(widget.productId);
    _reviewsFuture = ProductService.getReviews(widget.productId);
    _recommendedFuture = ProductService.getRecommended(widget.productId);
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
      future: Future.wait([
        _productFuture,
        _ratingFuture,
        _reviewsFuture,
        _recommendedFuture,
      ]),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError || snap.data == null) {
          return const Scaffold(
            body: Center(child: Text('Không tải được dữ liệu sản phẩm.')),
          );
        }

        final results = snap.data!;
        final product = results[0] as Product;
        final productRating = results[1] as ProductRating;
        final reviews = results[2] as List<Review>;
        final recommendedProducts = results[3] as List<Product>;

        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: screenWidth <= 800
              ? AppBar(title: const Text("Chi tiết sản phẩm"))
              : null,
          body: SingleChildScrollView(
            child: Column(
              children: [
                if (screenWidth > 800) const WebHeader(userData: {},),
                screenWidth > 800
                    ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 400,
                              padding: const EdgeInsets.all(16),
                              child: ProductImageCarousel(product: product),
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
                        ),
                        const SizedBox(height: 32),
                        ProductTabs(
                          tabController: _tabController,
                          product: product,
                          reviews: reviews,
                        ),
                        const SizedBox(height: 32),
                        RecommendedProducts(
                          recommendedProducts: recommendedProducts,
                        ),
                      ],
                    ),
                  ),
                )
                    : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProductImageCarousel(product: product),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ProductInfo(
                            product: product,
                            productRating: productRating,
                          ),
                          ),
                        const SizedBox(height: 32),
                        ProductTabs(
                          tabController: _tabController,
                          product: product,
                          reviews: reviews,
                        ),
                        const SizedBox(height: 32),
                        RecommendedProducts(
                          recommendedProducts: recommendedProducts,
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}