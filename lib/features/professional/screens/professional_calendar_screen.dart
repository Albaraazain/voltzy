import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/config/routes.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/schedule_provider.dart';
import '../../../models/job_model.dart';

class WeekDay extends StatelessWidget {
  final String day;
  final String date;
  final bool isActive;
  final VoidCallback onTap;

  const WeekDay({
    super.key,
    required this.day,
    required this.date,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
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
  final String homeownerId;

  const TimeSlot({
    super.key,
    required this.time,
    required this.title,
    required this.client,
    required this.location,
    required this.status,
    required this.backgroundColor,
    required this.homeownerId,
  });

  void _navigateToJobDetails(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.professionalJobDetails,
      arguments: {
        'service_type': title,
        'status': status,
        'client_name': client,
        'client_initials': client.split(' ').map((e) => e[0]).take(2).join(''),
        'client_rating': '4.9', // TODO: Make dynamic
        'client_jobs': '24', // TODO: Make dynamic
        'address': location,
        'scheduled_time': time,
        'rate': '85', // TODO: Make dynamic
        'duration': '2-3 hours', // TODO: Make dynamic
        'payment_method': 'Credit Card', // TODO: Make dynamic
        'notes': '',
        'tags': <String>[], // Explicitly cast to List<String>
      },
    );
  }

  void _navigateToClientNotes(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.clientProfileNotes,
      arguments: {
        'homeownerId': homeownerId,
        'professionalId': Provider.of<DatabaseProvider>(context, listen: false)
            .currentProfessional
            ?.id,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToJobDetails(context),
      child: Container(
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
                GestureDetector(
                  onTap: () => _navigateToClientNotes(context),
                  child: Text(
                    client,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      decoration: TextDecoration.underline,
                    ),
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
      ),
    );
  }
}

class ProfessionalCalendarScreen extends StatefulWidget {
  const ProfessionalCalendarScreen({super.key});

  @override
  State<ProfessionalCalendarScreen> createState() =>
      _ProfessionalCalendarScreenState();
}

class _ProfessionalCalendarScreenState
    extends State<ProfessionalCalendarScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _weekDates;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _updateWeekDates();
    _loadAppointments();
  }

  void _updateWeekDates() {
    final now = DateTime.now();
    _weekDates = List.generate(7, (index) {
      return now.add(Duration(days: index));
    });
  }

  void _loadAppointments() {
    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);
    scheduleProvider.loadAppointments(date: _selectedDate);
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadAppointments();
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<ScheduleProvider>(
          builder: (context, scheduleProvider, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calendar',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _weekDates.map((date) {
                        return WeekDay(
                          day: _getWeekdayName(date.weekday),
                          date: date.day.toString(),
                          isActive: date.year == _selectedDate.year &&
                              date.month == _selectedDate.month &&
                              date.day == _selectedDate.day,
                          onTap: () => _onDateSelected(date),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    if (scheduleProvider.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (scheduleProvider.error != null)
                      Center(
                        child: Text(
                          'Error: ${scheduleProvider.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    else if (scheduleProvider.appointments.isEmpty)
                      const Center(
                        child: Text(
                          'No appointments for this day',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    else
                      ...scheduleProvider.appointments.map((job) => TimeSlot(
                            time: job.formattedTime,
                            title: job.title,
                            client:
                                job.homeowner?.profile.name ?? 'Unknown Client',
                            location: job.homeowner?.address ?? 'No location',
                            status: job.status,
                            backgroundColor: scheduleProvider
                                .getAppointmentColor(job.status),
                            homeownerId: job.homeownerId,
                          )),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
