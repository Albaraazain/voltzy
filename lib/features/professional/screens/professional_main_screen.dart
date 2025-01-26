import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/bottom_navigation_provider.dart';
import '../../../core/routes/app_router.dart';
import 'professional_home_screen.dart';
import 'professional_calendar_screen.dart';
import 'professional_messages_screen.dart';
import 'professional_profile_screen.dart';

class ProfessionalMainScreen extends StatefulWidget {
  const ProfessionalMainScreen({Key? key}) : super(key: key);

  @override
  ProfessionalMainScreenState createState() => ProfessionalMainScreenState();
}

class ProfessionalMainScreenState extends State<ProfessionalMainScreen> {
  final List<Widget> _screens = [
    const ProfessionalHomeScreen(),
    const ProfessionalCalendarScreen(),
    const ProfessionalMessagesScreen(),
    const ProfessionalProfileScreen(),
  ];

  int _selectedIndex = 0;

  void showMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black38,
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
                            setState(() => _selectedIndex = 0);
                          }),
                          _buildAnimatedMenuItem(
                              Icons.calendar_today, 'Schedule', animation, 1,
                              onTap: () {
                            Navigator.pop(context);
                            setState(() => _selectedIndex = 1);
                          }),
                          _buildAnimatedMenuItem(
                              Icons.message_outlined, 'Messages', animation, 2,
                              onTap: () {
                            Navigator.pop(context);
                            setState(() => _selectedIndex = 2);
                          }),
                          _buildAnimatedMenuItem(
                              Icons.person_outline, 'Profile', animation, 3,
                              onTap: () {
                            Navigator.pop(context);
                            setState(() => _selectedIndex = 3);
                          }),
                          const Divider(color: Colors.white24, height: 32),
                          _buildAnimatedMenuItem(
                              Icons.work_outline, 'My Services', animation, 4,
                              onTap: () {
                            Navigator.pop(context);
                            // TODO: Navigate to services screen
                          }),
                          _buildAnimatedMenuItem(
                              Icons.payments_outlined, 'Earnings', animation, 5,
                              onTap: () {
                            Navigator.pop(context);
                            // TODO: Navigate to earnings screen
                          }),
                          _buildAnimatedMenuItem(
                              Icons.settings_outlined, 'Settings', animation, 6,
                              onTap: () {
                            Navigator.pop(context);
                            // TODO: Navigate to settings screen
                          }),
                          _buildAnimatedMenuItem(Icons.help_outline,
                              'Help & Support', animation, 7, onTap: () {
                            Navigator.pop(context);
                            // TODO: Navigate to help screen
                          }),
                          const Spacer(),
                          _buildAnimatedMenuItem(
                              Icons.logout, 'Sign Out', animation, 8,
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
            showElevation: true,
            onItemSelected: (index) => navigationProvider.setIndex(index),
            items: [
              FlashyTabBarItem(
                icon: const Icon(Icons.home_outlined),
                title: const Text('Home'),
                activeColor: Colors.pink,
                inactiveColor: Colors.grey,
              ),
              FlashyTabBarItem(
                icon: const Icon(Icons.calendar_today),
                title: const Text('Schedule'),
                activeColor: Colors.pink,
                inactiveColor: Colors.grey,
              ),
              FlashyTabBarItem(
                icon: const Icon(Icons.message_outlined),
                title: const Text('Messages'),
                activeColor: Colors.pink,
                inactiveColor: Colors.grey,
              ),
              FlashyTabBarItem(
                icon: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                activeColor: Colors.pink,
                inactiveColor: Colors.grey,
              ),
            ],
          ),
        );
      },
    );
  }
}
