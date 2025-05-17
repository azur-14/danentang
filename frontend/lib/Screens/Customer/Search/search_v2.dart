import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../Service/search_service.dart';
import '../../../models/product.dart';

class Searching extends StatelessWidget {
  const Searching({super.key});

  @override
  Widget build(BuildContext context) {
    return const SearchScreen();
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  List<Product> _searchResults = [];
  List<String> _autocompleteSuggestions = [];
  List<String> _selectedBrands = [];
  double? _minPrice;
  double? _maxPrice;
  String? _selectedCategory;
  Timer? _debounce;
  Map<String, String> _categoryNames = {};

  @override
  void initState() {
    super.initState();
    _loadCategoryNames();
  }

  Future<void> _loadCategoryNames() async {
    final categories = await _searchService.getCategories();
    for (var categoryId in categories) {
      final name = await _searchService.getCategoryName(categoryId!);
      setState(() {
        _categoryNames[categoryId] = name;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.isNotEmpty) {
        try {
          final suggestions = await _searchService.autocomplete(query);
          setState(() {
            _autocompleteSuggestions = suggestions;
            _searchResults = [];
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi gợi ý: $e')),
          );
        }
      } else {
        setState(() {
          _autocompleteSuggestions.clear();
          _searchResults.clear();
        });
      }
    });
  }

  void _submitSearch(String query) async {
    try {
      final results = await _searchService.searchProducts(
        query,
        brands: _selectedBrands,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        category: _selectedCategory,
      );
      setState(() {
        _searchResults = results;
        _autocompleteSuggestions.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tìm kiếm: $e')),
      );
    }
  }

  void _clearSearchHistory() {
    setState(() {
      _searchService.clearSearchHistory();
    });
  }

  void _removeSearchItem(String query) {
    setState(() {
      _searchService.removeFromSearchHistory(query);
    });
  }

  void _showFilterDialog() async {
    final brands = await _searchService.getBrands();
    final categories = await _searchService.getCategories();
    List<String> tempBrands = List.from(_selectedBrands);
    double? tempMinPrice = _minPrice;
    double? tempMaxPrice = _maxPrice;
    String? tempCategory = _selectedCategory;
    final minPriceController = TextEditingController(text: _minPrice?.toString());
    final maxPriceController = TextEditingController(text: _maxPrice?.toString());
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: const Text('Lọc sản phẩm'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Thương hiệu', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...brands.map((brand) {
                      return CheckboxListTile(
                        title: Text(brand!),
                        value: tempBrands.contains(brand),
                        onChanged: (value) {
                          dialogSetState(() {
                            if (value == true) {
                              tempBrands.add(brand!);
                            } else {
                              tempBrands.remove(brand);
                            }
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 16),
                    const Text('Giá', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(
                      controller: minPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Giá tối thiểu',
                        errorText: minPriceController.text.isNotEmpty && tempMinPrice == null ? 'Giá không hợp lệ' : null,
                      ),
                      onChanged: (value) {
                        dialogSetState(() {
                          tempMinPrice = double.tryParse(value);
                        });
                      },
                    ),
                    TextField(
                      controller: maxPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Giá tối đa',
                        errorText: maxPriceController.text.isNotEmpty && tempMaxPrice == null ? 'Giá không hợp lệ' : null,
                      ),
                      onChanged: (value) {
                        dialogSetState(() {
                          tempMaxPrice = double.tryParse(value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Danh mục', style: TextStyle(fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: tempCategory,
                      hint: const Text('Chọn danh mục'),
                      items: categories
                          .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(_categoryNames[category] ?? 'N/A'),
                      ))
                          .toList(),
                      onChanged: (value) {
                        dialogSetState(() {
                          tempCategory = value;
                        });
                      },
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    if (tempBrands.isEmpty && tempMinPrice == null && tempMaxPrice == null && tempCategory == null) {
                      dialogSetState(() {
                        errorMessage = 'Vui lòng chọn ít nhất một bộ lọc';
                      });
                      return;
                    }
                    if (tempMinPrice != null && tempMaxPrice != null && tempMinPrice! > tempMaxPrice!) {
                      dialogSetState(() {
                        errorMessage = 'Giá tối thiểu không được lớn hơn giá tối đa';
                      });
                      return;
                    }
                    setState(() {
                      _selectedBrands = tempBrands;
                      _minPrice = tempMinPrice;
                      _maxPrice = tempMaxPrice;
                      _selectedCategory = tempCategory;
                    });
                    _submitSearch(_searchController.text);
                    Navigator.pop(context);
                  },
                  child: const Text('Áp dụng'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Widget hiển thị gợi ý với highlight từ khóa
  Widget _buildSuggestionItem(String suggestion, String query) {
    final normalizedQuery = query.toLowerCase();
    final normalizedSuggestion = suggestion.toLowerCase();
    final startIndex = normalizedSuggestion.indexOf(normalizedQuery);
    if (startIndex == -1) {
      return Text(suggestion);
    }
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: suggestion.substring(0, startIndex),
            style: const TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: suggestion.substring(startIndex, startIndex + query.length),
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: suggestion.substring(startIndex + query.length),
            style: const TextStyle(color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _smartImage(String imageUrl, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (imageUrl.isEmpty) {
      return const Icon(Icons.image_not_supported);
    }
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      );
    }
    try {
      final bytes = base64Decode(imageUrl);
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
      );
    } catch (_) {
      return const Icon(Icons.image_not_supported);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onSubmitted: _submitSearch,
                  decoration: const InputDecoration(
                    hintText: 'Tìm kiếm sản phẩm...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterDialog,
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {},
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_searchController.text.isEmpty && _searchService.getSearchHistory().isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Lịch sử tìm kiếm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton(
                      onPressed: _clearSearchHistory,
                      child: const Text('Xóa tất cả', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchService.getSearchHistory().length,
                  itemBuilder: (context, index) {
                    final query = _searchService.getSearchHistory()[index];
                    return ListTile(
                      leading: const Icon(Icons.history, color: Colors.grey),
                      title: Text(query),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _removeSearchItem(query),
                      ),
                      onTap: () {
                        _searchController.text = query;
                        _submitSearch(query);
                      },
                    );
                  },
                ),
              ],
              if (_autocompleteSuggestions.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Gợi ý', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _autocompleteSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _autocompleteSuggestions[index];
                    return ListTile(
                      title: _buildSuggestionItem(suggestion, _searchController.text),
                      onTap: () {
                        _searchController.text = suggestion;
                        _submitSearch(suggestion);
                      },
                    );
                  },
                ),
              ],
              if (_searchResults.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Kết quả tìm kiếm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final product = _searchResults[index];
                    final imageUrl = product.images.isNotEmpty ? product.images[0].url : '';
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: SizedBox(
                          width: 80,
                          height: 80,
                          child: imageUrl.isNotEmpty
                              ? _smartImage(imageUrl)
                              : const Icon(Icons.image_not_supported),
                        ),
                        title: Text(product.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.minPrice == product.maxPrice
                                  ? 'Giá: \$${product.minPrice.toStringAsFixed(0)}'
                                  : 'Giá: \$${product.minPrice.toStringAsFixed(0)} - \$${product.maxPrice.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                            ),
                            Text('Thương hiệu: ${product.brand ?? 'N/A'}'),
                            Text('Danh mục: ${_categoryNames[product.categoryId] ?? 'N/A'}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }
}
