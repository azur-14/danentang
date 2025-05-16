import 'package:flutter/material.dart';
import 'package:danentang/constants/colors.dart';

class OrderSummaryWidget extends StatelessWidget {
  final double subtotal;
  final double vat;
  final double shipping;
  final double discount;
  final double total;
  final TextEditingController discountController;
  final VoidCallback onApplyCoupon;
  final bool applyingCoupon;
  final String? errorCoupon;
  final int loyaltyPointsAvailable;
  final int loyaltyPointsToUse;
  final TextEditingController loyaltyController;
  final ValueChanged<String> onLoyaltyChanged;
  final VoidCallback onCheckout;

  const OrderSummaryWidget({
    Key? key,
    required this.subtotal,
    required this.vat,
    required this.shipping,
    required this.discount,
    required this.total,
    required this.discountController,
    required this.onApplyCoupon,
    required this.applyingCoupon,
    required this.errorCoupon,
    required this.loyaltyPointsAvailable,
    required this.loyaltyPointsToUse,
    required this.loyaltyController,
    required this.onLoyaltyChanged,
    required this.onCheckout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tóm tắt đơn hàng",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Mã giảm giá
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: discountController,
                  decoration: InputDecoration(
                    hintText: "Nhập mã giảm giá",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: AppColors.hexToColor(AppColors.grey300)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: applyingCoupon ? null : onApplyCoupon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.hexToColor(AppColors.purple),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: applyingCoupon
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("Áp dụng"),
              ),
            ],
          ),
          if (errorCoupon != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                errorCoupon!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          const SizedBox(height: 12),
          // Điểm tích lũy
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Điểm tích lũy"),
              Text("Bạn có $loyaltyPointsAvailable điểm"),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: loyaltyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Nhập điểm muốn dùng",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: AppColors.hexToColor(AppColors.grey300)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: onLoyaltyChanged,
                ),
              ),
              const SizedBox(width: 8),
              Text("= ₫${loyaltyPointsToUse * 1000}"),
            ],
          ),
          const SizedBox(height: 16),
          // Tóm tắt giá trị
          _buildSummaryRow("Giá", "₫${subtotal.toInt()}"),
          _buildSummaryRow("VAT", "₫${vat.toInt()}"),
          _buildSummaryRow("Vận chuyển", "₫${shipping.toInt()}"),
          _buildSummaryRow("Giảm giá", "-₫${discount.toInt()}"),
          const Divider(),
          _buildSummaryRow(
            "Tổng giá",
            "₫${total.toInt()}",
            isTotal: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onCheckout,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.hexToColor(AppColors.purple),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              "Mua ngay",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : AppColors.hexToColor(AppColors.grey),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.black : AppColors.hexToColor(AppColors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
