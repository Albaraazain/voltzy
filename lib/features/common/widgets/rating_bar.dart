import 'package:flutter/material.dart';

class RatingBar extends StatelessWidget {
  final double rating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<double>? onRatingChanged;

  const RatingBar({
    super.key,
    required this.rating,
    this.size = 24.0,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: onRatingChanged != null
              ? () => onRatingChanged?.call(index + 1.0)
              : null,
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: index < rating ? activeColor : inactiveColor,
            size: size,
          ),
        );
      }),
    );
  }
}
