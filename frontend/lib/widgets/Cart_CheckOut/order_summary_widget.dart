import 'package:flutter/material.dart';
import 'package:danentang/constants/colors.dart';

class OrderSummaryWidget extends StatelessWidget {
  final double subtotal;
  final double vat;
  final double shipping;
  final double discount;
  final double total;
  final bool applyPoints;
  final TextEditingController discountController;
  final Function(bool) onApplyPointsChanged;
  final VoidCallback onCheckout;

  const OrderSummaryWidget({
    required this.subtotal,
    required this.vat,
    required this.shipping,
    required this.discount,
    required this.total,
    required this.applyPoints,
    required this.discountController,
    required this.onApplyPointsChanged,
    required this.onCheckout,
  });

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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: discountController,
                  decoration: InputDecoration(
                    hintText: "Enter code",
                    hintStyle: TextStyle(color: AppColors.hexToColor(AppColors.grey)),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  onApplyPointsChanged(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.hexToColor(AppColors.purple),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  minimumSize: const Size(100, 50),
                ),
                child: const Text(
                  "Áp dụng",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Đổi điểm tích lũy"),
              Row(
                children: [
                  const Text("Tổng quy đổi: 0 ₫"),
                  const SizedBox(width: 8),
                  Switch(
                    value: applyPoints,
                    onChanged: onApplyPointsChanged,
                    activeColor: AppColors.hexToColor(AppColors.purple),
                  ),
                ],
              ),
            ],
          ),
          _buildSummaryRow("Giá", "₫${subtotal.toInt()}.000"),
          _buildSummaryRow("VAT", "₫${vat.toInt()}"),
          _buildSummaryRow("Vận chuyển", "₫${shipping.toInt()}.000"),
          _buildSummaryRow("Giảm giá", "-₫${discount.toInt()}.000"),
          const Divider(),
          _buildSummaryRow(
            "Tổng giá",
            "₫${total.toInt()}.000",
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