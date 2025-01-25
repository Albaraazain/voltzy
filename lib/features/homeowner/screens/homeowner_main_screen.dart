import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../../common/widgets/loading_indicator.dart';
import '../models/service_category_card.dart';
import '../widgets/service_categories_grid.dart';
import '../screens/category_details_screen.dart';

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

        return ServiceCategoryCard(
          id: category.id,
          name: category.name,
          description: category.description ?? '',
          iconName: category.iconName ?? 'default',
          serviceCount: 5, // TODO: Get actual count from database
          minPrice: 89.99, // TODO: Get actual price range from database
          maxPrice: 1999.99,
          size: size,
          accentColor: AppColors.getCategoryColor(index),
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
    final category = _categories.firstWhere((c) => c.id == categoryId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailsScreen(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          _getTitle(),
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
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _buildCurrentScreen(),
      bottomNavigationBar: FlashyTabBar(
        selectedIndex: _currentIndex,
        showElevation: true,
        backgroundColor: AppColors.surface,
        height: 55,
        animationDuration: const Duration(milliseconds: 200),
        items: [
          FlashyTabBarItem(
            icon: const Icon(Icons.home_outlined, size: 22),
            title: const Text('Home', style: TextStyle(fontSize: 12)),
            activeColor: AppColors.primary,
            inactiveColor: AppColors.textSecondary,
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.search_outlined, size: 22),
            title: const Text('Search', style: TextStyle(fontSize: 12)),
            activeColor: AppColors.primary,
            inactiveColor: AppColors.textSecondary,
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.work_outline, size: 22),
            title: const Text('Jobs', style: TextStyle(fontSize: 12)),
            activeColor: AppColors.primary,
            inactiveColor: AppColors.textSecondary,
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.person_outline, size: 22),
            title: const Text('Profile', style: TextStyle(fontSize: 12)),
            activeColor: AppColors.primary,
            inactiveColor: AppColors.textSecondary,
          ),
        ],
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Search';
      case 2:
        return 'My Jobs';
      case 3:
        return 'Profile';
      default:
        return 'Home';
    }
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return ServiceCategoriesGrid(
          categories: _categories,
          onCategoryTap: _handleCategoryTap,
        );
      case 1:
        return const Center(child: Text('Search Screen'));
      case 2:
        return const Center(child: Text('Jobs Screen'));
      case 3:
        return const Center(child: Text('Profile Screen'));
      default:
        return ServiceCategoriesGrid(
          categories: _categories,
          onCategoryTap: _handleCategoryTap,
        );
    }
  }
}
