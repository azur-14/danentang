import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:danentang/constants/colors.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/widgets/category_icon.dart';
import 'package:danentang/widgets/footer.dart';
import 'package:danentang/widgets/product_section.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool isLoggedIn = false;
  String userName = "ban";
  bool showAllCategories = false;
  final List<Product> laptops = [
    Product(
      name: "Dell XPS 13",
      price: "1299",
      discount: "10%",
      imageUrl: "https://example.com/images/dell_xps13.jpg",
    ),
    Product(
      name: "MacBook Air M2",
      price: "1199",
      discount: "5%",
      imageUrl: "https://example.com/images/macbook_air_m2.jpg",
    ),
    Product(
      name: "HP Spectre x360",
      price: "1399",
      discount: "15%",
      imageUrl: "https://example.com/images/hp_spectre.jpg",
    ),
    Product(
      name: "Asus ZenBook 14",
      price: "999",
      discount: "8%",
      imageUrl: "https://example.com/images/asus_zenbook14.jpg",
    ),
  ];
  final List<Product> budgetLaptops = [
    Product(
      name: "Acer Aspire 5",
      price: "499",
      discount: "12%",
      imageUrl: "https://example.com/images/acer_aspire5.jpg",
    ),
    Product(
      name: "Lenovo IdeaPad 3",
      price: "449",
      discount: "10%",
      imageUrl: "https://example.com/images/lenovo_ideapad3.jpg",
    ),
  ];
  final List<Product> promotionalProducts = [
    Product(
      name: "Lenovo Legion 5",
      price: "1099",
      discount: "20%",
      imageUrl: "https://example.com/images/lenovo_legion5.jpg",
    ),
    Product(
      name: "Asus TUF Gaming F15",
      price: "999",
      discount: "25%",
      imageUrl: "https://example.com/images/asus_tuf_f15.jpg",
    ),
  ];
  final List<Product> newProducts = [
    Product(
      name: "MacBook Pro M3",
      price: "1999",
      discount: "5%",
      imageUrl: "https://example.com/images/macbook_pro_m3.jpg",
    ),
    Product(
      name: "HP Envy 14 2025",
      price: "1249",
      discount: "10%",
      imageUrl: "https://example.com/images/hp_envy14.jpg",
    ),
  ];
  final List<Product> bestSellers = [
    Product(
      name: "Dell Inspiron 15",
      price: "749",
      discount: "15%",
      imageUrl: "https://example.com/images/dell_inspiron15.jpg",
    ),
    Product(
      name: "Acer Swift 3",
      price: "699",
      discount: "12%",
      imageUrl: "https://example.com/images/acer_swift3.jpg",
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  int _calculateItemsPerRow(double screenWidth, double itemWidth, double spacing, double horizontalPadding) {
    double availableWidth = screenWidth - (horizontalPadding * 2);
    return ((availableWidth + spacing) / (itemWidth + spacing)).floor();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 800 ? _buildWebLayout() : _buildMobileLayout();
  }

  Widget _buildMobileLayout() {
    final screenWidth = MediaQuery.of(context).size.width;
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
      CategoryIcon(icon: Icons.laptop, label: "Laptops"),
      CategoryIcon(icon: Icons.sports_esports, label: "Gaming"),
      CategoryIcon(icon: Icons.laptop_mac, label: "Ultrabooks"),
      CategoryIcon(icon: Icons.work, label: "Workstations"),
      CategoryIcon(icon: Icons.money_off, label: "Budget"),
      CategoryIcon(icon: Icons.tablet, label: "2-in-1"),
    ];

    int categoryItemCount = showAllCategories
        ? categories.length
        : (categoryItemsPerRow < categories.length ? categoryItemsPerRow : categories.length);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.diamond, color: Colors.purple, size: 20),
            SizedBox(width: 8),
            Text(
              "Hello $userName",
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: () {
                  context.go('/cart', extra: isLoggedIn);
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    "1",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.message, color: Colors.black),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    "1",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Categories", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showAllCategories = !showAllCategories;
                      });
                    },
                    child: Text(
                      showAllCategories ? "Show less" : "See all",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple[300]!, Colors.purple[100]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't Miss Out!",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        "SAVE UP TO 75%",
                        style: TextStyle(fontSize: 14, color: Colors.red),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text("Shop now"),
                      ),
                    ],
                  ),
                ),
              ),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Chat'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 1) {
            context.go('/cart', extra: isLoggedIn);
          } else if (index == 0) {
            context.go('/');
          }
        },
      ),
    );
  }

  Widget _buildWebLayout() {
    final screenWidth = MediaQuery.of(context).size.width;
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
      CategoryIcon(icon: Icons.laptop, label: "Laptops"),
      CategoryIcon(icon: Icons.sports_esports, label: "Gaming"),
      CategoryIcon(icon: Icons.laptop_mac, label: "Ultrabooks"),
      CategoryIcon(icon: Icons.work, label: "Workstations"),
      CategoryIcon(icon: Icons.money_off, label: "Budget"),
      CategoryIcon(icon: Icons.tablet, label: "2-in-1"),
    ];

    int categoryItemCount = showAllCategories
        ? categories.length
        : (categoryItemsPerRow < categories.length ? categoryItemsPerRow : categories.length);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppColors.primaryPurple,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "HoaLahe | Kênh người bán | Tải Ứng dụng | Kết nối",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Row(
                    children: [
                      Text(
                        "Tiếng Việt",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      SizedBox(width: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "je3mlgb384",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                children: [
                  Text(
                    "HoaLaHe",
                    style: TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 32),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Container(
                          margin: EdgeInsets.only(left: 8, right: 8),
                          child: CircleAvatar(
                            radius: 16,
                            child: Icon(
                              Icons.search,
                              color: AppColors.primaryPurple,
                              size: 20,
                            ),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.lightGrey,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.shopping_cart, size: 32),
                    onPressed: () {
                      context.go('/cart', extra: isLoggedIn);
                    },
                  ),
                ],
              ),
            ),
            Container(
              height: 300,
              margin: EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: AssetImage('assets/images/banner2.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: AssetImage('assets/images/voucher1.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: AssetImage('assets/images/voucher2.jpg'),
                                fit: BoxFit.cover,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  _buildPromoItem(Icons.local_shipping, "Giao Hỏa Tốc"),
                  SizedBox(width: 40),
                  _buildPromoItem(Icons.discount, "Mã Giảm Giá"),
                  SizedBox(width: 40),
                  _buildPromoItem(Icons.category, "Danh Mục Hàng"),
                  SizedBox(width: 40),
                  _buildPromoItem(Icons.chat, "Trò Chuyện"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
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
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
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
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}