import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../common/widgets/custom_list_tile.dart';

class HomeownerProfileScreen extends StatelessWidget {
  const HomeownerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeowner = context.watch<DatabaseProvider>().currentHomeowner;
    final profile = context.watch<DatabaseProvider>().currentProfile;

    if (homeowner == null || profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.name,
                      style: AppTextStyles.h2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Settings Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Settings',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 16),
                  CustomListTile(
                    leading: const Icon(Icons.person_outline),
                    title: 'Personal Information',
                    subtitle: 'Manage your personal details',
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/homeowner/personal-info',
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: 'Address',
                    subtitle: homeowner.address ?? 'Add your address',
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/homeowner/address',
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: 'Notification Settings',
                    subtitle: 'Manage your notification preferences',
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/homeowner/notification-preferences',
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomListTile(
                    leading: const Icon(Icons.phone_outlined),
                    title: 'Contact Preferences',
                    subtitle: 'Choose how you want to be contacted',
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/homeowner/contact-preferences',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Support Section
                  Text(
                    'Support',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 16),
                  CustomListTile(
                    leading: const Icon(Icons.help_outline),
                    title: 'Help Center',
                    subtitle: 'Get help and support',
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/homeowner/help-center',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign Out Button
                  CustomListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: 'Sign Out',
                    titleStyle: const TextStyle(color: Colors.red),
                    subtitle: 'Log out of your account',
                    onTap: () => context.read<AuthProvider>().signOut(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
