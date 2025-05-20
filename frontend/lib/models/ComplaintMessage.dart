class ComplaintMessage {
  final String senderId;
  final String receiverId;
  final String content;
  final bool isFromCustomer;
  final DateTime createdAt;
  final String? imageUrl;   // <-- Thêm dòng này

  ComplaintMessage({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isFromCustomer,
    required this.createdAt,
    this.imageUrl,          // <-- Thêm dòng này
  });

  factory ComplaintMessage.fromJson(Map<String, dynamic> json) {
    return ComplaintMessage(
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      isFromCustomer: json['isFromCustomer'],
      createdAt: DateTime.parse(json['createdAt']),
      imageUrl: json['imageUrl'],       // <-- Thêm dòng này
    );
  }
}
