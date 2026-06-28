import 'package:flutter/material.dart';
import '../constants/app_spacing.dart';

class CategoryFilterChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  const CategoryFilterChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selected;
          return FilterChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (_) => onSelected(category),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
