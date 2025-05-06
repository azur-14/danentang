import 'CartItem.dart';

class Cart {
  final String id;
  final String userId;
  final List<CartItem> items;

  Cart({ required this.id, required this.userId, required this.items });

  factory Cart.fromJson(Map<String,dynamic> json) {
    final rawId = json['_id'] ?? json['id'];
    var list = (json['items'] as List)
        .map((e) => CartItem.fromJson(e))
        .toList();
    return Cart(id: rawId, userId: json['userId'], items: list);
  }
}
