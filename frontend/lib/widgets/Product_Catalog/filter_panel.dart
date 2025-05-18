import 'package:flutter/material.dart';
import 'package:danentang/models/Category.dart'; // Use uppercase Category.dart

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
        const Text(
          'Filter Products',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: selectedCategoryId == null,
              onSelected: (selected) {
                if (selected) onCategoryChanged(null);
              },
            ),
            ...categories.map((category) => ChoiceChip(
              label: Text(category.name),
              selected: selectedCategoryId == category.id,
              onSelected: (selected) {
                if (selected) onCategoryChanged(category.id);
              },
            )),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Brand', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: selectedBrand,
          hint: const Text('Select Brand'),
          isExpanded: true,
          items: brands.map((brand) => DropdownMenuItem<String>(
            value: brand,
            child: Text(brand),
          )).toList(),
          onChanged: onBrandChanged,
        ),
        const SizedBox(height: 16),
        const Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: priceRange,
          min: 0,
          max: 100000000,
          divisions: 100,
          label: '₫${priceRange.round()}',
          onChanged: onPriceChanged,
          onChangeEnd: onPriceChangeEnd,
        ),
        const SizedBox(height: 16),
        const Text('Rating', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (index) {
            final rating = 5 - index;
            return GestureDetector(
              onTap: () => onRatingChanged(rating),
              child: Icon(
                Icons.star,
                color: selectedRating != null && rating <= selectedRating!
                    ? Colors.yellow
                    : Colors.grey,
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: onReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
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