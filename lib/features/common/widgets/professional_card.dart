import 'package:flutter/material.dart';
import '../../../models/professional_model.dart';
import 'rating_bar.dart';

class ProfessionalCard extends StatelessWidget {
  final Professional professional;
  final VoidCallback? onTap;
  final bool showDistance;
  final bool showAvailability;
  final bool showRating;

  const ProfessionalCard({
    super.key,
    required this.professional,
    this.onTap,
    this.showDistance = false,
    this.showAvailability = true,
    this.showRating = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: professional.profileImage != null
                    ? NetworkImage(professional.profileImage!)
                    : null,
                child: professional.profileImage == null
                    ? Icon(
                        Icons.person,
                        size: 32,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            professional.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (showAvailability)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: professional.isAvailable
                                  ? Colors.green
                                  : theme.colorScheme.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              professional.isAvailable
                                  ? 'Available'
                                  : 'Unavailable',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (showRating && professional.rating > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          RatingBar(
                            rating: professional.rating,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${professional.reviewCount})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (professional.specialties.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: professional.specialties.map((specialty) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              specialty,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    if (showDistance && professional.location != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${professional.location!.address ?? 'Unknown location'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
