import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/models/Review.dart';
import 'package:danentang/Service/product_service.dart';

class ProductTabs extends StatefulWidget {
  final TabController tabController;
  final Product product;

  const ProductTabs({
    Key? key,
    required this.tabController,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductTabs> createState() => _ProductTabsState();
}

class _ProductTabsState extends State<ProductTabs> {
  late Future<List<Review>> _futureReviews;
  final _formKey = GlobalKey<FormState>();
  int _rating = 5;
  String _comment = '';
  String? _guestName;
  bool _isLoggedIn = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
    _checkLogin();
  }

  void _loadReviews() {
    _futureReviews = ProductService.getReviews(widget.product.id);
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getString('token') != null;
    });
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _submitting = true);

    try {
      await ProductService.submitReview(
        productId: widget.product.id,
        guestName: _isLoggedIn ? null : _guestName,
        rating: _isLoggedIn ? _rating : null,
        comment: _comment,
      );
      _loadReviews();
      setState(() {}); // refresh UI
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Gửi thành công!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF87CEEB), // Xanh dương nhạt cho snackbar thành công
        ),
      );
      _formKey.currentState!.reset();
      setState(() => _rating = 5);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF2E2E2E), // Xám đậm cho snackbar lỗi
        ),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define color scheme
    const primaryColor = Color(0xFF1E90FF); // Xanh dương đậm (Dodger Blue) cho văn bản chính
    const lightBlueColor = Color(0xFF87CEEB); // Xanh dương nhạt (Light Sky Blue) cho nền và phụ
    const accentColor = Color(0xFF2E2E2E); // Xám đậm làm điểm nhấn
    const backgroundColor = Colors.white; // Nền trắng

    return Container(
      color: backgroundColor, // Nền trắng cho toàn bộ tab
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: lightBlueColor.withOpacity(0.1), // Xanh nhạt rất nhẹ cho tab bar
            child: TabBar(
              controller: widget.tabController,
              labelColor: primaryColor, // Xanh dương đậm cho tab được chọn
              unselectedLabelColor: Colors.grey,
              indicatorColor: primaryColor, // Xanh dương đậm cho indicator
              tabs: const [
                Tab(text: "Chi tiết sản phẩm"),
                Tab(text: "Đánh giá người dùng"),
              ],
            ),
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: widget.tabController,
              children: [
                // Tab 1: Product description
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    widget.product.description ?? "Không có mô tả.",
                    style: TextStyle(fontSize: 14, color: primaryColor.withOpacity(0.8)), // Xanh dương đậm nhạt cho mô tả
                  ),
                ),

                // Tab 2: Reviews + form
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Danh sách đánh giá',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: accentColor, // Xám đậm làm điểm nhấn cho tiêu đề
                        ),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<List<Review>>(
                        future: _futureReviews,
                        builder: (context, snap) {
                          if (snap.connectionState != ConnectionState.done) {
                            return Center(child: CircularProgressIndicator(color: primaryColor));
                          }
                          final reviews = snap.data ?? [];
                          if (reviews.isEmpty) {
                            return Text(
                              'Chưa có đánh giá.',
                              style: TextStyle(color: primaryColor.withOpacity(0.7)), // Xanh dương nhạt cho thông báo
                            );
                          }
                          return Column(
                            children: reviews.map((r) {
                              final username = r.userId != null
                                  ? 'Người dùng'
                                  : (r.guestName ?? 'Khách vãng lai');
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: lightBlueColor.withOpacity(0.1), // Xanh nhạt rất nhẹ cho avatar
                                  child: Icon(Icons.person, size: 20, color: primaryColor),
                                ),
                                title: Text(
                                  username,
                                  style: TextStyle(color: primaryColor), // Xanh dương đậm cho tên
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (r.rating != null)
                                      RatingBarIndicator(
                                        rating: r.rating!.toDouble(),
                                        itemBuilder: (_, __) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        itemCount: 5,
                                        itemSize: 16,
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      r.comment,
                                      style: TextStyle(color: primaryColor.withOpacity(0.7)), // Xanh dương nhạt cho bình luận
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      Divider(height: 32, color: lightBlueColor.withOpacity(0.2)), // Xanh nhạt rất nhẹ cho divider
                      Text(
                        'Gửi đánh giá của bạn',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: accentColor, // Xám đậm làm điểm nhấn cho tiêu đề
                        ),
                      ),
                      const SizedBox(height: 8),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!_isLoggedIn) ...[
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Tên của bạn',
                                  labelStyle: TextStyle(color: primaryColor.withOpacity(0.7)), // Xanh dương nhạt cho nhãn
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: primaryColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: lightBlueColor.withOpacity(0.3)),
                                  ),
                                ),
                                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                                onSaved: (v) => _guestName = v,
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (_isLoggedIn) ...[
                              Text(
                                'Đánh giá',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: accentColor, // Xám đậm làm điểm nhấn
                                ),
                              ),
                              RatingBar.builder(
                                initialRating: _rating.toDouble(),
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: false,
                                itemCount: 5,
                                itemBuilder: (_, __) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (r) => _rating = r.toInt(),
                              ),
                              const SizedBox(height: 12),
                            ],
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Bình luận',
                                labelStyle: TextStyle(color: primaryColor.withOpacity(0.7)), // Xanh dương nhạt cho nhãn
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: primaryColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: lightBlueColor.withOpacity(0.3)),
                                ),
                              ),
                              maxLines: 3,
                              validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                              onSaved: (v) => _comment = v ?? '',
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton(
                                onPressed: _submitting ? null : _submitReview,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor, // Xám đậm làm điểm nhấn cho nút
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: _submitting
                                    ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : Text(
                                  _isLoggedIn ? 'Gửi đánh giá' : 'Gửi bình luận',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}