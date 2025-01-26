import 'package:flutter/material.dart';
import '../../../core/config/routes.dart';

class JobCard extends StatelessWidget {
  final String serviceType;
  final String clientName;
  final String clientInitials;
  final String status;
  final String scheduledTime;
  final String address;
  final String rate;
  final String duration;
  final String? notes;
  final List<String>? tags;
  final VoidCallback? onTap;

  const JobCard({
    Key? key,
    required this.serviceType,
    required this.clientName,
    required this.clientInitials,
    required this.status,
    required this.scheduledTime,
    required this.address,
    required this.rate,
    required this.duration,
    this.notes,
    this.tags,
    this.onTap,
  }) : super(key: key);

  void _navigateToJobDetails(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.professionalJobDetails,
      arguments: {
        'service_type': serviceType,
        'status': status,
        'client_name': clientName,
        'client_initials': clientInitials,
        'client_rating': '4.9', // TODO: Make dynamic
        'client_jobs': '24', // TODO: Make dynamic
        'address': address,
        'scheduled_time': scheduledTime,
        'rate': rate,
        'duration': duration,
        'payment_method': 'Credit Card', // TODO: Make dynamic
        'notes': notes,
        'tags': tags ?? [],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToJobDetails(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceType,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      clientName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  scheduledTime,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return Colors.pink.shade700;
      case 'Scheduled':
        return Colors.amber.shade700;
      default:
        return Colors.grey.shade600;
    }
  }
}
