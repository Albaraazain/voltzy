import 'package:flutter/material.dart';
import '../../../models/job_model.dart';
import '../../../core/constants/colors.dart';

class ProfessionalJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const ProfessionalJobCard({
    super.key,
    required this.job,
    this.onTap,
    this.onAccept,
    this.onDecline,
    this.onStart,
    this.onComplete,
    this.onCancel,
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
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    job.homeowner?.profile.name ?? 'Unknown Client',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
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
                        'Location available',
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
    return onAccept != null ||
        onDecline != null ||
        onStart != null ||
        onComplete != null ||
        onCancel != null;
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final List<Widget> buttons = [];

    if (job.status == Job.STATUS_AWAITING_ACCEPTANCE) {
      if (onAccept != null) {
        buttons.add(
          ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Accept'),
          ),
        );
        buttons.add(const SizedBox(width: 8));
      }
      if (onDecline != null) {
        buttons.add(
          TextButton(
            onPressed: onDecline,
            child: const Text('Decline'),
          ),
        );
      }
    } else if (job.status == Job.STATUS_SCHEDULED) {
      if (onStart != null) {
        buttons.add(
          ElevatedButton(
            onPressed: onStart,
            child: const Text('Start Job'),
          ),
        );
        buttons.add(const SizedBox(width: 8));
      }
      if (onCancel != null) {
        buttons.add(
          TextButton(
            onPressed: onCancel,
            child: const Text('Cancel'),
          ),
        );
      }
    } else if (job.status == Job.STATUS_STARTED) {
      if (onComplete != null) {
        buttons.add(
          ElevatedButton(
            onPressed: onComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Complete'),
          ),
        );
        buttons.add(const SizedBox(width: 8));
      }
      if (onCancel != null) {
        buttons.add(
          TextButton(
            onPressed: onCancel,
            child: const Text('Cancel'),
          ),
        );
      }
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
