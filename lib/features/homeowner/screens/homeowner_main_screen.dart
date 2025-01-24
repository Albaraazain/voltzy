import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/homeowner_provider.dart';
import '../../common/widgets/loading_indicator.dart';

class HomeownerMainScreen extends StatefulWidget {
  const HomeownerMainScreen({super.key});

  @override
  State<HomeownerMainScreen> createState() => _HomeownerMainScreenState();
}

class _HomeownerMainScreenState extends State<HomeownerMainScreen> {
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
          'Home',
          style: AppTextStyles.h2,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () =>
                Navigator.pushNamed(context, '/homeowner/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () =>
                Navigator.pushNamed(context, '/homeowner/personal-info'),
          ),
        ],
      ),
      body: _isLoading ? const Center(child: LoadingIndicator()) : _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: 'History',
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
        return _buildHomeTab();
      case 1:
        return _buildSearchTab();
      case 2:
        return _buildHistoryTab();
      case 3:
        return _buildSettingsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHomeTab() {
    final homeowner = context.watch<DatabaseProvider>().currentHomeowner;
    if (homeowner == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Welcome back, ${homeowner.profile.name}!',
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: 24),
        // Add more widgets for the home tab
      ],
    );
  }

  Widget _buildSearchTab() {
    return const Center(child: Text('Search Tab'));
  }

  Widget _buildHistoryTab() {
    return const Center(child: Text('History Tab'));
  }

  Widget _buildSettingsTab() {
    return const Center(child: Text('Settings Tab'));
  }
}
