import 'package:flutter/material.dart';

enum CardSize {
  small, // 1x1
  medium, // 2x1
  large // 2x2
}

class ServiceCategoryCard {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int serviceCount;
  final double minPrice;
  final double maxPrice;
  final CardSize size;
  final Color accentColor;

  const ServiceCategoryCard({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.serviceCount,
    required this.minPrice,
    required this.maxPrice,
    required this.size,
    required this.accentColor,
  });

  // Helper method to get the grid item span based on card size
  int get columnSpan {
    switch (size) {
      case CardSize.small:
        return 1;
      case CardSize.medium:
      case CardSize.large:
        return 2;
    }
  }

  int get rowSpan {
    switch (size) {
      case CardSize.small:
      case CardSize.medium:
        return 1;
      case CardSize.large:
        return 2;
    }
  }
}
