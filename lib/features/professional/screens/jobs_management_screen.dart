import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/job_provider.dart';
import '../../../models/job_model.dart';
import '../../common/widgets/loading_indicator.dart';

class JobsManagementScreen extends StatefulWidget {
  const JobsManagementScreen({super.key});

  @override
  State<JobsManagementScreen> createState() => _JobsManagementScreenState();
}

class _JobsManagementScreenState extends State<JobsManagementScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().loadJobs('all');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs Management'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
              context.read<JobProvider>().loadJobs(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Jobs'),
              ),
              PopupMenuItem(
                value: Job.STATUS_STARTED,
                child: const Text('Active Jobs'),
              ),
              PopupMenuItem(
                value: Job.STATUS_COMPLETED,
                child: const Text('Completed Jobs'),
              ),
              PopupMenuItem(
                value: Job.STATUS_CANCELLED,
                child: const Text('Cancelled Jobs'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<JobProvider>(
        builder: (context, jobProvider, child) {
          if (jobProvider.isLoading) {
            return const LoadingIndicator();
          }

          if (jobProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(jobProvider.error!),
                  TextButton(
                    onPressed: () => jobProvider.loadJobs(_selectedFilter),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (jobProvider.jobs.isEmpty) {
            return Center(
              child: Text(
                'No jobs found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobProvider.jobs.length,
            itemBuilder: (context, index) {
              final job = jobProvider.jobs[index];
              return _JobCard(
                job: job,
                onTap: () {
                  Navigator.pushNamed(context, '/job-details', arguments: job);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;

  const _JobCard({
    required this.job,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${job.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  Text(
                    'Scheduled for ${_formatDate(job.date)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              if (_showActionButtons())
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: _buildActionButtons(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    switch (job.status) {
      case Job.STATUS_AWAITING_ACCEPTANCE:
        color = Colors.orange;
        break;
      case Job.STATUS_SCHEDULED:
        color = Colors.blue;
        break;
      case Job.STATUS_STARTED:
        color = Colors.green;
        break;
      case Job.STATUS_COMPLETED:
        color = Colors.purple;
        break;
      case Job.STATUS_CANCELLED:
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        _getStatusText(job.status),
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
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

  bool _showActionButtons() {
    return job.status == Job.STATUS_AWAITING_ACCEPTANCE ||
        job.status == Job.STATUS_SCHEDULED ||
        job.status == Job.STATUS_STARTED;
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final List<Widget> buttons = [];

    switch (job.status) {
      case Job.STATUS_AWAITING_ACCEPTANCE:
        buttons.addAll([
          TextButton(
            onPressed: () {
              // TODO: Implement decline action
            },
            child: const Text('Decline'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement accept action
            },
            child: const Text('Accept'),
          ),
        ]);
        break;
      case Job.STATUS_SCHEDULED:
        buttons.add(
          ElevatedButton(
            onPressed: () {
              // TODO: Implement start action
            },
            child: const Text('Start Job'),
          ),
        );
        break;
      case Job.STATUS_STARTED:
        buttons.add(
          ElevatedButton(
            onPressed: () {
              // TODO: Implement complete action
            },
            child: const Text('Complete Job'),
          ),
        );
        break;
    }

    return buttons;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
