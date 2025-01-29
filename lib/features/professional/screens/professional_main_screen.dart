import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/bottom_navigation_provider.dart';
import '../../../core/config/routes.dart';
import 'professional_home_screen.dart';
import 'professional_calendar_screen.dart';
import 'professional_messages_screen.dart';
import 'professional_profile_screen.dart';
import 'job_requests_screen.dart';

class ProfessionalMainScreen extends StatefulWidget {
  const ProfessionalMainScreen({super.key});

  @override
  State<ProfessionalMainScreen> createState() => _ProfessionalMainScreenState();
}

class _ProfessionalMainScreenState extends State<ProfessionalMainScreen> {
  final int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ProfessionalHomeScreen(),
    const JobRequestsScreen(),
    const ProfessionalCalendarScreen(),
    const ProfessionalMessagesScreen(),
    const ProfessionalProfileScreen(),
  ];

  void showMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeIn,
            ),
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
                      color: Colors.pink[400],
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
                              Icons.work_outline, 'Job Requests', animation, 1,
                              onTap: () {
                            Navigator.pop(context);
                            context
                                .read<BottomNavigationProvider>()
                                .setIndex(1);
                          }),
                          _buildAnimatedMenuItem(
                              Icons.calendar_today, 'Schedule', animation, 2,
                              onTap: () {
                            Navigator.pop(context);
                            context
                                .read<BottomNavigationProvider>()
                                .setIndex(2);
                          }),
                          _buildAnimatedMenuItem(
                              Icons.message_outlined, 'Messages', animation, 3,
                              onTap: () {
                            Navigator.pop(context);
                            context
                                .read<BottomNavigationProvider>()
                                .setIndex(3);
                          }),
                          _buildAnimatedMenuItem(
                              Icons.person_outline, 'Profile', animation, 4,
                              onTap: () {
                            Navigator.pop(context);
                            context
                                .read<BottomNavigationProvider>()
                                .setIndex(4);
                          }),
                          const Divider(color: Colors.white24, height: 32),
                          _buildAnimatedMenuItem(
                              Icons.work_outline, 'My Services', animation, 5,
                              onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                                context, AppRoutes.professionalServices);
                          }),
                          _buildAnimatedMenuItem(
                              Icons.payments_outlined, 'Earnings', animation, 6,
                              onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                                context, AppRoutes.professionalEarnings);
                          }),
                          _buildAnimatedMenuItem(
                              Icons.settings_outlined, 'Settings', animation, 7,
                              onTap: () {
                            Navigator.pop(context);
                            // TODO: Navigate to settings screen
                          }),
                          _buildAnimatedMenuItem(Icons.help_outline,
                              'Help & Support', animation, 8, onTap: () {
                            Navigator.pop(context);
                            // TODO: Navigate to help screen
                          }),
                          const Spacer(),
                          _buildAnimatedMenuItem(
                              Icons.logout, 'Sign Out', animation, 9,
                              onTap: () {
                            Navigator.pop(context);
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
          0.3 + (index * 0.05),
          1.0,
          curve: Curves.easeOutCubic,
        ),
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Interval(
            0.3 + (index * 0.05),
            1.0,
            curve: Curves.easeOut,
          ),
        ),
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
    return Consumer<BottomNavigationProvider>(
      builder: (context, navigationProvider, _) {
        return Scaffold(
          body: IndexedStack(
            index: navigationProvider.selectedIndex,
            children: _screens.map((screen) {
              return Builder(
                builder: (context) => GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: screen,
                ),
              );
            }).toList(),
          ),
          bottomNavigationBar: FlashyTabBar(
            selectedIndex: navigationProvider.selectedIndex,
            showElevation: false,
            height: 55,
            items: [
              FlashyTabBarItem(
                icon: const Icon(Icons.home_outlined),
                title: const Text('Home'),
              ),
              FlashyTabBarItem(
                icon: const Icon(Icons.work_outline),
                title: const Text('Requests'),
              ),
              FlashyTabBarItem(
                icon: const Icon(Icons.calendar_today),
                title: const Text('Schedule'),
              ),
              FlashyTabBarItem(
                icon: const Icon(Icons.message_outlined),
                title: const Text('Messages'),
              ),
              FlashyTabBarItem(
                icon: const Icon(Icons.person_outline),
                title: const Text('Profile'),
              ),
            ],
            onItemSelected: (index) {
              navigationProvider.setIndex(index);
            },
          ),
        );
      },
    );
  }
}
