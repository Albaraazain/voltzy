import 'package:flutter/material.dart';
import '../../../core/config/routes.dart';

class AppointmentCard extends StatelessWidget {
  final String title;
  final String time;
  final String client;
  final String status;
  final String avatar;

  const AppointmentCard({
    Key? key,
    required this.title,
    required this.time,
    required this.client,
    required this.status,
    required this.avatar,
  }) : super(key: key);

  void _navigateToJobDetails(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.professionalJobDetails,
      arguments: {
        'service_type': title,
        'status': status,
        'client_name': client,
        'client_initials': avatar,
        'client_rating': '4.9', // TODO: Make dynamic
        'client_jobs': '24', // TODO: Make dynamic
        'address': '123 Main St, Boston', // TODO: Make dynamic
        'scheduled_time': time,
        'rate': '85', // TODO: Make dynamic
        'duration': '2-3 hours', // TODO: Make dynamic
        'payment_method': 'Credit Card', // TODO: Make dynamic
        'notes': '',
        'tags': <String>[], // Explicitly cast to List<String>
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToJobDetails(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Text(
                      avatar,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber[700],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
