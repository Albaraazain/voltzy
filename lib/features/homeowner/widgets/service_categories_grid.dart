import 'package:flutter/material.dart';
import '../models/service_category_card.dart';
import 'service_category_card_widget.dart';

class ServiceCategoriesGrid extends StatelessWidget {
  final List<ServiceCategoryCard> categories;
  final Function(String categoryId) onCategoryTap;

  const ServiceCategoriesGrid({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the ideal item width based on screen size
        final screenWidth = constraints.maxWidth;
        final crossAxisCount = screenWidth > 600 ? 4 : 2;
        final itemWidth =
            (screenWidth - (crossAxisCount + 1) * 16) / crossAxisCount;
        final smallItemHeight = itemWidth;
        final largeItemHeight = (itemWidth * 2) + 16; // Including gap

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];

            // Calculate the size based on category's span
            final width =
                category.columnSpan == 1 ? itemWidth : itemWidth * 2 + 16;
            final height =
                category.rowSpan == 1 ? smallItemHeight : largeItemHeight;
            final aspectRatio = width / height;

            return AspectRatio(
              aspectRatio: aspectRatio,
              child: ServiceCategoryCardWidget(
                category: category,
                onTap: () => onCategoryTap(category.id),
              ),
            );
          },
        );
      },
    );
  }
}
