import 'dart:convert';
import 'package:http/http.dart' as http;

class ElasticSearchService {
  final String host;
  final int port;
  final String index;

  ElasticSearchService({
    this.host = '10.0.2.2',
    this.port = 9200,
    this.index = 'products',
  });

  /// Tìm kiếm sản phẩm theo từ khóa (search)
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
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
      "size": 10,
      "query": {
        "match_phrase_prefix": {
          "name": prefix,
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
}