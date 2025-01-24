import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/professional_stats_provider.dart';
import '../../../providers/job_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../models/professional_stats.dart';
import '../../../models/job_model.dart';
import '../../../core/utils/api_response.dart';
import '../../common/widgets/loading_indicator.dart';
import '../../../core/services/logger_service.dart';
import '../../common/widgets/job_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Map<String, String> _periodLabels = {
    'week': 'This Week',
    'month': 'This Month',
    'year': 'This Year',
  };

  bool _isInitialLoad = true;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    context.read<NotificationProvider>().stopListeningToNotifications();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    try {
      setState(() {
        _isRetrying = true;
      });

      final dbProvider = context.read<DatabaseProvider>();
      await dbProvider.loadInitialData();

      // Load jobs and stats
      await context.read<JobProvider>().loadJobs(null);
      final professional = dbProvider.professionals.firstOrNull;
      if (professional != null) {
        await context
            .read<ProfessionalStatsProvider>()
            .loadStats(professional.id);
      }

      if (mounted) {
        setState(() {
          _isInitialLoad = false;
          _isRetrying = false;
        });
      }
    } catch (e) {
      LoggerService.error('Error loading dashboard data', e);
      if (mounted) {
        setState(() {
          _isInitialLoad = false;
          _isRetrying = false;
        });
      }
    }
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.h3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsChart(ProfessionalStats stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Earnings', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildEarningsData(stats),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsData(ProfessionalStats stats) {
    return Center(
      child: Text(
        '\$${stats.weeklyEarnings.toStringAsFixed(2)}',
        style: AppTextStyles.h1.copyWith(color: Colors.green),
      ),
    );
  }

  Widget _buildRecentJobs(List<Job> jobs) {
    if (jobs.isEmpty) {
      return const Center(
        child: Text('No recent jobs'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return JobCard(job: job);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = context.watch<JobProvider>();
    final statsProvider = context.watch<ProfessionalStatsProvider>();
    final jobs = jobProvider.jobs;
    final stats = statsProvider.stats;

    if (_isInitialLoad || _isRetrying) {
      return const Scaffold(
        body: Center(child: LoadingIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/professional/notifications');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatsCard(
                    title: 'Total Jobs',
                    value: stats.totalJobs.toString(),
                    icon: Icons.work,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatsCard(
                    title: 'Completed',
                    value: stats.completedJobs.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Earnings Chart
            _buildEarningsChart(stats),
            const SizedBox(height: 24),
            // Recent Jobs
            Text('Recent Jobs', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            _buildRecentJobs(jobs),
          ],
        ),
      ),
    );
  }
}
