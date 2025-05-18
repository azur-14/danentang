import 'package:flutter/material.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/models/Category.dart';
import 'package:danentang/widgets/Product_Catalog/filter_panel.dart';
import 'package:danentang/widgets/Product_Catalog/product_grid.dart';
import 'package:danentang/Service/product_service.dart';
import 'package:go_router/go_router.dart';

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
  bool _isFilterApplied = false; // Track if filters are applied

  String? _selectedBrand;
  double _priceRange = double.infinity; // Default to infinity (no price filter)
  int? _selectedRating;

  late Future<List<Category>> _futureCategories;

  @override
  void initState() {
    super.initState();
    _futureCategories = ProductService.fetchAllCategories();
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
      // Fetch products based on categoryId
      List<Product> allProducts;
      if (widget.categoryId != null) {
        debugPrint('Fetching products for category: ${widget.categoryId}');
        allProducts = await ProductService.fetchProductsByCategory(widget.categoryId!);
        debugPrint('API response for category ${widget.categoryId}: $allProducts');
        debugPrint('Fetched ${allProducts.length} products for category ${widget.categoryId}');
      } else {
        debugPrint('Fetching all products');
        allProducts = await ProductService.fetchAllProducts();
        debugPrint('API response for all products: $allProducts');
        debugPrint('Fetched ${allProducts.length} products');
      }

      // Log product details
      for (var product in allProducts) {
        debugPrint('Product: ${product.name}, CategoryId: ${product.categoryId}, Price: ${product.variants.isNotEmpty ? product.variants[0].additionalPrice : 0}');
      }

      // Apply filters only if _isFilterApplied is true
      var filteredProducts = allProducts;
      if (_isFilterApplied) {
        if (_selectedBrand != null && _selectedBrand != 'All') {
          filteredProducts = filteredProducts.where((p) => p.brand == _selectedBrand).toList();
          debugPrint('After brand filter ($_selectedBrand): ${filteredProducts.length} products');
        }

        filteredProducts = filteredProducts.where((p) {
          final price = p.variants.isNotEmpty ? p.variants[0].additionalPrice : 0;
          return price <= _priceRange;
        }).toList();
        debugPrint('After price filter ($_priceRange): ${filteredProducts.length} products');


      }

      final startIndex = _currentPage * _pageSize;
      final endIndex = startIndex + _pageSize;
      final newProducts = filteredProducts.skip(startIndex).take(_pageSize).toList();
      debugPrint('After pagination (page $_currentPage): ${newProducts.length} new products');

      setState(() {
        _products.addAll(newProducts);
        _currentPage++;
        _isLoading = false;
      });
      debugPrint('Total products in grid: ${_products.length}');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading products: $e');
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
      _priceRange = double.infinity; // Reset to no price filter
      _selectedRating = null;
      _isFilterApplied = false; // Disable filters
      _products.clear();
      _currentPage = 0;
      _loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elap Commerce', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[700],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
          IconButton(icon: const Icon(Icons.shopping_cart, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: isMobile ? _buildMobileLayout(context) : _buildDesktopLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        FutureBuilder<List<Category>>(
          future: _futureCategories,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Container(
                width: 250,
                padding: const EdgeInsets.all(16),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Container(
                width: 250,
                padding: const EdgeInsets.all(16),
                child: const Center(child: Text('Error loading categories')),
              );
            }
            final categories = snapshot.data ?? [];
            debugPrint('Loaded categories: ${categories.map((c) => c.id).toList()}');
            final selectedCategoryId = categories.any((category) => category.id == widget.categoryId)
                ? widget.categoryId
                : null;
            return Container(
              width: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: Colors.grey.shade300)),
              ),
              child: FilterPanel(
                categories: categories,
                brands: ['All', 'Lenovo', 'Apple', 'Razer'],
                selectedCategoryId: selectedCategoryId,
                selectedBrand: _selectedBrand,
                priceRange: _priceRange.isFinite ? _priceRange : 100000000, // Display max price for UI
                selectedRating: _selectedRating,
                onCategoryChanged: (value) {
                  setState(() {
                    _products.clear();
                    _currentPage = 0;
                    _isFilterApplied = false; // Reset filters when changing category
                    context.go('/catalog/$value');
                  });
                },
                onBrandChanged: (value) {
                  setState(() {
                    _selectedBrand = value;
                    _isFilterApplied = true; // Enable filters
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
                    _priceRange = value;
                    _isFilterApplied = true; // Enable filters
                    _products.clear();
                    _currentPage = 0;
                    _loadProducts();
                  });
                },
                onRatingChanged: (value) {
                  setState(() {
                    _selectedRating = value;
                    _isFilterApplied = true; // Enable filters
                    _products.clear();
                    _currentPage = 0;
                    _loadProducts();
                  });
                },
                onReset: _resetFilters,
                onApply: () {
                  setState(() {
                    _isFilterApplied = true; // Enable filters
                    _products.clear();
                    _currentPage = 0;
                    _loadProducts();
                  });
                },
              ),
            );
          },
        ),
        Expanded(
          child: _products.isEmpty && !_isLoading
              ? const Center(child: Text('Không tìm thấy sản phẩm'))
              : ProductGrid(
            products: _products,
            isLoading: _isLoading,
            scrollController: _scrollController,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => FutureBuilder<List<Category>>(
                  future: _futureCategories,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading categories'));
                    }
                    final categories = snapshot.data ?? [];
                    debugPrint('Loaded categories (mobile): ${categories.map((c) => c.id).toList()}');
                    final selectedCategoryId = categories.any((category) => category.id == widget.categoryId)
                        ? widget.categoryId
                        : null;
                    return DraggableScrollableSheet(
                      initialChildSize: 0.8,
                      minChildSize: 0.5,
                      maxChildSize: 0.9,
                      expand: false,
                      builder: (context, scrollController) => SingleChildScrollView(
                        controller: scrollController,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: FilterPanel(
                            categories: categories,
                            brands: ['All', 'Lenovo', 'Apple', 'Razer'],
                            selectedCategoryId: selectedCategoryId,
                            selectedBrand: _selectedBrand,
                            priceRange: _priceRange.isFinite ? _priceRange : 100000000, // Display max price for UI
                            selectedRating: _selectedRating,
                            onCategoryChanged: (value) {
                              setState(() {
                                _products.clear();
                                _currentPage = 0;
                                _isFilterApplied = false; // Reset filters
                                context.go('/catalog/$value');
                              });
                            },
                            onBrandChanged: (value) {
                              setState(() {
                                _selectedBrand = value;
                                _isFilterApplied = true; // Enable filters
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
                                _priceRange = value;
                                _isFilterApplied = true; // Enable filters
                                _products.clear();
                                _currentPage = 0;
                                _loadProducts();
                              });
                            },
                            onRatingChanged: (value) {
                              setState(() {
                                _selectedRating = value;
                                _isFilterApplied = true; // Enable filters
                                _products.clear();
                                _currentPage = 0;
                                _loadProducts();
                              });
                            },
                            onReset: _resetFilters,
                            onApply: () {
                              setState(() {
                                _isFilterApplied = true; // Enable filters
                                _products.clear();
                                _currentPage = 0;
                                _loadProducts();
                              });
                            },
                          ),
                        ),
                      ),
                    );
                  },
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
          child: _products.isEmpty && !_isLoading
              ? const Center(child: Text('Không tìm thấy sản phẩm'))
              : ProductGrid(
            products: _products,
            isLoading: _isLoading,
            scrollController: _scrollController,
          ),
        ),
      ],
    );
  }
}