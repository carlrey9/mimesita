import 'package:flutter/material.dart';
import '../constants/categories.dart';
import '../constants/app_colors.dart';

class CategoryChips extends StatelessWidget {
  final PlaceCategory selectedCategory;
  final ValueChanged<PlaceCategory> onCategorySelected;

  const CategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: CategoryHelper.allCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final catInfo = CategoryHelper.allCategories[index];
          final isSelected = catInfo.category == selectedCategory;

          return FilterChip(
            selected: isSelected,
            showCheckmark: false,
            avatar: Text(
              catInfo.emoji,
              style: const TextStyle(fontSize: 14),
            ),
            label: Text(
              catInfo.label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
            backgroundColor: Colors.white,
            selectedColor: AppColors.primary,
            side: BorderSide(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            onSelected: (_) => onCategorySelected(catInfo.category),
          );
        },
      ),
    );
  }
}
