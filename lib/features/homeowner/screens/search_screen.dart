import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voltz/features/common/widgets/filter_bottom_sheet.dart';
import 'package:voltz/features/common/widgets/professional_card.dart';
import 'package:voltz/features/common/widgets/search_filter_chip.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Residential',
    'Commercial',
    'Emergency',
    'Installation',
    'Repair',
  ];

  @override
  void initState() {
    super.initState();
    // Load professionals when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DatabaseProvider>().loadProfessionals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search professionals...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.map_outlined),
                          color: Colors.white,
                          onPressed: () {
                            Navigator.pushNamed(context, '/browse_map');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filters.map((filter) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: SearchFilterChip(
                            label: filter,
                            isSelected: _selectedFilter == filter,
                            onTap: () {
                              setState(() => _selectedFilter = filter);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            // Search Results
            Expanded(
              child: Consumer<DatabaseProvider>(
                builder: (context, databaseProvider, child) {
                  if (databaseProvider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.accent),
                      ),
                    );
                  }

                  final professionals = databaseProvider.professionals;

                  if (professionals.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No professionals found',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: professionals.length,
                    itemBuilder: (context, index) {
                      final professional = professionals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ProfessionalCard(
                          professional: professional,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        filterGroups: const <String, List<String>>{},
        selectedFilters: const {},
        onApply: (filters) {},
        onReset: () {},
      ),
    );
  }
}
