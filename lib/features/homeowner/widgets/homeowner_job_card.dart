import 'package:flutter/material.dart';
import '../../../models/job_model.dart';
import '../../../core/constants/colors.dart';

class HomeownerJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final VoidCallback? onReview;
  final VoidCallback? onViewProfessional;

  const HomeownerJobCard({
    super.key,
    required this.job,
    this.onTap,
    this.onCancel,
    this.onReschedule,
    this.onReview,
    this.onViewProfessional,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(job.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      job.status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
              if (job.professional != null) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: onViewProfessional,
                  child: Row(
                    children: [
                      const Icon(Icons.handyman_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        job.professional?.profile?.name ??
                            'Unknown Professional',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                      ...[
                        const SizedBox(width: 8),
                        Icon(Icons.star, size: 16, color: Colors.amber[700]),
                        const SizedBox(width: 2),
                        Text(
                          (job.professional?.rating ?? 0.0).toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    job.formattedDate,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time_outlined, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    job.formattedTime,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.attach_money_outlined, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '\$${job.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              if (job.locationLat != null && job.locationLng != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Location provided',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
              if (job.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  job.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (_shouldShowActions) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: _buildActionButtons(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool get _shouldShowActions {
    return onCancel != null || onReschedule != null || onReview != null;
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final List<Widget> buttons = [];

    if (job.status == Job.STATUS_SCHEDULED ||
        job.status == Job.STATUS_STARTED) {
      if (onReschedule != null) {
        buttons.add(
          ElevatedButton.icon(
            onPressed: onReschedule,
            icon: const Icon(Icons.schedule),
            label: const Text('Reschedule'),
          ),
        );
        buttons.add(const SizedBox(width: 8));
      }
      if (onCancel != null) {
        buttons.add(
          TextButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Cancel'),
          ),
        );
      }
    } else if (job.status == Job.STATUS_COMPLETED && onReview != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: onReview,
          icon: const Icon(Icons.rate_review_outlined),
          label: const Text('Leave Review'),
        ),
      );
    }

    return buttons;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case Job.STATUS_AWAITING_ACCEPTANCE:
        return Colors.orange;
      case Job.STATUS_SCHEDULED:
        return Colors.blue;
      case Job.STATUS_STARTED:
        return Colors.purple;
      case Job.STATUS_COMPLETED:
        return Colors.green;
      case Job.STATUS_CANCELLED:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
