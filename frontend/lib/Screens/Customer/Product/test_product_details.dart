import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/models/ProductRating.dart';
import 'package:danentang/models/Review.dart';
import 'package:danentang/widgets/Header/web_header.dart';

import '../../../Service/product_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  const ProductDetailsScreen({ super.key, required this.productId });

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> with SingleTickerProviderStateMixin {
  late Future<Product> _productFuture;
  late Future<ProductRating> _ratingFuture;
  late Future<List<Review>> _reviewsFuture;
  late Future<List<Product>> _recommendedFuture;
  late TabController _tabController;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Nếu widget.product != null (tức là ta đã pass full object qua extra),
      // Ngược lại (ví dụ deep-link hoặc reload) mới fetch từ server
      _productFuture     = ProductService.getById(widget.productId);
      _ratingFuture      = ProductService.getRating(widget.productId);
      _reviewsFuture     = ProductService.getReviews(widget.productId);
      _recommendedFuture = ProductService.getRecommended(widget.productId);

  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      // Chờ tất cả 4 Future cùng lúc
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

        // Sau khi load xong, extract từng phần
        final results             = snap.data!;
        final product             = results[0] as Product;
        final productRating       = results[1] as ProductRating;
        final reviews             = results[2] as List<Review>;
        final recommendedProducts = results[3] as List<Product>;

        return _buildContent(
          context,
          product,
          productRating,
          reviews,
          recommendedProducts,
        );
      },
    );
  }

  @override
  Widget _buildContent(BuildContext context, Product product, ProductRating productRating, List<Review> reviews, List<Product> recommendedProducts) {

    final double discountedPrice =
        product.price * (1 - product.discountPercentage / 100);
    final screenWidth = MediaQuery.of(context).size.width;
    const maxContentWidth = 1200.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (screenWidth > 800) const WebHeader(),
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
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: 400,
                                    width: double.infinity,
                                    child: PageView.builder(
                                      controller: _pageController,
                                      itemCount: product.images.length,
                                      itemBuilder: (context, index) {
                                        return Image.network(
                                          product.images[index].url,
                                          height: 400,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.broken_image, size: 50),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      color: Colors.purple[600],
                                      child: Text(
                                        product.id,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              product.images.isNotEmpty
                                  ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: SmoothPageIndicator(
                                  controller: _pageController,
                                  count: product.images.length,
                                  effect: const WormEffect(
                                    dotHeight: 10,
                                    dotWidth: 10,
                                    activeDotColor: Colors.purple,
                                    dotColor: Colors.white,
                                    spacing: 8,
                                  ),
                                ),
                              )
                                  : const SizedBox.shrink(),
                              const SizedBox(height: 16),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: product.images.asMap().entries.skip(1).map(
                                        (entry) {
                                      int index = entry.key;
                                      ProductImage image = entry.value;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: GestureDetector(
                                          onTap: () {
                                            _pageController.jumpToPage(index);
                                          },
                                          child: Image.network(
                                            image.url,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.broken_image, size: 30),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    RatingBarIndicator(
                                      rating: productRating.averageRating,
                                      itemBuilder: (context, index) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      itemCount: 5,
                                      itemSize: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "(${productRating.reviewCount} Đánh giá)",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Text(
                                      "₫${discountedPrice.toStringAsFixed(0)}",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (product.discountPercentage > 0)
                                      Text(
                                        "₫${product.price.toStringAsFixed(0)}",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    const Spacer(),
                                    const Text(
                                      "Đã bán: 200K",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Biến thể:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ...product.variants.map(
                                      (variant) {
                                    double variantPrice = product.price + variant.additionalPrice;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          Text(
                                            "${variant.variantName}: ",
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                          Text(
                                            "₫${variantPrice.toStringAsFixed(0)} (Kho: ${variant.inventory})",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "Mô tả:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.description ?? "Không có mô tả.",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Handle buy now action
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.purple[700],
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: const Text(
                                          "Mua ngay",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.shopping_bag_outlined,
                                          color: Colors.grey[600],
                                          size: 24,
                                        ),
                                        onPressed: () {
                                          // Handle add to cart action
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.chat_bubble_outline,
                                          color: Colors.grey[600],
                                          size: 24,
                                        ),
                                        onPressed: () {
                                          GoRouter.of(context).go('/chat');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: Colors.grey[200],
                            child: TabBar(
                              controller: _tabController,
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: Colors.purple,
                              tabs: const [
                                Tab(text: "Chi tiết sản phẩm"),
                                Tab(text: "Đánh giá người dùng"),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    product.description ?? "Không có mô tả.",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: reviews.isEmpty
                                        ? [
                                      const Text(
                                        "Chưa có đánh giá.",
                                        style: TextStyle(fontSize: 14),
                                      )
                                    ]
                                        : reviews.map(
                                          (review) => ListTile(
                                        leading: CircleAvatar(
                                          radius: 20,
                                          child: Icon(
                                            Icons.person,
                                            size: 20,
                                          ),
                                        ),
                                        title: Text(
                                          review.username,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            RatingBarIndicator(
                                              rating: review.rating,
                                              itemBuilder: (context, index) => const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              itemCount: 5,
                                              itemSize: 16,
                                            ),
                                            Text(
                                              review.comment,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Sản phẩm đề xuất",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 150,
                            child: recommendedProducts.isEmpty
                                ? const Center(child: Text("Không có sản phẩm đề xuất."))
                                : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: recommendedProducts.length,
                              itemBuilder: (context, index) {
                                final recommendedProduct = recommendedProducts[index];
                                final recommendedDiscountedPrice = recommendedProduct.price *
                                    (1 - recommendedProduct.discountPercentage / 100);
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Card(
                                    child: Container(
                                      width: 120,
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          recommendedProduct.images.isNotEmpty
                                              ? Image.network(
                                            recommendedProduct.images[0].url,
                                            height: 80,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Container(
                                                  height: 80,
                                                  color: Colors.grey[300],
                                                  child: const Icon(Icons.broken_image),
                                                ),
                                          )
                                              : Container(
                                            height: 80,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.image),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            recommendedProduct.name,
                                            style: const TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "₫${recommendedDiscountedPrice.toStringAsFixed(0)}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
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
                    Stack(
                      children: [
                        Container(
                          height: 250,
                          width: double.infinity,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: product.images.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                product.images[index].url,
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, size: 50),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            color: Colors.purple[600],
                            child: Text(
                              product.id,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: SmoothPageIndicator(
                          controller: _pageController,
                          count: product.images.length,
                          effect: const WormEffect(
                            dotHeight: 10,
                            dotWidth: 10,
                            activeDotColor: Colors.purple,
                            dotColor: Colors.white,
                            spacing: 8,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: product.images.asMap().entries.skip(1).map(
                                (entry) {
                              int index = entry.key;
                              ProductImage image = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    _pageController.jumpToPage(index);
                                  },
                                  child: Image.network(
                                    image.url,
                                    width: 80,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 80,
                                      height: 50,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image, size: 30),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              RatingBarIndicator(
                                rating: productRating.averageRating,
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "(${productRating.reviewCount} Đánh giá)",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                "₫${discountedPrice.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (product.discountPercentage > 0)
                                Text(
                                  "₫${product.price.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              const Spacer(),
                              const Text(
                                "Đã bán: 200K",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Biến thể:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ...product.variants.map(
                                (variant) {
                              double variantPrice = product.price + variant.additionalPrice;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      "${variant.variantName}: ",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      "₫${variantPrice.toStringAsFixed(0)} (Kho: ${variant.inventory})",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Mô tả:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.description ?? "Không có mô tả.",
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Handle buy now action
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple[700],
                                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: const Text(
                                    "Mua ngay",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Colors.grey[600],
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    // Handle add to cart action
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.chat_bubble_outline,
                                    color: Colors.grey[600],
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    GoRouter.of(context).go('/chat');
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: Colors.grey[200],
                            child: TabBar(
                              controller: _tabController,
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: Colors.purple,
                              tabs: const [
                                Tab(text: "Chi tiết sản phẩm"),
                                Tab(text: "Đánh giá người dùng"),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    product.description ?? "Không có mô tả.",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                SingleChildScrollView(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: reviews.isEmpty
                                        ? [
                                      const Text(
                                        "Chưa có đánh giá.",
                                        style: TextStyle(fontSize: 14),
                                      )
                                    ]
                                        : reviews.map(
                                          (review) => ListTile(
                                        leading: CircleAvatar(
                                          radius: 20,
                                          child: Icon(
                                            Icons.person,
                                            size: 20,
                                          ),
                                        ),
                                        title: Text(
                                          review.username,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            RatingBarIndicator(
                                              rating: review.rating,
                                              itemBuilder: (context, index) => const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              itemCount: 5,
                                              itemSize: 16,
                                            ),
                                            Text(
                                              review.comment,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Sản phẩm đề xuất",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 150,
                            child: recommendedProducts.isEmpty
                                ? const Center(child: Text("Không có sản phẩm đề xuất."))
                                : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: recommendedProducts.length,
                              itemBuilder: (context, index) {
                                final recommendedProduct = recommendedProducts[index];
                                final recommendedDiscountedPrice = recommendedProduct.price *
                                    (1 - recommendedProduct.discountPercentage / 100);
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Card(
                                    child: Container(
                                      width: 120,
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          recommendedProduct.images.isNotEmpty
                                              ? Image.network(
                                            recommendedProduct.images[0].url,
                                            height: 80,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Container(
                                                  height: 80,
                                                  color: Colors.grey[300],
                                                  child: const Icon(Icons.broken_image),
                                                ),
                                          )
                                              : Container(
                                            height: 80,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.image),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            recommendedProduct.name,
                                            style: const TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "₫${recommendedDiscountedPrice.toStringAsFixed(0)}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: screenWidth <= 800
          ? AppBar(
        title: const Text("Chi tiết sản phẩm"),
      )
          : null,
    );
  }
}