import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Categories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'See all',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              Chip(label: Text('Foods')),
              SizedBox(width: 8),
              Chip(label: Text('Gift')),
              SizedBox(width: 8),
              Chip(label: Text('Fashion')),
              SizedBox(width: 8),
              Chip(label: Text('Gaspet')),
              SizedBox(width: 8),
              Chip(label: Text('Accessory')),
            ],
          ),
        ),
      ],
    );
  }
}