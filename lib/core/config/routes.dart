import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/homeowner/screens/broadcast_job_screen.dart';
import '../../features/homeowner/screens/direct_request_job_screen.dart';
import '../../features/homeowner/screens/direct_request_map_screen.dart';
import '../../features/homeowner/screens/homeowner_main_screen.dart';
import '../../features/homeowner/screens/jobs_screen.dart';
import '../../features/homeowner/screens/professional_profile_screen.dart';
import '../../features/homeowner/screens/search_screen.dart';
import '../../features/professional/screens/dashboard_screen.dart';
import '../../features/professional/screens/professional_main_screen.dart';
import '../../features/professional/screens/schedule_screen.dart';
import '../../models/professional_model.dart';
import '../../models/service_model.dart';
import '../../features/homeowner/models/service.dart';
import '../../features/homeowner/screens/homeowner_profile_screen.dart';

class AppRoutes {
  static Map<String, Widget Function(BuildContext)> getRoutes() {
    return {
      '/login': (context) => const LoginScreen(),
      '/register': (context) => const RegisterScreen(),
      '/search': (context) => const SearchScreen(),
      '/jobs': (context) => const JobsScreen(),
      '/professional/dashboard': (context) => const DashboardScreen(),
      '/professional/schedule': (context) => const ScheduleScreen(),
      '/professional/main': (context) => const ProfessionalMainScreen(),
      '/homeowner/dashboard': (context) => const HomeownerMainScreen(),
      '/homeowner/main': (context) => const HomeownerMainScreen(),
      '/homeowner/profile': (context) => const HomeownerProfileScreen(),
    };
  }

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/professional-profile':
        final professional = settings.arguments as Professional;
        return MaterialPageRoute(
          builder: (_) => ProfessionalProfileScreen(professional: professional),
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
        final service = settings.arguments as Service;
        return MaterialPageRoute(
          builder: (_) => BroadcastJobScreen(service: service),
        );

      default:
        return null;
    }
  }
}
