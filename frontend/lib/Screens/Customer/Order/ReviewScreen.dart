import 'dart:io';
import 'package:flutter/material.dart';
import 'package:danentang/data/order_data.dart';
import 'package:danentang/models/Order.dart';
import 'package:danentang/models/OrderItem.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/product.dart';
import '../../../ultis/image_helper.dart';

class ReviewScreen extends StatefulWidget {
  final String orderId;

  const ReviewScreen({super.key, required this.orderId});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ImagePicker _picker = ImagePicker();
  final Map<String, double> _ratings = {};
  final Map<String, String> _reviewTexts = {};
  final Map<String, List<File>> _photos = {};
  List<Product> products = [
    Product(
      id: 'p1',
      name: 'Laptop ABC',
      brand: 'XYZ',
      description: 'Mô tả...',
      discountPercentage: 10,
      categoryId: 'c1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      images: [
        ProductImage(id: 'i1', url: '<base64-encoded-string>', sortOrder: 1),
      ],
      variants: [
        ProductVariant(
          id: 'v1',
          variantName: '8GB RAM',
          additionalPrice: 0,
          inventory: 5,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    final order = testOrders.firstWhere((o) => o.id == widget.orderId);
    for (var item in order.items) {
      _ratings[item.productId] = 0;
      _reviewTexts[item.productId] = '';
      _photos[item.productId] = [];
    }
  }

  Future<void> _pickImage(ImageSource source, String productId) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _photos[productId]!.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
      );
    }
  }

  void _showImageSourceDialog(String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn nguồn ảnh'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera, productId);
            },
            child: const Text('Máy ảnh', style: TextStyle(color: Color(0xFF4B5EFC))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery, productId);
            },
            child: const Text('Thư viện', style: TextStyle(color: Color(0xFF4B5EFC))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = testOrders.firstWhere(
          (o) => o.id == widget.orderId,
      orElse: () => throw Exception('Order not found'),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF4B5EFC),
        elevation: 0,
        title: Text(
          'Đánh giá đơn hàng #${order.orderNumber}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4B5EFC)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth < 720 ? constraints.maxWidth : 720.0;
            return Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Đánh giá sản phẩm',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: order.items.map((item) => _buildReviewItem(item)).toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            child: const Text(
                              'Hủy',
                              style: TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              _ratings.forEach((productId, rating) {
                                print('Sản phẩm $productId: $rating sao, Nhận xét: ${_reviewTexts[productId]}, Ảnh: ${_photos[productId]!.length}');
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã gửi đánh giá')),
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4B5EFC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            child: const Text(
                              'Gửi đánh giá',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReviewItem(OrderItem item) {
    final Product product = products.firstWhere(
          (p) => p.variants.any((v) => v.id == item.productVariantId),
      orElse: () => Product(
        id: '',
        name: '',
        brand: '',
        description: '',
        discountPercentage: 0,
        categoryId: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        images: [],
        variants: [],
      ),
    );

    final String? base64 = product.images.isNotEmpty ? product.images.first.url : null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageFromBase64String(
                    base64,
                    width: 60,
                    height: 60,
                    placeholder: const AssetImage('assets/placeholder.png'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Biến thể: ${item.variantName}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Số lượng: ${item.quantity}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₫${NumberFormat('#,##0', 'vi_VN').format(item.price * item.quantity)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Xếp hạng',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < (_ratings[item.productId] ?? 0) ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFD700),
                    size: 24,
                  ),
                  onPressed: () {
                    setState(() {
                      _ratings[item.productId] = (index + 1).toDouble();
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                );
              }),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nhận xét',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Viết nhận xét...',
                hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF4B5EFC)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 3,
              style: const TextStyle(fontSize: 12),
              onChanged: (value) {
                setState(() {
                  _reviewTexts[item.productId] = value;
                });
              },
            ),
            const SizedBox(height: 12),
            const Text(
              'Ảnh',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _photos[item.productId]!.map((photo) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        photo,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red, size: 16),
                        onPressed: () {
                          setState(() {
                            _photos[item.productId]!.remove(photo);
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showImageSourceDialog(item.productId),
              child: Row(
                children: [
                  Icon(Icons.add_photo_alternate, color: const Color(0xFF4B5EFC), size: 20),
                  const SizedBox(width: 4),
                  const Text(
                    'Thêm ảnh',
                    style: TextStyle(
                      color: Color(0xFF4B5EFC),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}