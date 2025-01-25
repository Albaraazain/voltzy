import 'package:flutter/material.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:provider/provider.dart';
import '../../../providers/bottom_navigation_provider.dart';
import '../../../providers/database_provider.dart';

class HomeownerBottomNavigation extends StatelessWidget {
  const HomeownerBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<DatabaseProvider, BottomNavigationProvider>(
      builder: (context, databaseProvider, navigationProvider, _) {
        final profile = databaseProvider.currentProfile;

        if (profile == null) return const SizedBox.shrink();

        return FlashyTabBar(
          selectedIndex: navigationProvider.selectedIndex,
          showElevation: false,
          height: 55,
          items: [
            FlashyTabBarItem(
              icon: const Icon(Icons.home_outlined),
              title: const Text('Home'),
            ),
            FlashyTabBarItem(
              icon: const Icon(Icons.favorite_outline),
              title: const Text('Favorites'),
            ),
            FlashyTabBarItem(
              icon: const Icon(Icons.access_time),
              title: const Text('Jobs'),
            ),
            FlashyTabBarItem(
              icon: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    profile.name.substring(0, 2).toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
              title: const Text('Profile'),
            ),
          ],
          onItemSelected: (index) {
            navigationProvider.setIndex(index);
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/homeowner/main');
                break;
              case 1:
                // TODO: Navigate to favorites
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/jobs');
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/homeowner/profile');
                break;
            }
          },
        );
      },
    );
  }
}
