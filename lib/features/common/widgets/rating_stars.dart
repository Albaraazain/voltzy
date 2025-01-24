import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final bool showRating;
  final MainAxisAlignment alignment;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
    this.showRating = false,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            if (index < rating.floor()) {
              return Icon(
                Icons.star,
                size: size,
                color: color ?? AppColors.warning,
              );
            } else if (index == rating.floor() && rating % 1 != 0) {
              return Icon(
                Icons.star_half,
                size: size,
                color: color ?? AppColors.warning,
              );
            } else {
              return Icon(
                Icons.star_border,
                size: size,
                color: color ?? AppColors.warning,
              );
            }
          }),
        ),
        if (showRating) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.875,
              fontWeight: FontWeight.w500,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}
