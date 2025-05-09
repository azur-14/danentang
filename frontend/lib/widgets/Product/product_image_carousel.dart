import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:danentang/models/product.dart';

class ProductImageCarousel extends StatefulWidget {
  final Product product;
  const ProductImageCarousel({super.key, required this.product});

  @override
  _ProductImageCarouselState createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: isDesktop ? 400 : 250,
              width: double.infinity,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.product.images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    widget.product.images[index].url,
                    height: isDesktop ? 400 : 250,
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
                  widget.product.id,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (widget.product.images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: widget.product.images.length,
              effect: const WormEffect(
                dotHeight: 10,
                dotWidth: 10,
                activeDotColor: Colors.purple,
                dotColor: Colors.white,
                spacing: 8,
              ),
            ),
          ),
        if (widget.product.images.length > 1)
          Padding(
            padding: const EdgeInsets.all(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.product.images.asMap().entries.skip(1).map(
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
                          height: isDesktop ? 80 : 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 80,
                            height: isDesktop ? 80 : 50,
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
      ],
    );
  }
}