import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int? count;
  final double size;
  final bool showNumber;

  const StarRating({
    super.key,
    required this.rating,
    this.count,
    this.size = 14,
    this.showNumber = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: size, color: AppColors.starGold),
        if (showNumber) ...[
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.9,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
        if (count != null) ...[
          const SizedBox(width: 2),
          Text(
            '($count)',
            style: TextStyle(
              fontSize: size * 0.8,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
