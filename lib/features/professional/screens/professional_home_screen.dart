import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/logger_service.dart';
import '../../../models/professional_model.dart';
import '../../../providers/database_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/routes/app_router.dart';
import 'professional_main_screen.dart';
import '../../../core/config/routes.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? trend;
  final IconData icon;
  final Color backgroundColor;

  const MetricCard({
    Key? key,
    required this.title,
    required this.value,
    this.trend,
    required this.icon,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 144,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, size: 20),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (trend != null)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$trend from last month',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

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

class ReviewCard extends StatelessWidget {
  final String name;
  final String avatar;
  final double rating;
  final String review;

  const ReviewCard({
    Key? key,
    required this.name,
    required this.avatar,
    required this.rating,
    required this.review,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(20),
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
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber[500],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfessionalHomeScreen extends StatelessWidget {
  const ProfessionalHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('MMMM d, y').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        final mainScreenState = context.findAncestorStateOfType<
                            ProfessionalMainScreenState>();
                        if (mainScreenState != null) {
                          mainScreenState.showMenu(context);
                        }
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.menu, color: Colors.black),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.pink[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'ME',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.pink[700],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome back, Mike!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Here\'s what\'s happening with your business',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Metrics Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    MetricCard(
                      title: 'Today\'s Earnings',
                      value: '\$285.00',
                      trend: '+12.5%',
                      icon: Icons.attach_money,
                      backgroundColor: Colors.pink[100]!,
                    ),
                    MetricCard(
                      title: 'Total Jobs',
                      value: '6',
                      trend: '+2',
                      icon: Icons.build,
                      backgroundColor: Colors.amber[100]!,
                    ),
                    MetricCard(
                      title: 'Rating',
                      value: '4.9',
                      icon: Icons.star,
                      backgroundColor: Colors.green[100]!,
                    ),
                    MetricCard(
                      title: 'New Requests',
                      value: '8',
                      icon: Icons.message,
                      backgroundColor: Colors.blue[100]!,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Today's Schedule
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Today\'s Schedule',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          today,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const AppointmentCard(
                  title: 'Electrical Installation',
                  time: '09:00 AM - 11:00 AM',
                  client: 'Sarah Johnson',
                  status: 'In Progress',
                  avatar: 'SJ',
                ),
                const SizedBox(height: 16),
                const AppointmentCard(
                  title: 'Circuit Repair',
                  time: '02:00 PM - 04:00 PM',
                  client: 'David Chen',
                  status: 'Upcoming',
                  avatar: 'DC',
                ),
                const SizedBox(height: 16),
                const AppointmentCard(
                  title: 'Safety Inspection',
                  time: '05:00 PM - 06:00 PM',
                  client: 'Mark Wilson',
                  status: 'Upcoming',
                  avatar: 'MW',
                ),

                // Recent Reviews
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Reviews',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'View all',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const ReviewCard(
                  name: 'Sarah Johnson',
                  avatar: 'SJ',
                  rating: 5.0,
                  review:
                      '"Mike was professional, punctual, and did an excellent job with the electrical installation. Highly recommended!"',
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
