import 'package:flutter/material.dart';
import '../../../models/job_model.dart';
import '../../../models/professional_model.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final Professional? professional;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onCancel;
  final VoidCallback? onComplete;

  const JobCard({
    super.key,
    required this.job,
    this.professional,
    this.onTap,
    this.onAccept,
    this.onDecline,
    this.onCancel,
    this.onComplete,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.service.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          professional?.name ?? 'No professional assigned',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(theme),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      job.status.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    job.formattedDate,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    job.formattedTime,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              if (_showActions) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onDecline != null)
                      TextButton(
                        onPressed: onDecline,
                        child: const Text('Decline'),
                      ),
                    if (onAccept != null) ...[
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: onAccept,
                        child: const Text('Accept'),
                      ),
                    ],
                    if (onCancel != null) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: onCancel,
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        child: const Text('Cancel'),
                      ),
                    ],
                    if (onComplete != null) ...[
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: onComplete,
                        child: const Text('Complete'),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ThemeData theme) {
    switch (job.status) {
      case Job.STATUS_AWAITING_ACCEPTANCE:
        return theme.colorScheme.tertiary;
      case Job.STATUS_SCHEDULED:
        return theme.colorScheme.primary;
      case Job.STATUS_STARTED:
        return theme.colorScheme.secondary;
      case Job.STATUS_COMPLETED:
        return Colors.green;
      case Job.STATUS_CANCELLED:
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.primary;
    }
  }

  bool get _showActions =>
      onAccept != null ||
      onDecline != null ||
      onCancel != null ||
      onComplete != null;
}
