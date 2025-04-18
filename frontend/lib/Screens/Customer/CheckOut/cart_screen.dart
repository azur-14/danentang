import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:danentang/models/product.dart';
import '../../../models/CartItem.dart';
import 'package:danentang/constants/colors.dart';


class CartScreenCheckOut extends StatefulWidget {
  final bool isLoggedIn;

  const CartScreenCheckOut({required this.isLoggedIn});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreenCheckOut> {
  final List<Product> products = [
    Product(
      name: "Apple W-Series 6",
      price: "45000",
      discount: "0",
      imageUrl: 'assets/images/watch.jpg',
      rating: 4.7,
    ),
    Product(
      name: "Siberina 800",
      price: "45000",
      discount: "0",
      imageUrl: 'assets/images/headphones.jpg',
      rating: 4.8,
    ),
    Product(
      name: "Lycra Men's Shirt",
      price: "45000",
      discount: "0",
      imageUrl: 'assets/images/shirt.jpg',
      rating: 4.5,
    ),
  ];

  late List<CartItem> cartItems;
  bool isEditing = false;
  bool applyDiscount = false;
  final _discountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cartItems = products.map((product) {
      return CartItem(
        product: product,
        quantity: 2,
        size: product.name == "Apple W-Series 6"
            ? "Số: 35"
            : product.name == "Siberina 800"
            ? "Size: M"
            : "Size: 5",
      );
    }).toList();
  }

  double get subtotal => cartItems.fold(0, (sum, item) {
    final price = double.parse(item.product.price.replaceAll('₦', '').replaceAll(',', ''));
    return sum + (price * item.quantity);
  });

  double get discount => applyDiscount ? 60000 : 0;
  double get shipping => 50000;
  double get vat => 20000;
  double get total => subtotal + vat + shipping - discount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My cart"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
            child: Text(
              isEditing ? "Xong" : "Chỉnh sửa",
              style: TextStyle(color: AppColors.hexToColor(AppColors.black)),
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(item.product.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.product.name,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isEditing)
                                  IconButton(
                                    icon: Icon(Icons.delete, color: AppColors.hexToColor(AppColors.grey)),
                                    onPressed: () {
                                      setState(() {
                                        cartItems.removeAt(index);
                                      });
                                    },
                                  ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text(item.size, style: TextStyle(color: AppColors.hexToColor(AppColors.grey))),
                                SizedBox(width: 8),
                                Row(
                                  children: [
                                    Icon(Icons.star, color: AppColors.hexToColor(AppColors.yellow), size: 16),
                                    SizedBox(width: 4),
                                    Text("${item.product.rating}", style: TextStyle(color: AppColors.hexToColor(AppColors.grey))),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "₦${item.product.price}",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove_circle, color: AppColors.hexToColor(AppColors.purple)),
                                      onPressed: () {
                                        setState(() {
                                          if (item.quantity > 1) item.quantity--;
                                        });
                                      },
                                    ),
                                    Text("${item.quantity}", style: TextStyle(fontSize: 16)),
                                    IconButton(
                                      icon: Icon(Icons.add_circle, color: AppColors.hexToColor(AppColors.purple)),
                                      onPressed: () {
                                        setState(() {
                                          item.quantity++;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            color: AppColors.hexToColor(AppColors.white),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _discountController,
                        decoration: InputDecoration(
                          hintText: "Enter code",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: AppColors.hexToColor(AppColors.grey300)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: AppColors.hexToColor(AppColors.grey300)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: AppColors.hexToColor(AppColors.grey300)),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          applyDiscount = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.hexToColor(AppColors.purple),
                        foregroundColor: AppColors.hexToColor(AppColors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        minimumSize: Size(100, 50),
                      ),
                      child: Text(
                        "Áp dụng",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Đổi điểm tích lũy"),
                    Row(
                      children: [
                        Text("Tổng quy đổi: 0.0 Đ"),
                        SizedBox(width: 8),
                        Switch(
                          value: applyDiscount,
                          onChanged: (value) {
                            setState(() {
                              applyDiscount = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                _buildSummaryRow("Giá", "₦${subtotal.toInt()}"),
                _buildSummaryRow("VAT", "₦${vat.toInt()}"),
                _buildSummaryRow("Vận chuyển", "₦${shipping.toInt()}"),
                _buildSummaryRow("Giảm giá", "-₦${discount.toInt()}"),
                Divider(),
                _buildSummaryRow("Tổng giá", "₦${total.toInt()}", isTotal: true),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.go('/checkout', extra: widget.isLoggedIn);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.hexToColor(AppColors.purple),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Mua ngay",
                    style: TextStyle(fontSize: 16, color: AppColors.hexToColor(AppColors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}