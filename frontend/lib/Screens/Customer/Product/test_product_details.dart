import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:danentang/data/products.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/models/ProductRating.dart';
import 'package:danentang/models/Review.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

void main() {
  runApp(TestProductDetailsApp());
}

class TestProductDetailsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ProductDetailsScreen(
        product: sampleProduct,
        productRating: sampleProductRating,
        reviews: sampleReviews,
        recommendedProducts: recommendedProducts,
      ),
    );
  }
}

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final ProductRating productRating;
  final List<Review> reviews;
  final List<Product> recommendedProducts;

  const ProductDetailsScreen({
    required this.product,
    this.productRating = const ProductRating(averageRating: 0, reviewCount: 0),
    this.reviews = const [],
    this.recommendedProducts = const [],
  });

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions using MediaQuery
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate discounted price
    double discountedPrice =
        widget.product.price * (1 - widget.product.discountPercentage / 100);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Product Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sliding Image Carousel
            Stack(
              children: [
                // PageView for sliding images
                Container(
                  height: screenHeight * 0.3, // 30% of screen height
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.product.images.length,
                    itemBuilder: (context, index) {
                      return Image.asset(
                        widget.product.images[index].url,
                        height: screenHeight * 0.3,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                // Badge in the top-left corner
                Positioned(
                  top: screenHeight * 0.01, // 1% of screen height
                  left: screenWidth * 0.02, // 2% of screen width
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.005,
                    ),
                    color: Colors.purple[600],
                    child: Text(
                      "1902",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.03, // 3% of screen width
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Three Dots Indicator
            Padding(
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: widget.product.images.length,
                  effect: WormEffect(
                    dotHeight: screenHeight * 0.015,
                    dotWidth: screenHeight * 0.015,
                    activeDotColor: Colors.purple[600]!,
                    dotColor: Colors.white,
                    spacing: screenWidth * 0.02,
                  ),
                ),
              ),
            ),
            // Thumbnail Images with Tap Functionality
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Row(
                children: widget.product.images
                    .asMap()
                    .entries
                    .skip(1)
                    .map(
                      (entry) {
                    int index = entry.key;
                    ProductImage image = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(right: screenWidth * 0.02),
                      child: GestureDetector(
                        onTap: () {
                          _pageController.jumpToPage(index);
                        },
                        child: Image.asset(
                          image.url,
                          width: screenWidth * 0.2, // 20% of screen width
                          height: screenHeight * 0.06, // 6% of screen height
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                )
                    .toList(),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product.name,
                    style: TextStyle(
                      fontSize: screenWidth * 0.06, // 6% of screen width
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  // Rating
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: widget.productRating.averageRating,
                        itemBuilder: (context, index) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        itemCount: 5,
                        itemSize: screenWidth * 0.05, // 5% of screen width
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        "(${widget.productRating.reviewCount} Reviews)",
                        style: TextStyle(fontSize: screenWidth * 0.035),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  // Price and Discount
                  Row(
                    children: [
                      Text(
                        "\$${discountedPrice.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      Text(
                        "\$${widget.product.price.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "Đã bán: 200K",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  // Variants
                  Text(
                    "Variants:",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ...widget.product.variants.map(
                        (variant) {
                      double variantPrice =
                          widget.product.price + variant.additionalPrice;
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.005),
                        child: Row(
                          children: [
                            Text(
                              "${variant.variantName}: ",
                              style: TextStyle(fontSize: screenWidth * 0.035),
                            ),
                            Text(
                              "\$${variantPrice.toStringAsFixed(0)} (Stock: ${variant.inventory})",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: screenWidth * 0.035,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Short Description
                  Text(
                    "Description:",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    widget.product.description ?? "No description available.",
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Detailed Description
                  Text(
                    "MÔ TẢ CHI TIẾT SẢN PHẨM",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    "We are seeking a talented UI Designer to join our design team. In this role, you will be responsible for crafting innovative and engaging user interfaces for our streaming platform. You will work closely with UX designers, product managers, and engineers to create a seamless and intuitive user experience.",
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Comments Section
                  Text(
                    "User Reviews:",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  ...widget.reviews.map(
                        (review) => ListTile(
                      leading: CircleAvatar(
                        radius: screenWidth * 0.05,
                        child: Icon(
                          Icons.person,
                          size: screenWidth * 0.05,
                        ),
                      ),
                      title: Text(
                        review.username,
                        style: TextStyle(fontSize: screenWidth * 0.035),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RatingBarIndicator(
                            rating: review.rating,
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: screenWidth * 0.04,
                          ),
                          Text(
                            review.comment,
                            style: TextStyle(fontSize: screenWidth * 0.03),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Recommended Products Section
                  Text(
                    "Sản phẩm đề xuất",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Container(
                    height: screenHeight * 0.2, // 20% of screen height
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.recommendedProducts.length,
                      itemBuilder: (context, index) {
                        final recommendedProduct =
                        widget.recommendedProducts[index];
                        double recommendedDiscountedPrice =
                            recommendedProduct.price *
                                (1 -
                                    recommendedProduct.discountPercentage /
                                        100);
                        return Padding(
                          padding: EdgeInsets.only(right: screenWidth * 0.02),
                          child: Card(
                            child: Container(
                              width: screenWidth * 0.3, // 30% of screen width
                              padding: EdgeInsets.all(screenWidth * 0.02),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  recommendedProduct.images.isNotEmpty
                                      ? Image.asset(
                                    recommendedProduct.images[0].url,
                                    height: screenHeight * 0.1,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                    height: screenHeight * 0.1,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.image),
                                  ),
                                  SizedBox(height: screenHeight * 0.005),
                                  Text(
                                    recommendedProduct.name,
                                    style:
                                    TextStyle(fontSize: screenWidth * 0.03),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "\$${recommendedDiscountedPrice.toStringAsFixed(0)}",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
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
                  SizedBox(height: screenHeight * 0.1), // Space for the bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
      // Updated Bottom Navigation Bar with Responsive Design
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.01,
        ),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Buy Now Button
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: () {
                  // Handle buy now action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08,
                    vertical: screenHeight * 0.015,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.08),
                  ),
                ),
                child: Text(
                  "Buy Now",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            // Add to Cart Icon
            Container(
              decoration: BoxDecoration(
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
                  size: screenWidth * 0.06,
                ),
                onPressed: () {
                  // Handle add to cart action
                },
              ),
            ),
            SizedBox(width: screenWidth * 0.02),
            // Chat Icon
            Container(
              decoration: BoxDecoration(
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
                  size: screenWidth * 0.06,
                ),
                onPressed: () {
                  // Handle chat action
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}