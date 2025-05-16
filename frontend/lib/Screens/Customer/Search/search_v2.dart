import 'package:flutter/material.dart';
import '../../../Service/elasticsearch_service.dart';

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
  final ElasticSearchService _elasticService = ElasticSearchService();
  List<Map<String, dynamic>> _searchResults = [];
  List<String> _autocompleteSuggestions = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  void _loadSearchHistory() {
    setState(() {
      // Sync history from ElasticSearchService
      _elasticService.getSearchHistory().forEach((query) {
        if (!_elasticService.getSearchHistory().contains(query)) {
          // No need to add manually, as getSearchHistory already returns the list
        }
      });
    });
  }

  void _onSearchChanged(String query) async {
    if (query.isNotEmpty) {
      try {
        final suggestions = await _elasticService.autocomplete(query);
        setState(() {
          _autocompleteSuggestions = suggestions;
          _searchResults.clear();
        });
      } catch (e) {
        print('Autocomplete error: $e');
      }
    } else {
      setState(() {
        _autocompleteSuggestions.clear();
        _searchResults.clear();
      });
    }
  }

  void _submitSearch(String query) async {
    if (query.isEmpty) return;
    try {
      final results = await _elasticService.searchProducts(query);
      setState(() {
        _searchResults = results;
        _autocompleteSuggestions.clear();
      });
    } catch (e) {
      print('Search error: $e');
    }
  }

  void _clearSearchHistory() {
    setState(() {
      _elasticService.clearSearchHistory();
    });
  }

  void _removeSearchItem(String query) {
    setState(() {
      _elasticService.removeFromSearchHistory(query);
    });
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
                    hintText: 'Search products...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {}, // Add cart logic if needed
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_searchController.text.isEmpty && _elasticService.getSearchHistory().isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Last search', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton(
                      onPressed: _clearSearchHistory,
                      child: const Text('Clear all', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _elasticService.getSearchHistory().length,
                  itemBuilder: (context, index) {
                    final query = _elasticService.getSearchHistory()[index];
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
                const Text('Suggestions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _autocompleteSuggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_autocompleteSuggestions[index]),
                      onTap: () {
                        _searchController.text = _autocompleteSuggestions[index];
                        _submitSearch(_autocompleteSuggestions[index]);
                      },
                    );
                  },
                ),
              ],
              if (_searchResults.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Search Results', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final product = _searchResults[index];
                    return ListTile(
                      title: Text(product['name'] ?? 'No name'),
                      subtitle: Text('Price: ${product['price']?.toString() ?? 'N/A'}'),
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
}