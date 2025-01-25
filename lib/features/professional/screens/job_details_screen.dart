import 'package:flutter/material.dart';
import '../../../models/job_model.dart';
import '../../../core/constants/colors.dart';

class JobDetailsScreen extends StatelessWidget {
  final Job job;

  const JobDetailsScreen({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Service Details',
              [
                _buildDetailRow('Title', job.title),
                _buildDetailRow('Service', job.service.name),
                _buildDetailRow('Status', job.status),
                _buildDetailRow('Date', job.date.toString()),
                _buildDetailRow('Price', '\$${job.price.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              'Client Information',
              [
                _buildDetailRow(
                    'Client', job.homeowner?.profile.name ?? 'Unknown'),
                if (job.locationLat != null && job.locationLng != null)
                  _buildDetailRow(
                      'Location', '${job.locationLat}, ${job.locationLng}'),
              ],
            ),
            if (job.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection(
                context,
                'Description',
                [Text(job.description)],
              ),
            ],
            if (job.notes != null) ...[
              const SizedBox(height: 16),
              _buildSection(
                context,
                'Notes',
                [Text(job.notes!)],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
