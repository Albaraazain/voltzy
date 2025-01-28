import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../providers/job_provider.dart';
import '../../../models/job_model.dart';
import '../../../models/base_service_model.dart';

class JobCard extends StatelessWidget {
  final String title;
  final String professional;
  final String date;
  final String time;
  final String status;
  final String image;
  final VoidCallback? onTap;

  const JobCard({
    super.key,
    required this.title,
    required this.professional,
    required this.date,
    required this.time,
    required this.status,
    required this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.pink.shade100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  image,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.pink.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              professional,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: status == 'In Progress'
                              ? Colors.pink.shade100
                              : status == 'Scheduled'
                                  ? Colors.amber.shade100
                                  : status == 'Completed'
                                      ? Colors.green.shade100
                                      : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 12,
                            color: status == 'In Progress'
                                ? Colors.pink.shade700
                                : status == 'Scheduled'
                                    ? Colors.amber.shade700
                                    : status == 'Completed'
                                        ? Colors.green.shade700
                                        : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.calendar,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        LucideIcons.chevronRight,
                        size: 20,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeownerJobsScreen extends StatefulWidget {
  const HomeownerJobsScreen({super.key});

  @override
  State<HomeownerJobsScreen> createState() => _HomeownerJobsScreenState();
}

class _HomeownerJobsScreenState extends State<HomeownerJobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final jobProvider = context.read<JobProvider>();
    await jobProvider.loadJobs(_selectedFilter);
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, min(2, name.length)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.chevronLeft, size: 24),
                        const SizedBox(width: 12),
                        Container(
                          height: 2,
                          width: 24,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'My Services',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Search and Filter
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.search,
                              size: 20,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Search services...',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Icon(
                        LucideIcons.filter,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Status Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        selected: _selectedFilter == 'all',
                        label: const Text('All Services'),
                        onSelected: (selected) {
                          setState(() => _selectedFilter = 'all');
                          _loadJobs();
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: Colors.pink.shade100,
                        labelStyle: TextStyle(
                          color: _selectedFilter == 'all'
                              ? Colors.pink.shade700
                              : Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        showCheckmark: false,
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        selected: _selectedFilter == 'active',
                        label: const Text('Active'),
                        onSelected: (selected) {
                          setState(() => _selectedFilter = 'active');
                          _loadJobs();
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: Colors.pink.shade100,
                        labelStyle: TextStyle(
                          color: _selectedFilter == 'active'
                              ? Colors.pink.shade700
                              : Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        showCheckmark: false,
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        selected: _selectedFilter == 'completed',
                        label: const Text('Completed'),
                        onSelected: (selected) {
                          setState(() => _selectedFilter = 'completed');
                          _loadJobs();
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor: Colors.pink.shade100,
                        labelStyle: TextStyle(
                          color: _selectedFilter == 'completed'
                              ? Colors.pink.shade700
                              : Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        showCheckmark: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Current Jobs
                Consumer<JobProvider>(
                  builder: (context, jobProvider, child) {
                    if (jobProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final currentJobs = jobProvider.jobs
                        .where((job) =>
                            job.status == 'in_progress' ||
                            job.status == 'scheduled' ||
                            job.status == 'awaiting_acceptance' ||
                            job.status == 'accepted')
                        .toList();

                    if (currentJobs.isEmpty) {
                      return const Center(
                        child: Text('No current services'),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Services',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...currentJobs.map((job) {
                          final professional = job.professional;
                          final professionalName = professional?.profile?.name;
                          return JobCard(
                            title: job.title,
                            professional: professionalName ?? 'Not Assigned',
                            date: _formatDate(job.date),
                            time: _formatTime(job.date),
                            status: _getStatusText(job.status),
                            image: _getInitials(professionalName ?? 'NA'),
                            onTap: () {
                              // Navigate to job details
                            },
                          );
                        }),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Past Jobs
                Consumer<JobProvider>(
                  builder: (context, jobProvider, child) {
                    final pastJobs = jobProvider.jobs
                        .where((job) => job.status == 'completed')
                        .toList();

                    if (pastJobs.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Past Services',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to all past services
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'View All',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    LucideIcons.chevronRight,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...pastJobs.take(2).map((job) {
                          final professional = job.professional;
                          final professionalName = professional?.profile?.name;
                          return JobCard(
                            title: job.title,
                            professional: professionalName ?? 'Not Assigned',
                            date: _formatDate(job.date),
                            time: _formatTime(job.date),
                            status: _getStatusText(job.status),
                            image: _getInitials(professionalName ?? 'NA'),
                            onTap: () {
                              // Navigate to job details
                            },
                          );
                        }),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Maintenance Reminder
                Consumer<JobProvider>(
                  builder: (context, jobProvider, child) {
                    final upcomingMaintenance = jobProvider.jobs.firstWhere(
                      (job) =>
                          job.maintenance_due_date != null &&
                          job.maintenance_due_date!.isAfter(DateTime.now()),
                      orElse: () => Job(
                        id: '',
                        title: '',
                        description: '',
                        status: '',
                        date: DateTime.now(),
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                        homeownerId: '',
                        verificationStatus: Job.VERIFICATION_STATUS_PENDING,
                        paymentStatus: Job.PAYMENT_STATUS_PENDING,
                        requestType: Job.REQUEST_TYPE_DIRECT,
                        price: 0,
                        service: BaseService(
                          id: '',
                          categoryId: '',
                          name: '',
                          description: '',
                          basePrice: 0,
                        ),
                      ),
                    );

                    if (upcomingMaintenance.id.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.pink.shade50,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Maintenance Reminder',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Annual electrical safety check due next month',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Schedule maintenance
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.pink.shade500,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            child: const Text(
                              'Schedule',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    if (date.difference(DateTime.now()).inDays == 0) {
      return 'Today';
    }
    if (date.difference(DateTime.now()).inDays == 1) {
      return 'Tomorrow';
    }
    return '${date.day} ${_getMonthName(date.month)}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'in_progress':
        return 'In Progress';
      case 'scheduled':
        return 'Scheduled';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }
}
