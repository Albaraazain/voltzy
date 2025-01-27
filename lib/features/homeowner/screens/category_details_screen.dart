import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/database_provider.dart';
import '../../../models/base_service_model.dart';
import '../models/service.dart';
import 'service_details_screen.dart';

class CategoryDetailsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryDetailsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  List<BaseService> _services = [];
  bool _isLoading = false;
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final services = await context
          .read<DatabaseProvider>()
          .getServicesByCategory(widget.categoryId);
      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading services: $e')),
        );
      }
    }
  }

  Color _getCardColor(int index) {
    final colors = [
      const Color(0xFFFCE7F3), // pink-100
      const Color(0xFFFEF3C7), // amber-100
      const Color(0xFFD1FAE5), // emerald-100
      const Color(0xFFDBEAFE), // blue-100
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.chevron_left, size: 24),
                  ),
                  const SizedBox(width: 12),
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
              const SizedBox(height: 24),

              // Title
              Text(
                widget.categoryName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    FilterChip(
                      selected: _selectedFilterIndex == 0,
                      label: const Text('All Services'),
                      onSelected: (bool selected) {
                        setState(() => _selectedFilterIndex = 0);
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: const Color(0xFFFEF3C7),
                      labelStyle: TextStyle(
                        color: _selectedFilterIndex == 0
                            ? const Color(0xFFB45309)
                            : Colors.grey[600],
                      ),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      selected: _selectedFilterIndex == 1,
                      label: const Text('Available'),
                      onSelected: (bool selected) {
                        setState(() => _selectedFilterIndex = 1);
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: const Color(0xFFFEF3C7),
                      labelStyle: TextStyle(
                        color: _selectedFilterIndex == 1
                            ? const Color(0xFFB45309)
                            : Colors.grey[600],
                      ),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      selected: _selectedFilterIndex == 2,
                      label: const Text('Featured'),
                      onSelected: (bool selected) {
                        setState(() => _selectedFilterIndex = 2);
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: const Color(0xFFFEF3C7),
                      labelStyle: TextStyle(
                        color: _selectedFilterIndex == 2
                            ? const Color(0xFFB45309)
                            : Colors.grey[600],
                      ),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Services grid
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      final service = _services[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ServiceCard(
                          backgroundColor: _getCardColor(index),
                          title: service.name,
                          price: service.basePrice,
                          duration: '${service.durationHours} hours service',
                          service: service,
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final double price;
  final String duration;
  final BaseService service;

  const ServiceCard({
    super.key,
    required this.backgroundColor,
    required this.title,
    required this.price,
    required this.duration,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final categoryService = CategoryService(
          id: service.id,
          name: service.name,
          description: service.description ?? '',
          basePrice: service.basePrice,
          durationHours: service.durationHours ?? 0,
          categoryId: service.categoryId,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailsScreen(
              service: categoryService,
            ),
          ),
        );
      },
      child: Container(
        height: 192, // 48 * 4 for the height-48 in Tailwind
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                duration,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '\$${price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CustomPaint(
                    size: const Size(96, 96),
                    painter: ServiceIconPainter(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF7B8B)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = const Color(0xFFFFA4B1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path()
      ..moveTo(size.width / 2, size.height * 0.2)
      ..lineTo(size.width * 0.6, size.height * 0.5)
      ..lineTo(size.width * 0.7, size.height * 0.5)
      ..lineTo(size.width / 2, size.height * 0.8)
      ..lineTo(size.width * 0.4, size.height * 0.5)
      ..lineTo(size.width * 0.3, size.height * 0.5)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
