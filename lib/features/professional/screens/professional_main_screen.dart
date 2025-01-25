import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/professional_stats_provider.dart';
import '../../common/widgets/loading_indicator.dart';
import '../../common/widgets/custom_button.dart';

class ProfessionalMainScreen extends StatefulWidget {
  const ProfessionalMainScreen({super.key});

  @override
  State<ProfessionalMainScreen> createState() => _ProfessionalMainScreenState();
}

class _ProfessionalMainScreenState extends State<ProfessionalMainScreen> {
  bool _isLoading = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final databaseProvider = context.read<DatabaseProvider>();
      await databaseProvider.loadInitialData();

      final statsProvider = context.read<ProfessionalStatsProvider>();
      final professional = databaseProvider.professionals.firstOrNull;
      if (professional != null) {
        await statsProvider.loadStats(professional.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Dashboard',
          style: AppTextStyles.h2,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, '/professional/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () =>
                Navigator.pushNamed(context, '/professional/edit-profile'),
          ),
        ],
      ),
      body: _isLoading ? const Center(child: LoadingIndicator()) : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildJobsTab();
      case 2:
        return _buildScheduleTab();
      case 3:
        return _buildSettingsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDashboardTab() {
    final professional =
        context.watch<DatabaseProvider>().professionals.firstOrNull;
    final stats = context.watch<ProfessionalStatsProvider>().stats;

    if (professional == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Welcome back, ${professional.profile.name}!',
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: 24),

        // Stats Cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Earnings',
                value: '\$${stats.totalEarnings.toStringAsFixed(2)}',
                icon: Icons.attach_money,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Jobs Completed',
                value: stats.completedJobs.toString(),
                icon: Icons.check_circle_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Active Jobs',
                value: (stats.totalJobs -
                        stats.completedJobs -
                        stats.cancelledJobs)
                    .toString(),
                icon: Icons.work_outline,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Rating',
                value: '${stats.averageRating.toStringAsFixed(1)} ⭐',
                icon: Icons.star_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Quick Actions
        Text('Quick Actions', style: AppTextStyles.h3),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/professional/availability'),
                text: 'Set Availability',
                type: ButtonType.secondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomButton(
                onPressed: () => Navigator.pushNamed(
                    context, '/professional/manage-services'),
                text: 'Manage Services',
                type: ButtonType.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.h3,
          ),
        ],
      ),
    );
  }

  Widget _buildJobsTab() {
    return const Center(child: Text('Jobs Tab'));
  }

  Widget _buildScheduleTab() {
    return const Center(child: Text('Schedule Tab'));
  }

  Widget _buildSettingsTab() {
    return const Center(child: Text('Settings Tab'));
  }
}
