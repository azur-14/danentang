import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:danentang/models/product.dart';
import 'package:danentang/models/Review.dart';

class ProductTabs extends StatelessWidget {
  final TabController tabController;
  final Product product;
  final List<Review> reviews;
  const ProductTabs({
    super.key,
    required this.tabController,
    required this.product,
    required this.reviews,
  });

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
              controller: tabController,
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
            height: 200,
            child: TabBarView(
              controller: tabController,
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    product.description ?? "Không có mô tả.",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: reviews.isEmpty
                        ? [
                      const Text(
                        "Chưa có đánh giá.",
                        style: TextStyle(fontSize: 14),
                      )
                    ]
                        : reviews.map(
                          (review) => ListTile(
                        leading: const CircleAvatar(
                          radius: 20,
                          child: Icon(
                            Icons.person,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          review.username,
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RatingBarIndicator(
                              rating: review.rating,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 16,
                            ),
                            Text(
                              review.comment,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ).toList(),
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