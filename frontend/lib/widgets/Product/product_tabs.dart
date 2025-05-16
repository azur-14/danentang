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
        const SnackBar(content: Text('Gửi thành công!')),
      );
      _formKey.currentState!.reset();
      setState(() => _rating = 5);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.grey[200],
            child: TabBar(
              controller: widget.tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.purple,
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
                    style: const TextStyle(fontSize: 14),
                  ),
                ),

                // Tab 2: Reviews + form
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Danh sách đánh giá',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<List<Review>>(
                        future: _futureReviews,
                        builder: (context, snap) {
                          if (snap.connectionState != ConnectionState.done) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final reviews = snap.data ?? [];
                          if (reviews.isEmpty) {
                            return const Text('Chưa có đánh giá.');
                          }
                          return Column(
                            children: reviews.map((r) {
                              final username = r.userId != null
                                  ? 'Người dùng'
                                  : (r.guestName ?? 'Khách vãng lai');
                              return ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person, size: 20),
                                ),
                                title: Text(username),
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
                                    Text(r.comment),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const Divider(height: 32),
                      const Text(
                        'Gửi đánh giá của bạn',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!_isLoggedIn) ...[
                              TextFormField(
                                decoration: const InputDecoration(labelText: 'Tên của bạn'),
                                validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                                onSaved: (v) => _guestName = v,
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (_isLoggedIn) ...[
                              const Text('Đánh giá', style: TextStyle(fontWeight: FontWeight.bold)),
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
                              decoration: const InputDecoration(labelText: 'Bình luận'),
                              maxLines: 3,
                              validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                              onSaved: (v) => _comment = v ?? '',
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton(
                                onPressed: _submitting ? null : _submitReview,
                                child: _submitting
                                    ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                    : Text(_isLoggedIn ? 'Gửi đánh giá' : 'Gửi bình luận'),
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
