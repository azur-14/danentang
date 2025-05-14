import 'package:flutter/material.dart';
import '../../../Service/elasticsearch_service.dart';

class Searching extends StatelessWidget {
  const Searching({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Search',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 18),
          elevation: 0,
        ),
      ),
      home: const SearchScreen(),
    );
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
  List<String> _lastSearches = [
    'Iphone 12 pro max',
    'Camera fujifilm',
    'Tripod Mini',
    'Bluetooth speaker',
    'Drawing pad',
  ];

  List<String> _autocompleteSuggestions = [];
  List<String> _searchResults = [];

  void _onSearchChanged(String query) async {
    if (query.isNotEmpty) {
      try {
        final suggestions = await _elasticService.autocomplete(query);
        setState(() {
          _autocompleteSuggestions = suggestions;
          _searchResults = [];
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
    if (query.isNotEmpty) {
      try {
        final results = await _elasticService.searchProducts(query);
        setState(() {
          _searchResults = results.map((e) => e['name'].toString()).toList();
          _autocompleteSuggestions.clear();
        });
        if (!_lastSearches.contains(query)) {
          _lastSearches.insert(0, query);
          if (_lastSearches.length > 5) {
            _lastSearches.removeLast();
          }
        }
      } catch (e) {
        print('Search error: $e');
      }
    }
  }

  void _clearSearchHistory() {
    setState(() {
      _lastSearches.clear();
    });
  }

  void _removeSearchItem(int index) {
    setState(() {
      _lastSearches.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
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
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_searchController.text.isEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Last search',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    TextButton(
                      onPressed: _clearSearchHistory,
                      child: const Text('Clear all', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _lastSearches.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.history, color: Colors.grey),
                      title: Text(_lastSearches[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _removeSearchItem(index),
                      ),
                      onTap: () {
                        _searchController.text = _lastSearches[index];
                        _submitSearch(_lastSearches[index]);
                      },
                    );
                  },
                ),
              ],
              if (_autocompleteSuggestions.isNotEmpty) ...[
                const Text('Suggestions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
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
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(_searchResults[index]));
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