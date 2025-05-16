import 'dart:convert';
import 'package:http/http.dart' as http;

class ElasticSearchService {
  final String host;
  final int port;
  final String index;
  // In-memory storage for search history (use shared_preferences in a real app)
  final List<String> _searchHistory = [];

  ElasticSearchService({
    this.host = '10.0.2.2',
    this.port = 9200,
    this.index = 'products',
  });

  /// Tìm kiếm sản phẩm theo từ khóa (search)
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    // Lưu truy vấn vào lịch sử tìm kiếm
    _addToSearchHistory(query);

    final url = Uri.parse('http://$host:$port/$index/_search');
    final body = jsonEncode({
      "query": {
        "match": {
          "name": query,
        }
      }
    });
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final hits = data['hits']['hits'] as List;
      return hits.map((e) => e['_source'] as Map<String, dynamic>).toList();
    } else {
      throw Exception('Elasticsearch search failed: ${response.statusCode}');
    }
  }

  /// Gợi ý tự động (autocomplete) dựa trên tiền tố
  Future<List<String>> autocomplete(String prefix) async {
    final url = Uri.parse('http://$host:$port/$index/_search');
    final body = jsonEncode({
      "size": 5, // Giảm số lượng gợi ý để tăng tốc độ
      "query": {
        "match_phrase_prefix": {
          "name": {
            "query": prefix,
            "slop": 2, // Cho phép khớp linh hoạt hơn
          }
        }
      },
      "highlight": {
        "fields": {
          "name": {}
        }
      }
    });
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final hits = data['hits']['hits'] as List;
      return hits.map((e) => e['_source']['name'] as String).toSet().toList();
    } else {
      throw Exception('Elasticsearch autocomplete failed: ${response.statusCode}');
    }
  }

  /// Gọi API để đồng bộ toàn bộ MongoDB → Elasticsearch
  Future<void> reindexProducts() async {
    final url = Uri.parse('http://$host:3000/api/sync/products'); // Khớp với endpoint backend
    final response = await http.post(url);

    if (response.statusCode == 200) {
      print('✅ Reindex thành công');
    } else {
      throw Exception('❌ Reindex thất bại: ${response.statusCode}');
    }
  }

  /// Thêm truy vấn vào lịch sử tìm kiếm
  void _addToSearchHistory(String query) {
    if (query.isNotEmpty) {
      // Xóa trùng lặp nếu có, sau đó thêm vào đầu danh sách
      _searchHistory.remove(query);
      _searchHistory.insert(0, query);
      // Giới hạn lịch sử ở 10 mục
      if (_searchHistory.length > 10) {
        _searchHistory.removeLast();
      }
    }
  }

  /// Lấy danh sách lịch sử tìm kiếm
  List<String> getSearchHistory() {
    return List.from(_searchHistory);
  }

  /// Xóa một mục trong lịch sử tìm kiếm
  void removeFromSearchHistory(String query) {
    _searchHistory.remove(query);
  }

  /// Xóa toàn bộ lịch sử tìm kiếm
  void clearSearchHistory() {
    _searchHistory.clear();
  }
}