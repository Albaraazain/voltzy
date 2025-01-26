import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/bottom_navigation_provider.dart';
import '../../common/widgets/bottom_navigation.dart';
import 'homeowner_home_screen.dart';
import 'homeowner_profile_screen.dart';

class HomeownerMainScreen extends StatefulWidget {
  const HomeownerMainScreen({super.key});

  @override
  State<HomeownerMainScreen> createState() => _HomeownerMainScreenState();
}

class _HomeownerMainScreenState extends State<HomeownerMainScreen> {
  final List<Widget> _screens = [
    const HomeownerHomeScreen(),
    const Center(child: Text('Favorites')), // TODO: Implement favorites screen
    const Center(child: Text('Jobs')), // TODO: Implement jobs screen
    const HomeownerProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Ensure we start at the home screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BottomNavigationProvider>().resetToHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavigationProvider>(
      builder: (context, navigationProvider, _) {
        return Scaffold(
          body: IndexedStack(
            index: navigationProvider.selectedIndex,
            children: _screens,
          ),
          bottomNavigationBar: const HomeownerBottomNavigation(),
        );
      },
    );
  }
}
