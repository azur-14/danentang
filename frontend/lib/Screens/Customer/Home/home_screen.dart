import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/widgets/category_icon.dart';
import 'package:danentang/widgets/footer.dart';
import 'package:danentang/widgets/product_section.dart';
import 'package:danentang/widgets/Header/mobile_header.dart';
import 'package:danentang/widgets/Header/web_header.dart';
import 'package:danentang/widgets/Search/mobile_search_bar.dart';
import 'package:danentang/widgets/Search/web_search_bar.dart';
import 'package:danentang/widgets/Footer/mobile_navigation_bar.dart';
import 'package:danentang/widgets/banner_section.dart'; // Import BannerSection

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  bool isLoggedIn = true;
  String userName = "JohnDoe";
  bool showAllCategories = false;

  final List<Product> laptops = [
    Product(
      name: "Dell XPS 13",
      price: "1299",
      discount: "10%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.5,
    ),
    Product(
      name: "MacBook Air M2",
      price: "1199",
      discount: "5%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.8,
    ),
    Product(
      name: "HP Spectre x360",
      price: "1399",
      discount: "15%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.7,
    ),
    Product(
      name: "Asus ZenBook 14",
      price: "999",
      discount: "8%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.3,
    ),
  ];

  final List<Product> budgetLaptops = [
    Product(
      name: "Acer Aspire 5",
      price: "499",
      discount: "12%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.0,
    ),
    Product(
      name: "Lenovo IdeaPad 3",
      price: "449",
      discount: "10%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.1,
    ),
    Product(
      name: "HP 14",
      price: "399",
      discount: "5%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 3.9,
    ),
  ];

  final List<Product> promotionalProducts = [
    Product(
      name: "Lenovo Legion 5",
      price: "1099",
      discount: "20%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.6,
    ),
    Product(
      name: "Asus TUF Gaming F15",
      price: "999",
      discount: "25%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.4,
    ),
    Product(
      name: "MSI Katana GF66",
      price: "1199",
      discount: "22%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.5,
    ),
  ];

  final List<Product> newProducts = [
    Product(
      name: "MacBook Pro M3",
      price: "1999",
      discount: "5%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.9,
    ),
    Product(
      name: "HP Envy 14 2025",
      price: "1249",
      discount: "10%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.7,
    ),
    Product(
      name: "Dell Inspiron 16",
      price: "899",
      discount: "8%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.4,
    ),
  ];

  final List<Product> bestSellers = [
    Product(
      name: "Dell Inspiron 15",
      price: "749",
      discount: "15%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.3,
    ),
    Product(
      name: "Acer Swift 3",
      price: "699",
      discount: "12%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.2,
    ),
    Product(
      name: "Lenovo ThinkPad E14",
      price: "799",
      discount: "10%",
      imageUrl: "https://images.unsplash.com/photo-1496181133206-80ce9b88a0a6",
      rating: 4.5,
    ),
  ];

  void _onItemTapped(int index, BuildContext context) {
    if (!isLoggedIn) {
      context.go('/login');
      return;
    }
    setState(() {
      selectedIndex = index;
    });
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/cart', extra: isLoggedIn);
        break;
      case 2:
        context.go('/profile', extra: isLoggedIn);
        break;
      case 3:
        context.go('/chat');
        break;
    }
  }

  int _calculateItemsPerRow(double screenWidth, double itemWidth, double spacing, double horizontalPadding) {
    double availableWidth = screenWidth - (horizontalPadding * 2);
    return ((availableWidth + spacing) / (itemWidth + spacing)).floor();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 800 ? _buildWebLayout(context, screenWidth) : _buildMobileLayout(context, screenWidth);
  }

  Widget _buildMobileLayout(BuildContext context, double screenWidth) {
    const double categoryItemWidth = 80;
    const double categorySpacing = 4;
    const double categoryHorizontalPadding = 16;
    int categoryItemsPerRow = _calculateItemsPerRow(
      screenWidth,
      categoryItemWidth,
      categorySpacing,
      categoryHorizontalPadding,
    );

    final categories = [
      const CategoryIcon(icon: Icons.laptop, label: "Laptops"),
      const CategoryIcon(icon: Icons.sports_esports, label: "Gaming"),
      const CategoryIcon(icon: Icons.laptop_mac, label: "Ultrabooks"),
      const CategoryIcon(icon: Icons.work, label: "Workstations"),
      const CategoryIcon(icon: Icons.money_off, label: "Budget"),
      const CategoryIcon(icon: Icons.tablet, label: "2-in-1"),
      const CategoryIcon(icon: Icons.desktop_windows, label: "Desktops"),
      const CategoryIcon(icon: Icons.assessment, label: "Accessories"),
    ];

    int categoryItemCount = showAllCategories
        ? categories.length
        : (categoryItemsPerRow < categories.length ? categoryItemsPerRow : categories.length);

    return Scaffold(
      appBar: MobileHeader(isLoggedIn: isLoggedIn, userName: userName),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MobileSearchBar(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Categories",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showAllCategories = !showAllCategories;
                      });
                    },
                    child: Text(
                      showAllCategories ? "Show less" : "See all",
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: categoryItemWidth,
                  crossAxisSpacing: categorySpacing,
                  mainAxisSpacing: 4,
                  childAspectRatio: 0.8,
                ),
                itemCount: categoryItemCount,
                itemBuilder: (context, index) {
                  return categories[index];
                },
              ),
            ),
            BannerSection(
              isWeb: false,
              screenWidth: screenWidth,
            ),
            ProductSection(
              title: "Promotional Products",
              products: promotionalProducts,
              isWeb: false,
              screenWidth: screenWidth,
            ),
            ProductSection(
              title: "New Products",
              products: newProducts,
              isWeb: false,
              screenWidth: screenWidth,
            ),
            ProductSection(
              title: "Best Sellers",
              products: bestSellers,
              isWeb: false,
              screenWidth: screenWidth,
            ),
            ProductSection(
              title: "Laptops",
              products: laptops,
              isWeb: false,
              screenWidth: screenWidth,
            ),
            ProductSection(
              title: "Budget Laptops",
              products: budgetLaptops,
              isWeb: false,
              screenWidth: screenWidth,
            ),
          ],
        ),
      ),
      bottomNavigationBar: MobileNavigationBar(
        selectedIndex: selectedIndex,
        onItemTapped: (index) => _onItemTapped(index, context),
        isLoggedIn: isLoggedIn,
      ),
    );
  }

  Widget _buildWebLayout(BuildContext context, double screenWidth) {
    const double categoryItemWidth = 80;
    const double categorySpacing = 4;
    const double categoryHorizontalPadding = 32;
    int categoryItemsPerRow = _calculateItemsPerRow(
      screenWidth,
      categoryItemWidth,
      categorySpacing,
      categoryHorizontalPadding,
    );

    final categories = [
      const CategoryIcon(icon: Icons.laptop, label: "Laptops"),
      const CategoryIcon(icon: Icons.sports_esports, label: "Gaming"),
      const CategoryIcon(icon: Icons.laptop_mac, label: "Ultrabooks"),
      const CategoryIcon(icon: Icons.work, label: "Workstations"),
      const CategoryIcon(icon: Icons.money_off, label: "Budget"),
      const CategoryIcon(icon: Icons.tablet, label: "2-in-1"),
      const CategoryIcon(icon: Icons.desktop_windows, label: "Desktops"),
      const CategoryIcon(icon: Icons.assessment, label: "Accessories"),
    ];

    int categoryItemCount = showAllCategories
        ? categories.length
        : (categoryItemsPerRow < categories.length ? categoryItemsPerRow : categories.length);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            WebHeader(isLoggedIn: isLoggedIn),
            WebSearchBar(isLoggedIn: isLoggedIn),
            BannerSection(
              isWeb: true,
              screenWidth: screenWidth,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPromoItem(Icons.local_shipping, "Giao Hỏa Tốc"),
                  const SizedBox(width: 40),
                  _buildPromoItem(Icons.discount, "Mã Giảm Giá"),
                  const SizedBox(width: 40),
                  _buildPromoItem(Icons.category, "Danh Mục Hàng"),
                  const SizedBox(width: 40),
                  _buildPromoItem(Icons.chat, "Trò Chuyện"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Danh Mục",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showAllCategories = !showAllCategories;
                      });
                    },
                    child: Text(
                      showAllCategories ? "Show less" : "See all",
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: categoryItemWidth,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: categoryItemCount,
                itemBuilder: (context, index) {
                  return categories[index];
                },
              ),
            ),
            ProductSection(
              title: "Promotional Products",
              products: promotionalProducts,
              isWeb: true,
              screenWidth: screenWidth,
            ),
            ProductSection(
              title: "New Products",
              products: newProducts,
              isWeb: true,
              screenWidth: screenWidth,
            ),
            ProductSection(
              title: "Best Sellers",
              products: bestSellers,
              isWeb: true,
              screenWidth: screenWidth,
            ),
            ProductSection(
              title: "Laptops",
              products: laptops,
              isWeb: true,
              screenWidth: screenWidth,
            ),
            ProductSection(
              title: "Budget Laptops",
              products: budgetLaptops,
              isWeb: true,
              screenWidth: screenWidth,
            ),
             Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.orange),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}