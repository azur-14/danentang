import 'package:flutter/material.dart';

class OrderFilterWidget extends StatefulWidget {
  final double maxPrice;
  final RangeValues priceRange;
  final DateTime? startDate;
  final DateTime? endDate;
  final String selectedCategory;
  final String selectedBrand;
  final List<String> categories;
  final List<String> brands;
  final bool isDialog;
  final Function(RangeValues) onPriceRangeChanged;
  final Function(DateTime?) onStartDateChanged;
  final Function(DateTime?) onEndDateChanged;
  final Function(String) onCategoryChanged;
  final Function(String) onBrandChanged;
  final VoidCallback onApply;
  final VoidCallback onReset;

  const OrderFilterWidget({
    super.key,
    required this.maxPrice,
    required this.priceRange,
    required this.startDate,
    required this.endDate,
    required this.selectedCategory,
    required this.selectedBrand,
    required this.categories,
    required this.brands,
    required this.isDialog,
    required this.onPriceRangeChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onCategoryChanged,
    required this.onBrandChanged,
    required this.onApply,
    required this.onReset,
  });

  @override
  _OrderFilterWidgetState createState() => _OrderFilterWidgetState();
}

class _OrderFilterWidgetState extends State<OrderFilterWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.isDialog ? null : 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDialog ? null : const Color(0xFFF7FAFC),
        borderRadius: widget.isDialog ? const BorderRadius.vertical(top: Radius.circular(16)) : null,
        boxShadow: widget.isDialog ? null : [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: widget.isDialog ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lọc đơn hàng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748)),
              ),
              if (widget.isDialog)
                IconButton(
                  icon: Icon(Icons.close, color: const Color(0xFF4A90E2)),
                  onPressed: () => Navigator.pop(context),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Theo ngày tạo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF4A90E2))),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: const Color(0xFF4A90E2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: widget.startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            primaryColor: const Color(0xFF4A90E2),
                            colorScheme: ColorScheme.light(primary: const Color(0xFF4A90E2)),
                            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      widget.onStartDateChanged(date);
                    }
                  },
                  child: Text(
                    widget.startDate != null
                        ? '${widget.startDate!.day}/${widget.startDate!.month}/${widget.startDate!.year}'
                        : 'Từ ngày',
                    style: TextStyle(color: const Color(0xFF4A90E2)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: const Color(0xFF4A90E2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: widget.endDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            primaryColor: const Color(0xFF4A90E2),
                            colorScheme: ColorScheme.light(primary: const Color(0xFF4A90E2)),
                            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      widget.onEndDateChanged(date);
                    }
                  },
                  child: Text(
                    widget.endDate != null
                        ? '${widget.endDate!.day}/${widget.endDate!.month}/${widget.endDate!.year}'
                        : 'Đến ngày',
                    style: TextStyle(color: const Color(0xFF4A90E2)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Product Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF4A90E2))),
          DropdownButtonFormField<String>(
            value: widget.selectedCategory,
            items: widget.categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category, style: TextStyle(color: const Color(0xFF2D3748))),
              );
            }).toList(),
            onChanged: (String? newValue) {
              widget.onCategoryChanged(newValue ?? 'All');
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF7FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: const Color(0xFF4A90E2))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: const Color(0xFF4A90E2))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: const Color(0xFF4A90E2))),
            ),
            dropdownColor: const Color(0xFFF7FAFC),
            icon: Icon(Icons.arrow_drop_down, color: const Color(0xFF4A90E2)),
          ),
          const SizedBox(height: 16),
          Text('Brand', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF4A90E2))),
          DropdownButtonFormField<String>(
            value: widget.selectedBrand,
            items: widget.brands.map((String brand) {
              return DropdownMenuItem<String>(
                value: brand,
                child: Text(brand, style: TextStyle(color: const Color(0xFF2D3748))),
              );
            }).toList(),
            onChanged: (String? newValue) {
              widget.onBrandChanged(newValue ?? 'All');
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF7FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: const Color(0xFF4A90E2))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: const Color(0xFF4A90E2))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: const Color(0xFF4A90E2))),
            ),
            dropdownColor: const Color(0xFFF7FAFC),
            icon: Icon(Icons.arrow_drop_down, color: const Color(0xFF4A90E2)),
          ),
          const SizedBox(height: 16),
          Text('Price', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF4A90E2))),
          RangeSlider(
            values: widget.priceRange,
            min: 0,
            max: widget.maxPrice,
            divisions: 100,
            activeColor: const Color(0xFF4A90E2),
            inactiveColor: const Color(0xFFD3E0EA),
            labels: RangeLabels(widget.priceRange.start.round().toString(), widget.priceRange.end.round().toString()),
            onChanged: widget.onPriceRangeChanged,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0 VNĐ', style: TextStyle(color: const Color(0xFF4A90E2))),
                Text('${widget.maxPrice.round()} VNĐ', style: TextStyle(color: const Color(0xFF4A90E2))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onReset,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: const Color(0xFF4A90E2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('Reset', style: TextStyle(color: const Color(0xFF4A90E2))),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onApply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
          if (widget.isDialog) const SizedBox(height: 16),
        ],
      ),
    );
  }
}