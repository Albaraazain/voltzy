import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/direct_request_model.dart';
import '../../../providers/direct_request_provider.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/date_time_utils.dart';

class IncomingRequestsScreen extends StatefulWidget {
  const IncomingRequestsScreen({super.key});

  @override
  State<IncomingRequestsScreen> createState() => _IncomingRequestsScreenState();
}

class _IncomingRequestsScreenState extends State<IncomingRequestsScreen> {
  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    await context.read<DirectRequestProvider>().loadProfessionalRequests();
  }

  Future<void> _acceptRequest(String requestId) async {
    try {
      await context.read<DirectRequestProvider>().acceptRequest(requestId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request accepted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept request: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _declineRequest(String requestId) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline Request'),
        content: TextField(
          decoration: const InputDecoration(
            hintText: 'Enter reason for declining',
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('Not available'),
            child: const Text('Decline'),
          ),
        ],
      ),
    );

    if (reason != null) {
      try {
        await context
            .read<DirectRequestProvider>()
            .declineRequest(requestId, reason);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request declined successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to decline request: ${e.toString()}')),
          );
        }
      }
    }
  }

  Widget _buildRequestList(List<DirectRequest> requests) {
    if (requests.isEmpty) {
      return const Center(
        child: Text('No requests found'),
      );
    }

    return ListView.builder(
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (request.homeowner != null) ...[
                  Text(
                    'From: ${request.homeowner!.profile.name}',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  request.message,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Scheduled Date: ${formatDate(request.date)}',
                  style: AppTextStyles.bodyMedium,
                ),
                Text(
                  'Scheduled Time: ${request.time}',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _declineRequest(request.id),
                      child: const Text('Decline'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _acceptRequest(request.id),
                      child: const Text('Accept'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Incoming Requests'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Accepted'),
              Tab(text: 'In Progress'),
            ],
          ),
        ),
        body: Consumer<DirectRequestProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${provider.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadRequests,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return TabBarView(
              children: [
                _buildRequestList(provider.pendingRequests),
                _buildRequestList(provider.acceptedRequests),
                _buildRequestList(provider.inProgressRequests),
              ],
            );
          },
        ),
      ),
    );
  }
}

enum RequestType {
  pending,
  accepted,
  inProgress,
  completed,
  cancelled,
}
