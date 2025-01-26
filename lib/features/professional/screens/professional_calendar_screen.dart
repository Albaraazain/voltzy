import 'package:flutter/material.dart';

class WeekDay extends StatelessWidget {
  final String day;
  final String date;
  final bool isActive;

  const WeekDay({
    Key? key,
    required this.day,
    required this.date,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 14,
            color: isActive ? Colors.pink[500] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? Colors.pink[100] : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              date,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? Colors.pink[500] : Colors.grey[600],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TimeSlot extends StatelessWidget {
  final String time;
  final String title;
  final String client;
  final String location;
  final String status;
  final Color backgroundColor;

  const TimeSlot({
    Key? key,
    required this.time,
    required this.title,
    required this.client,
    required this.location,
    required this.status,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                client,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                location,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfessionalCalendarScreen extends StatelessWidget {
  const ProfessionalCalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    Row(
                      children: [
                        Container(
                          height: 4,
                          width: 24,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.pink[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'January 2025',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.pink[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Schedule',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Week Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.chevron_left, color: Colors.grey[400]),
                    const Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          WeekDay(day: 'Mon', date: '22'),
                          WeekDay(day: 'Tue', date: '23'),
                          WeekDay(day: 'Wed', date: '24'),
                          WeekDay(day: 'Thu', date: '25'),
                          WeekDay(day: 'Fri', date: '26', isActive: true),
                          WeekDay(day: 'Sat', date: '27'),
                          WeekDay(day: 'Sun', date: '28'),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
                const SizedBox(height: 32),

                // Schedule Timeline
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Morning',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TimeSlot(
                      time: '09:00 AM - 11:00 AM',
                      title: 'Electrical Installation',
                      client: 'Sarah Johnson',
                      location: '123 Main St, Boston',
                      status: 'In Progress',
                      backgroundColor: Colors.pink[100]!,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Afternoon',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TimeSlot(
                      time: '02:00 PM - 04:00 PM',
                      title: 'Circuit Repair',
                      client: 'David Chen',
                      location: '456 Park Ave, Boston',
                      status: 'Upcoming',
                      backgroundColor: Colors.amber[100]!,
                    ),
                    TimeSlot(
                      time: '05:00 PM - 06:00 PM',
                      title: 'Safety Inspection',
                      client: 'Mark Wilson',
                      location: '789 Oak St, Boston',
                      status: 'Upcoming',
                      backgroundColor: Colors.blue[100]!,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Actions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Block Time Off',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Set Availability',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
