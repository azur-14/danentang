import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../models/category.dart';
import 'package:danentang/widgets/Product_Catalog/filter_panel.dart';
import 'package:danentang/widgets/Product_Catalog/product_grid.dart';

class ProductCatalogPage extends StatefulWidget {
  final String? categoryId;

  const ProductCatalogPage({super.key, this.categoryId});

  @override
  _ProductCatalogPageState createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends State<ProductCatalogPage> {
  final ScrollController _scrollController = ScrollController();
  List<Product> _products = [];
  int _currentPage = 0;
  final int _pageSize = 8;
  bool _isLoading = false;

  String? _selectedBrand;
  double _priceRange = 100000000;
  int? _selectedRating;

  final List<Category> _categories = [
    Category(id: 'cat_laptops', name: 'Laptops', createdAt: DateTime(2025, 5, 18, 3, 44)),
    Category(id: 'cat_gaming', name: 'Gaming', createdAt: DateTime(2025, 5, 18, 3, 44)),
    Category(id: 'cat_ultrabooks', name: 'Ultrabook', createdAt: DateTime(2025, 5, 18, 3, 44)),
    Category(id: 'cat_workstations', name: 'Workstation', createdAt: DateTime(2025, 5, 18, 3, 44)),
    Category(id: 'cat_accessories', name: 'Accessories', createdAt: DateTime(2025, 5, 18, 3, 44)),
  ];

  final List<String> _brands = ['All', 'Lenovo', 'Apple', 'Razer'];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      const String base64Image =
          'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJYAAACWCAYAAAA8AXHiAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAbElEQVR4nO3BAQ0AAADCoPdPbQ8HFAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgZwglAABe6mO9AAAAAElFTkSuQmCC';

      final List<Product> allProducts = [
        Product(
          id: 'prod_1',
          name: 'Laptop Lenovo IdeaPad Slim 3',
          brand: 'Lenovo',
          description: 'Đồng hành cùng bạn với hiệu năng vượt trội.',
          discountPercentage: 0,
          categoryId: 'cat_laptops',
          createdAt: DateTime(2025, 5, 18, 3, 44),
          updatedAt: DateTime(2025, 5, 18, 3, 44),
          images: [
            ProductImage(id: 'img_1', url: base64Image, sortOrder: 0),
          ],
          variants: [
            ProductVariant(
              id: 'var_1',
              variantName: '15IRH10 i5 13420H/24GB/512GB/15.6"',
              additionalPrice: 20990000,
              inventory: 15,
              createdAt: DateTime(2025, 5, 18, 3, 44),
              updatedAt: DateTime(2025, 5, 18, 3, 44),
            ),
          ],
        ),
        ...List.generate(
          42,
              (index) => Product(
            id: 'prod_${index + 6}',
            name: 'Product ${index + 6}',
            brand: _brands[(index % (_brands.length - 1)) + 1],
            description: 'Sản phẩm chất lượng cao.',
            discountPercentage: index % 3 == 0 ? 10 : 0,
            categoryId: _categories[index % _categories.length].id!,
            createdAt: DateTime(2025, 5, 18, 3, 44),
            updatedAt: DateTime(2025, 5, 18, 3, 44),
            images: [
              ProductImage(
                id: 'img_${index + 6}',
                url: base64Image,
                sortOrder: 0,
              ),
            ],
            variants: [
              ProductVariant(
                id: 'var_${index + 6}',
                variantName: '16GB/512GB',
                additionalPrice: 15000000 + (index * 100000),
                inventory: 10,
                createdAt: DateTime(2025, 5, 18, 3, 44),
                updatedAt: DateTime(2025, 5, 18, 3, 44),
              ),
            ],
          ),
        ),
      ];

      var filteredProducts = widget.categoryId != null &&
          allProducts.any((p) => p.categoryId == widget.categoryId)
          ? allProducts.where((p) => p.categoryId == widget.categoryId).toList()
          : allProducts;

      if (_selectedBrand != null && _selectedBrand != 'All') {
        filteredProducts = filteredProducts.where((p) => p.brand == _selectedBrand).toList();
      }

      filteredProducts = filteredProducts.where((p) {
        final price = p.variants.isNotEmpty ? p.variants[0].additionalPrice : 0;
        return price <= _priceRange;
      }).toList();

      if (_selectedRating != null) {
        filteredProducts = filteredProducts.where((p) {
          final rating = (filteredProducts.indexOf(p) % 5) + 1;
          return rating >= _selectedRating!;
        }).toList();
      }

      final startIndex = _currentPage * _pageSize;
      final endIndex = startIndex + _pageSize;
      final newProducts = filteredProducts.skip(startIndex).take(_pageSize).toList();

      setState(() {
        _products.addAll(newProducts);
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadProducts();
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedBrand = null;
      _priceRange = 100000000;
      _selectedRating = null;
      _products.clear();
      _currentPage = 0;
      _loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    String? _selectedCategoryId = widget.categoryId != null &&
        _categories.any((category) => category.id == widget.categoryId)
        ? widget.categoryId
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elap Commerce', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[700],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.shopping_cart, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: isMobile
          ? _buildMobileLayout(context, _selectedCategoryId)
          : _buildDesktopLayout(context, _selectedCategoryId),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, String? selectedCategoryId) {
    return Row(
      children: [
        Container(
          width: 250,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: Colors.grey.shade300)),
          ),
          child: FilterPanel(
            categories: _categories,
            brands: _brands,
            selectedCategoryId: selectedCategoryId,
            selectedBrand: _selectedBrand,
            priceRange: _priceRange,
            selectedRating: _selectedRating,
            onCategoryChanged: (value) {
              setState(() {
                _products.clear();
                _currentPage = 0;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductCatalogPage(categoryId: value),
                  ),
                );
              });
            },
            onBrandChanged: (value) {
              setState(() {
                _selectedBrand = value;
                _products.clear();
                _currentPage = 0;
                _loadProducts();
              });
            },
            onPriceChanged: (value) {
              setState(() {
                _priceRange = value;
              });
            },
            onPriceChangeEnd: (value) {
              setState(() {
                _products.clear();
                _currentPage = 0;
                _loadProducts();
              });
            },
            onRatingChanged: (value) {
              setState(() {
                _selectedRating = value;
                _products.clear();
                _currentPage = 0;
                _loadProducts();
              });
            },
            onReset: _resetFilters,
            onApply: () {
              setState(() {
                _products.clear();
                _currentPage = 0;
                _loadProducts();
              });
            },
          ),
        ),
        Expanded(
          child: ProductGrid(
            products: _products,
            isLoading: _isLoading,
            scrollController: _scrollController,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, String? selectedCategoryId) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize: 0.8,
                  minChildSize: 0.5,
                  maxChildSize: 0.9,
                  expand: false,
                  builder: (context, scrollController) => SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FilterPanel(
                        categories: _categories,
                        brands: _brands,
                        selectedCategoryId: selectedCategoryId,
                        selectedBrand: _selectedBrand,
                        priceRange: _priceRange,
                        selectedRating: _selectedRating,
                        onCategoryChanged: (value) {
                          setState(() {
                            _products.clear();
                            _currentPage = 0;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductCatalogPage(categoryId: value),
                              ),
                            );
                          });
                        },
                        onBrandChanged: (value) {
                          setState(() {
                            _selectedBrand = value;
                            _products.clear();
                            _currentPage = 0;
                            _loadProducts();
                          });
                        },
                        onPriceChanged: (value) {
                          setState(() {
                            _priceRange = value;
                          });
                        },
                        onPriceChangeEnd: (value) {
                          setState(() {
                            _products.clear();
                            _currentPage = 0;
                            _loadProducts();
                          });
                        },
                        onRatingChanged: (value) {
                          setState(() {
                            _selectedRating = value;
                            _products.clear();
                            _currentPage = 0;
                            _loadProducts();
                          });
                        },
                        onReset: _resetFilters,
                        onApply: () {
                          setState(() {
                            _products.clear();
                            _currentPage = 0;
                            _loadProducts();
                          });
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Filters'),
          ),
        ),
        Expanded(
          child: ProductGrid(
            products: _products,
            isLoading: _isLoading,
            scrollController: _scrollController,
          ),
        ),
      ],
    );
  }
}