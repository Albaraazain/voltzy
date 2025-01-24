import 'package:flutter/material.dart';
import '../../../models/job_model.dart';

class JobCard extends StatelessWidget {
  final Job job;

  const JobCard({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(job.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job.description),
            const SizedBox(height: 4),
            Text(
              'Status: ${_getStatusText(job.status)}',
              style: TextStyle(
                color: _getStatusColor(job.status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Text(
          '\$${job.price.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/professional/job-details',
            arguments: job,
          );
        },
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case Job.STATUS_AWAITING_ACCEPTANCE:
        return 'Awaiting Acceptance';
      case Job.STATUS_SCHEDULED:
        return 'Scheduled';
      case Job.STATUS_STARTED:
        return 'Started';
      case Job.STATUS_COMPLETED:
        return 'Completed';
      case Job.STATUS_CANCELLED:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case Job.STATUS_AWAITING_ACCEPTANCE:
        return Colors.orange;
      case Job.STATUS_SCHEDULED:
        return Colors.blue;
      case Job.STATUS_STARTED:
        return Colors.green;
      case Job.STATUS_COMPLETED:
        return Colors.purple;
      case Job.STATUS_CANCELLED:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
