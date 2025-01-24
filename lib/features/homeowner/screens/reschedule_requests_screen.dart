import 'package:flutter/material.dart';
import '../../../models/reschedule_request_model.dart';
import '../../../providers/schedule_provider.dart';
import 'package:provider/provider.dart';

class RescheduleRequestsScreen extends StatelessWidget {
  const RescheduleRequestsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reschedule Requests'),
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, child) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final allRequests = [
            ...provider.pendingRescheduleRequests,
            ...provider.acceptedRescheduleRequests,
            ...provider.declinedRescheduleRequests,
          ];

          if (allRequests.isEmpty) {
            return const Center(
              child: Text('No reschedule requests'),
            );
          }

          return ListView.builder(
            itemCount: allRequests.length,
            itemBuilder: (context, index) {
              final request = allRequests[index];
              return _buildRequestCard(context, request);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, RescheduleRequest request) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job: ${request.jobId}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Original Date: ${request.originalDate} ${request.originalTime}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Proposed Date: ${request.proposedDate} ${request.proposedTime}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Status: ${request.status}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (request.reason != null) ...[
              const SizedBox(height: 8),
              Text(
                'Reason: ${request.reason}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (request.status == RescheduleRequest.STATUS_PENDING) ...[
                  TextButton(
                    onPressed: () => _handleAccept(context, request),
                    child: const Text('Accept'),
                  ),
                  TextButton(
                    onPressed: () => _handleDecline(context, request),
                    child: const Text('Decline'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAccept(
      BuildContext context, RescheduleRequest request) async {
    try {
      await context.read<ScheduleProvider>().respondToRescheduleRequest(
            requestId: request.id,
            status: RescheduleRequest.STATUS_ACCEPTED,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request accepted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accepting request: $e')),
        );
      }
    }
  }

  Future<void> _handleDecline(
      BuildContext context, RescheduleRequest request) async {
    try {
      await context.read<ScheduleProvider>().respondToRescheduleRequest(
            requestId: request.id,
            status: RescheduleRequest.STATUS_DECLINED,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request declined')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error declining request: $e')),
        );
      }
    }
  }
}
