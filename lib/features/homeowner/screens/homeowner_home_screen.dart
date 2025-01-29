import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/database_provider.dart';
import '../../common/widgets/loading_indicator.dart';
import '../models/service_category_card.dart';
import 'category_services_screen.dart';
import '../../../providers/bottom_navigation_provider.dart';
import '../../../providers/auth_provider.dart';
import '../widgets/location_selector_widget.dart';

class HomeownerHomeScreen extends StatefulWidget {
  const HomeownerHomeScreen({super.key});

  @override
  State<HomeownerHomeScreen> createState() => _HomeownerHomeScreenState();
}

class _HomeownerHomeScreenState extends State<HomeownerHomeScreen> {
  bool _isLoading = false;
  List<ServiceCategoryCard> _categories = [];
  String _selectedDifficulty = 'Emergency';

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
      final categories = await databaseProvider.loadServiceCategories();

      final cardCategories = categories.map((category) {
        return ServiceCategoryCard(
          id: category.id,
          name: category.name,
          description: category.description ?? '',
          iconName: category.iconName ?? 'default',
          serviceCount: 5,
          minPrice: 89.99,
          maxPrice: 1999.99,
          size: CardSize.medium,
          accentColor: _getCategoryMaterialColor(category.name),
        );
      }).toList();

      setState(() => _categories = cardCategories);
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

  MaterialColor _getCategoryMaterialColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'cleaning services':
        return Colors.blue;
      case 'maintenance services':
        return Colors.orange;
      case 'installation services':
        return Colors.green;
      case 'repair services':
        return Colors.red;
      case 'landscaping services':
        return Colors.teal;
      default:
        return Colors.amber;
    }
  }

  Widget _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('electrical')) return _buildElectricalIcon();
    if (name.contains('plumbing')) return _buildPlumbingIcon();
    if (name.contains('cleaning')) return _buildCleaningIcon();
    return _buildRepairIcon(); // Default icon for other categories
  }

  void _showMenu() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: animation,
            child: Material(
              elevation: 0,
              color: Colors.transparent,
              child: Stack(
                children: [
                  // Semi-transparent overlay
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.black.withOpacity(0.3),
                    ),
                  ),
                  // Menu content
                  Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade400,
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(32)),
                    ),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Menu',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.white, size: 28),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          ),
                          _buildAnimatedMenuItem(
                              Icons.home_outlined, 'Home', animation, 0,
                              onTap: () {
                            Navigator.pop(context);
                            context
                                .read<BottomNavigationProvider>()
                                .setIndex(0);
                          }),
                          _buildAnimatedMenuItem(
                              Icons.favorite_outline, 'Favorites', animation, 1,
                              onTap: () {
                            Navigator.pop(context);
                            context
                                .read<BottomNavigationProvider>()
                                .setIndex(1);
                          }),
                          _buildAnimatedMenuItem(
                              Icons.access_time, 'My Jobs', animation, 2,
                              onTap: () {
                            Navigator.pop(context);
                            context
                                .read<BottomNavigationProvider>()
                                .setIndex(2);
                          }),
                          _buildAnimatedMenuItem(
                              Icons.person_outline, 'Profile', animation, 3,
                              onTap: () {
                            Navigator.pop(context);
                            context
                                .read<BottomNavigationProvider>()
                                .setIndex(3);
                          }),
                          const Divider(color: Colors.white24, height: 32),
                          _buildAnimatedMenuItem(
                              Icons.settings_outlined, 'Settings', animation, 4,
                              onTap: () {
                            Navigator.pop(context);
                            // TODO: Navigate to settings screen
                          }),
                          _buildAnimatedMenuItem(Icons.help_outline,
                              'Help & Support', animation, 5, onTap: () {
                            Navigator.pop(context);
                            // TODO: Navigate to help screen
                          }),
                          const Spacer(),
                          _buildAnimatedMenuItem(
                              Icons.logout, 'Sign Out', animation, 6,
                              onTap: () {
                            Navigator.pop(context);
                            // TODO: Implement sign out
                            context.read<AuthProvider>().signOut();
                          }),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedMenuItem(
      IconData icon, String title, Animation<double> animation, int index,
      {VoidCallback? onTap}) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Interval(
          0.4 + (index * 0.1),
          1.0,
          curve: Curves.easeOutCubic,
        ),
      )),
      child: FadeTransition(
        opacity: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Interval(
            0.4 + (index * 0.1),
            1.0,
            curve: Curves.easeOut,
          ),
        )),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: Icon(icon, color: Colors.white, size: 28),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: LoadingIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 24),
                            Text(
                              'Welcome Back!',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'What service do you need today?',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: LocationSelectorWidget(),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(24),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final category = _categories[index];
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CategoryServicesScreen(
                                    categoryId: category.id,
                                    categoryName: category.name,
                                    categoryColor: category.accentColor,
                                  ),
                                ),
                              ),
                              child: category,
                            );
                          },
                          childCount: _categories.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: _showMenu,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Container(
                      width: 24,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 24,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 24,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Home Services of any Type',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyChips() {
    final difficulties = ['Emergency', 'Regular', 'Scheduled'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: difficulties.map((difficulty) {
          final isSelected = _selectedDifficulty == difficulty;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(difficulty),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedDifficulty = difficulty);
              },
              backgroundColor:
                  isSelected ? Colors.amber.shade100 : Colors.grey.shade100,
              labelStyle: TextStyle(
                color:
                    isSelected ? Colors.amber.shade700 : Colors.grey.shade400,
                fontSize: 14,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildServiceGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: _categories.map((category) {
        final color = _getCategoryMaterialColor(category.name);
        final icon = _getCategoryIcon(category.name);
        return GestureDetector(
          onTap: () {
            _navigateToCategory(category);
          },
          child: _buildServiceCard(
            category.name.replaceAll(' Services', ''),
            color,
            icon,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildServiceCard(String title, MaterialColor color, Widget icon) {
    String imagePath = 'assets/images/';
    switch (title.toLowerCase()) {
      case 'electrical':
        imagePath += 'electrical_services.png';
        break;
      case 'plumbing':
        imagePath += 'plumbing_services.png';
        break;
      case 'hvac':
        imagePath += 'hvac_services.png';
        break;
      case 'landscaping':
        imagePath += 'landscaping_services.png';
        break;
      case 'security systems':
      case 'security':
        imagePath += 'security_services.png';
        break;
      case 'smart home':
        imagePath += 'smart_home_services.png';
        break;
      case 'home cleaning':
      case 'cleaning':
        imagePath += 'home_cleaning_services.png';
        break;
      case 'carpentry':
        imagePath += 'carbentry_services.png';
        break;
      case 'painting':
        imagePath += 'painting_services.png';
        break;
      case 'solar services':
      case 'solar':
        imagePath += 'solar_services.png';
        break;
      case 'appliance repair':
      case 'appliance':
        imagePath += 'appliance_repair_services.png';
        break;
      default:
        imagePath += 'default_service.png';
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 0.5,
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.2,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElectricalIcon() {
    return CustomPaint(
      painter: ElectricalPainter(),
    );
  }

  Widget _buildPlumbingIcon() {
    return CustomPaint(
      painter: PlumbingPainter(),
    );
  }

  Widget _buildCleaningIcon() {
    return CustomPaint(
      painter: CleaningPainter(),
    );
  }

  Widget _buildRepairIcon() {
    return CustomPaint(
      painter: RepairPainter(),
    );
  }

  void _navigateToCategory(ServiceCategoryCard category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryServicesScreen(
          categoryName: category.name,
          categoryColor: _getCategoryMaterialColor(category.name),
          categoryId: category.id,
        ),
      ),
    );
  }
}

class ElectricalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pink.shade200
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.2)
      ..lineTo(size.width * 0.6, size.height * 0.5)
      ..lineTo(size.width * 0.7, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.8)
      ..lineTo(size.width * 0.4, size.height * 0.5)
      ..lineTo(size.width * 0.3, size.height * 0.5)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PlumbingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.3,
        size.width * 0.5,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.7,
        size.width * 0.7,
        size.height * 0.7,
      );

    canvas.drawPath(path, paint);
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.7),
      8,
      paint..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CleaningPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green.shade400;

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.2,
      paint,
    );

    paint
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.35, size.height * 0.5)
      ..lineTo(size.width * 0.45, size.height * 0.6)
      ..lineTo(size.width * 0.65, size.height * 0.4);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class RepairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.7)
      ..lineTo(size.width * 0.5, size.height * 0.3)
      ..lineTo(size.width * 0.7, size.height * 0.7);

    canvas.drawPath(path, paint);

    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.3),
      8,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
