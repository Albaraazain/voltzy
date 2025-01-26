import 'package:flutter/material.dart';
import '../../features/professional/screens/professional_home_screen.dart';
import '../../features/professional/screens/professional_calendar_screen.dart';
import '../../features/professional/screens/professional_messages_screen.dart';
import '../../features/professional/screens/professional_profile_screen.dart';

class AppRouter {
  static const String professionalHome = '/professional/home';
  static const String professionalCalendar = '/professional/calendar';
  static const String professionalMessages = '/professional/messages';
  static const String professionalProfile = '/professional/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case professionalHome:
        return MaterialPageRoute(
          builder: (_) => const ProfessionalHomeScreen(),
        );
      case professionalCalendar:
        return MaterialPageRoute(
          builder: (_) => const ProfessionalCalendarScreen(),
        );
      case professionalMessages:
        return MaterialPageRoute(
          builder: (_) => const ProfessionalMessagesScreen(),
        );
      case professionalProfile:
        return MaterialPageRoute(
          builder: (_) => const ProfessionalProfileScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
