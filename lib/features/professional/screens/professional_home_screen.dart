import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/metric_card.dart';
import '../widgets/appointment_card.dart';
import '../widgets/review_card.dart';
import 'professional_main_screen.dart';

class ProfessionalHomeScreen extends StatefulWidget {
  const ProfessionalHomeScreen({super.key});

  @override
  State<ProfessionalHomeScreen> createState() => _ProfessionalHomeScreenState();
}

class _ProfessionalHomeScreenState extends State<ProfessionalHomeScreen> {
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
                        final mainScreen =
                            context.findAncestorWidgetOfExactType<
                                ProfessionalMainScreen>();
                        if (mainScreen != null) {
                          final mainScreenState =
                              context.findAncestorStateOfType<
                                  State<ProfessionalMainScreen>>();
                          if (mainScreenState != null) {
                            (mainScreenState as dynamic).showMenu(context);
                          }
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
