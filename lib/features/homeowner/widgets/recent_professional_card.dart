import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';

class RecentProfessionalCard extends StatelessWidget {
  final String name;
  final double? rating;
  final String specialty;
  final int jobsCompleted;
  final bool isVerified;

  const RecentProfessionalCard({
    super.key,
    required this.name,
    required this.rating,
    required this.specialty,
    required this.jobsCompleted,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                color: AppColors.accent,
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.h3,
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: Colors.blue,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  specialty,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (rating != null) ...[
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating!.toString(),
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    const Icon(
                      Icons.work_outline,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$jobsCompleted jobs',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Navigate to professional profile
            },
            icon: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
