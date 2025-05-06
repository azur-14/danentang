// lib/models/Review.dart

class Review {
  final String username;
  final double rating;
  final String comment;

  Review({
    required this.username,
    required this.rating,
    required this.comment,
  });

  /// Parse from JSON map returned by your API
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      username: json['username'] as String? ?? '',
      rating:   (json['rating']   as num?)?.toDouble() ?? 0.0,
      comment:  json['comment']  as String? ?? '',
    );
  }

  /// Convert back to JSON (if you ever need to POST/PUT)
  Map<String, dynamic> toJson() => {
    'username': username,
    'rating':   rating,
    'comment':  comment,
  };
}
