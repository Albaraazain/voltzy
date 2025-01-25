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
        final horizontalPadding = screenWidth > 600 ? 32.0 : 24.0;
        final spacing = screenWidth > 600 ? 24.0 : 16.0;

        final itemWidth = (screenWidth -
                (horizontalPadding * 2) -
                (spacing * (crossAxisCount - 1))) /
            crossAxisCount;
        final smallItemHeight = itemWidth * 1.2; // Slightly taller than wide
        final largeItemHeight = (itemWidth * 2) + spacing;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: spacing,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome message
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge,
                      children: const [
                        TextSpan(
                          text: 'Find the perfect\n',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                        ),
                        TextSpan(
                          text: 'service for your home',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Categories grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    childAspectRatio: itemWidth / smallItemHeight,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];

                    // Calculate aspect ratio based on card size
                    double aspectRatio;
                    if (category.size == CardSize.large) {
                      aspectRatio = itemWidth / largeItemHeight;
                    } else {
                      aspectRatio = itemWidth / smallItemHeight;
                    }

                    return AspectRatio(
                      aspectRatio: aspectRatio,
                      child: ServiceCategoryCardWidget(
                        category: category,
                        onTap: () => onCategoryTap(category.id),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
