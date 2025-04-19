import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/colors.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_slider;

class BannerSection extends StatelessWidget {
  final bool isWeb;
  final double screenWidth;

  const BannerSection({
    Key? key,
    required this.isWeb,
    required this.screenWidth,
  }) : super(key: key);

  // List of banner images for the main slideshow
  static const List<String> slideshowImages = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.png',
  ];

  // Images for the static side banners (vouchers)
  static const String voucherImage1 = 'assets/images/voucher1.jpg'; // Top voucher
  static const String voucherImage2 = 'assets/images/voucher2.jpg'; // Bottom voucher

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.brandPrimary, width: 3), // Outer frame
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [AppColors.brandPrimary, AppColors.brandSecondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: isWeb ? _buildWebBanner(context) : _buildMobileBanner(context),
    );
  }

  Widget _buildMobileBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0), // Inner padding to avoid border overlap
      child: SizedBox(
        height: 120,
        child: Stack(
          children: [
            carousel_slider.CarouselSlider(
              options: carousel_slider.CarouselOptions(
                height: 120,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800), // Smoother transition
                autoPlayCurve: Curves.fastOutSlowIn, // Smooth curve
                enlargeCenterPage: true,
                viewportFraction: 0.95, // Slightly smaller to show transition effect
                aspectRatio: 16 / 9,
                enableInfiniteScroll: true,
              ),
              items: slideshowImages.map((imagePath) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "BẠN MỚI GIẢM 50.000Đ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    "GIẢM ĐỈNH CAO",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.yellow,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/products');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text("Shop now"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0), // Inner padding to avoid border overlap
      child: SizedBox(
        height: 300,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: carousel_slider.CarouselSlider(
                options: carousel_slider.CarouselOptions(
                  height: 300,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800), // Smoother transition
                  autoPlayCurve: Curves.fastOutSlowIn, // Smooth curve
                  enlargeCenterPage: true,
                  viewportFraction: 0.95, // Slightly smaller to show transition effect
                  aspectRatio: 16 / 9,
                  enableInfiniteScroll: true,
                ),
                items: slideshowImages.map((imagePath) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4.0),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        image: const DecorationImage(
                          image: AssetImage(voucherImage1),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "GIẢM ĐỈNH CAO",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              "GIẢM TẶNG VOUCHER 15.000Đ",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.yellow,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 4.0),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        image: const DecorationImage(
                          image: AssetImage(voucherImage2),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "RẺ VÔ ĐỊCH",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              "GIẢM ĐẾN 90% ĐỒNG DỌC",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.yellow,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}