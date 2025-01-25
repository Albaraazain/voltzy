import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../../common/widgets/loading_indicator.dart';
import '../models/service_category_card.dart';
import '../widgets/service_categories_grid.dart';

class HomeownerMainScreen extends StatefulWidget {
  const HomeownerMainScreen({super.key});

  @override
  State<HomeownerMainScreen> createState() => _HomeownerMainScreenState();
}

class _HomeownerMainScreenState extends State<HomeownerMainScreen> {
  bool _isLoading = false;
  int _currentIndex = 0;
  List<ServiceCategoryCard> _categories = [];

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

      // Load categories from the database
      final categories = await databaseProvider.loadServiceCategories();

      // Convert to card models with different sizes and accent colors
      final cardCategories = categories.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;

        // Assign different sizes based on position
        CardSize size;
        if (index == 0) {
          size = CardSize.large;
        } else if (index % 3 == 0) {
          size = CardSize.medium;
        } else {
          size = CardSize.small;
        }

        // Generate a unique color based on the category name
        final hue = (category.name.hashCode % 360).toDouble();
        final accentColor = HSLColor.fromAHSL(1.0, hue, 0.6, 0.4).toColor();

        return ServiceCategoryCard(
          id: category.id,
          name: category.name,
          description: category.description ?? '',
          iconName: category.iconName ?? 'default',
          serviceCount: 5, // TODO: Get actual count from database
          minPrice: 89.99, // TODO: Get actual price range from database
          maxPrice: 1999.99,
          size: size,
          accentColor: accentColor,
        );
      }).toList();

      setState(() {
        _categories = cardCategories;
      });
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

  void _handleCategoryTap(String categoryId) {
    // TODO: Navigate to category detail screen
    print('Tapped category: $categoryId');
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

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${homeowner.profile.name}!',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 8),
                Text(
                  'What service can we help you with today?',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        SliverFillRemaining(
          child: ServiceCategoriesGrid(
            categories: _categories,
            onCategoryTap: _handleCategoryTap,
          ),
        ),
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
