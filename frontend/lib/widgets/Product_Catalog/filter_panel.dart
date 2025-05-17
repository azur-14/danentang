import 'package:flutter/material.dart';

import '../../../models/category.dart';

class FilterPanel extends StatelessWidget {
  final List<Category> categories;
  final List<String> brands;
  final String? selectedCategoryId;
  final String? selectedBrand;
  final double priceRange;
  final int? selectedRating;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onBrandChanged;
  final ValueChanged<double> onPriceChanged;
  final ValueChanged<double> onPriceChangeEnd;
  final ValueChanged<int?> onRatingChanged;
  final VoidCallback onReset;
  final VoidCallback onApply;

  const FilterPanel({
    super.key,
    required this.categories,
    required this.brands,
    this.selectedCategoryId,
    this.selectedBrand,
    required this.priceRange,
    this.selectedRating,
    required this.onCategoryChanged,
    required this.onBrandChanged,
    required this.onPriceChanged,
    required this.onPriceChangeEnd,
    required this.onRatingChanged,
    required this.onReset,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Filter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        const Text('Product Category'),
        DropdownButton<String>(
          isExpanded: true,
          hint: const Text('All'),
          value: selectedCategoryId,
          items: [
            const DropdownMenuItem(value: null, child: Text('All')),
            ...categories.map((category) {
              return DropdownMenuItem(
                value: category.id,
                child: Text(category.name),
              );
            }).toList(),
          ],
          onChanged: onCategoryChanged,
        ),
        const SizedBox(height: 16),
        const Text('Brand'),
        DropdownButton<String>(
          isExpanded: true,
          hint: const Text('All'),
          value: selectedBrand,
          items: brands.map((brand) {
            return DropdownMenuItem(
              value: brand,
              child: Text(brand),
            );
          }).toList(),
          onChanged: onBrandChanged,
        ),
        const SizedBox(height: 16),
        const Text('Price'),
        Slider(
          value: priceRange,
          min: 0,
          max: 100000000,
          divisions: 100,
          activeColor: Colors.blue[700],
          label: '${priceRange.toStringAsFixed(0)} VND',
          onChanged: onPriceChanged,
          onChangeEnd: onPriceChangeEnd,
        ),
        Row(
          children: const [
            Expanded(child: Text('0 VND')),
            Expanded(child: Text('100,000,000 VND', textAlign: TextAlign.right)),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Rating'),
        Column(
          children: [
            for (int i = 5; i >= 1; i--)
              Row(
                children: [
                  Radio<int>(
                    value: i,
                    groupValue: selectedRating,
                    activeColor: Colors.blue[700],
                    onChanged: onRatingChanged,
                  ),
                  Text('$i ★'),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: onReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset'),
            ),
            ElevatedButton(
              onPressed: onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ],
    );
  }
}