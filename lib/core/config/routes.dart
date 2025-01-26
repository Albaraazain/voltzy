import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/homeowner/screens/broadcast_job_screen.dart';
import '../../features/homeowner/screens/direct_request_job_screen.dart';
import '../../features/homeowner/screens/direct_request_map_screen.dart';
import '../../features/homeowner/screens/homeowner_main_screen.dart';
import '../../features/homeowner/screens/jobs_screen.dart';
import '../../features/homeowner/screens/professional_profile_screen.dart'
    as homeowner;
import '../../features/homeowner/screens/search_screen.dart';
import '../../features/professional/screens/professional_home_screen.dart';
import '../../features/professional/screens/professional_calendar_screen.dart';
import '../../features/professional/screens/professional_messages_screen.dart';
import '../../features/professional/screens/professional_profile_screen.dart';
import '../../models/professional_model.dart';
import '../../models/service_model.dart';
import '../../features/homeowner/models/service.dart';
import '../../features/homeowner/screens/homeowner_profile_screen.dart';

class AppRoutes {
  // Route names
  static const String professionalHome = '/professional/home';
  static const String professionalCalendar = '/professional/calendar';
  static const String professionalMessages = '/professional/messages';
  static const String professionalProfile = '/professional/profile';

  static Map<String, Widget Function(BuildContext)> getRoutes() {
    return {
      '/login': (context) => const LoginScreen(),
      '/register': (context) => const RegisterScreen(),
      '/search': (context) => const SearchScreen(),
      '/jobs': (context) => const JobsScreen(),
      '/homeowner/dashboard': (context) => const HomeownerMainScreen(),
      '/homeowner/main': (context) => const HomeownerMainScreen(),
      '/homeowner/profile': (context) => const HomeownerProfileScreen(),
      // Professional routes
      professionalHome: (context) => const ProfessionalHomeScreen(),
      professionalCalendar: (context) => const ProfessionalCalendarScreen(),
      professionalMessages: (context) => const ProfessionalMessagesScreen(),
      professionalProfile: (context) => const ProfessionalProfileScreen(),
    };
  }

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/professional-profile':
        final professional = settings.arguments as Professional;
        return MaterialPageRoute(
          builder: (_) =>
              homeowner.ProfessionalProfileScreen(professional: professional),
        );

      case '/direct-request-map':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DirectRequestMapScreen(
            service: args['service'] as String,
            scheduledDate: args['scheduledDate'] as DateTime,
            hours: args['hours'] as double,
            radiusKm: args['radiusKm'] as double,
            locationLat: args['locationLat'] as double?,
            locationLng: args['locationLng'] as double?,
          ),
        );

      case '/direct-request-job':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DirectRequestJobScreen(
            professional: args['professional'] as Professional,
            service: args['service'] as Service,
            scheduledDate: args['scheduledDate'] as DateTime,
            hours: args['hours'] as int,
            budget: args['budget'] as double,
          ),
        );

      case '/broadcast-job':
        final service = settings.arguments as CategoryService;
        return MaterialPageRoute(
          builder: (_) => BroadcastJobScreen(service: service),
        );

      default:
        return null;
    }
  }
}
