import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../providers/database_provider.dart';
import '../../common/widgets/loading_indicator.dart';
import '../models/service_category_card.dart';
import '../models/service.dart';
import '../screens/broadcast_job_screen.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final ServiceCategoryCard category;

  const CategoryDetailsScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  bool _isLoading = true;
  List<CategoryService> _services = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      setState(() => _isLoading = true);
      final services = await context
          .read<DatabaseProvider>()
          .getServicesByCategory(widget.category.id);

      setState(() {
        _services = services;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading services: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Sliver app bar with category header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: widget.category.accentColor.withOpacity(0.1),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.category.accentColor.withOpacity(0.2),
                      widget.category.accentColor.withOpacity(0.1),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        IconMapper.getIcon(widget.category.iconName),
                        size: 48,
                        color: widget.category.accentColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.category.name,
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.category.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Services list
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: LoadingIndicator()),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final service = _services[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _ServiceCard(
                        name: service.name,
                        description: service.description,
                        duration: service.durationHours.toString(),
                        price: service.basePrice,
                        accentColor: widget.category.accentColor,
                        onTap: () {
                          print('DEBUG: Service card tapped');
                          print(
                              'DEBUG: Service details - Name: ${service.name}, Price: ${service.basePrice}');
                          try {
                            print(
                                'DEBUG: Attempting to navigate to broadcast-job screen');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BroadcastJobScreen(
                                  service: service,
                                ),
                              ),
                            ).then((value) {
                              print('DEBUG: Navigation result: $value');
                            }).catchError((error) {
                              print('ERROR: Navigation failed: $error');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Navigation error: $error')),
                              );
                            });
                          } catch (e, stackTrace) {
                            print('ERROR: Exception during navigation:');
                            print(e);
                            print('Stack trace:');
                            print(stackTrace);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                      ),
                    );
                  },
                  childCount: _services.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final String name;
  final String description;
  final String duration;
  final double price;
  final Color accentColor;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isHovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _handleHover(true),
      onExit: (_) => _handleHover(false),
      child: GestureDetector(
        onTap: () {
          print('DEBUG: GestureDetector onTap triggered');
          widget.onTap();
        },
        onTapDown: (_) => print('DEBUG: GestureDetector onTapDown triggered'),
        onTapUp: (_) => print('DEBUG: GestureDetector onTapUp triggered'),
        onTapCancel: () =>
            print('DEBUG: GestureDetector onTapCancel triggered'),
        behavior: HitTestBehavior.opaque, // Make sure it catches all taps
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      widget.accentColor.withOpacity(_isHovered ? 0.15 : 0.08),
                  blurRadius: _isHovered ? 8 : 4,
                  offset: Offset(0, _isHovered ? 4 : 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.name,
                        style: AppTextStyles.h3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '\$${widget.price.toStringAsFixed(0)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: widget.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.duration} hours',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: widget.accentColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
