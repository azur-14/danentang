import 'dart:io';
import 'package:flutter/material.dart';
import 'package:danentang/data/order_data.dart';
import 'package:danentang/models/Order.dart';
import 'package:danentang/models/OrderItem.dart';
import 'package:go_router/go_router.dart';
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
  // Maps to store ratings, review text, and photos for each item (keyed by productId)
  final Map<String, double> _ratings = {};
  final Map<String, String> _reviewTexts = {};
  final Map<String, List<File>> _photos = {};
  // inject sẵn từ OrderDetailsScreen hoặc fetchAll
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
    // Initialize maps for each item in the order
    final order = testOrders.firstWhere((o) => o.id == widget.orderId);
    for (var item in order.items) {
      _ratings[item.productId] = 0;
      _reviewTexts[item.productId] = '';
      _photos[item.productId] = [];
    }
  }

  // Method to pick an image for a specific product
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

  // Show dialog to choose image source
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
            child: const Text('Máy ảnh'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery, productId);
            },
            child: const Text('Thư viện'),
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
      appBar: AppBar(
        title: Text('Đánh giá đơn hàng #${order.orderNumber}'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đánh giá sản phẩm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: order.items.map((item) => _buildReviewItem(item)).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Hủy', style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Submit reviews
                    _ratings.forEach((productId, rating) {
                      print('Sản phẩm $productId: $rating sao, Nhận xét: ${_reviewTexts[productId]}, Ảnh: ${_photos[productId]!.length}');
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã gửi đánh giá')),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(120, 48),
                  ),
                  child: const Text(
                    'Gửi đánh giá',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    width: 80,
                    height: 80,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Biến thể: ${item.variantName} | Số lượng: ${item.quantity}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (item.productVariantId != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Mã biến thể: ${item.productVariantId}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        '₫${NumberFormat('#,##0', 'vi_VN').format(item.price * item.quantity)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.push('/reorder/${widget.orderId}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text(
                    'Mua lại',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Xếp hạng của bạn',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < (_ratings[item.productId] ?? 0) ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      _ratings[item.productId] = (index + 1).toDouble();
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nhận xét chi tiết',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Viết nhận xét của bạn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  _reviewTexts[item.productId] = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Thêm ảnh',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
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
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.red, size: 20),
                        onPressed: () {
                          setState(() {
                            _photos[item.productId]!.remove(photo);
                          });
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_photo_alternate, color: Colors.grey),
                  onPressed: () => _showImageSourceDialog(item.productId),
                ),
                const Text('Thêm ảnh', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}