import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/database_provider.dart';
import '../../core/services/logger_service.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/homeowner/screens/broadcast_job_screen.dart';
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
import '../../features/professional/screens/professional_main_screen.dart';
import '../../models/professional_model.dart';
import '../../models/base_service_model.dart';
import '../../features/homeowner/screens/homeowner_profile_screen.dart';
import '../../features/professional/screens/professional_job_details_screen.dart';
import '../../features/professional/screens/professional_earnings_screen.dart';
import '../../features/professional/screens/professional_service_details_screen.dart';
import '../../features/professional/screens/professional_services_management_screen.dart';
import '../../features/homeowner/screens/set_location_screen.dart';
import '../../features/professional/screens/client_profile_notes_screen.dart';
import '../../models/homeowner_model.dart';

class AppRoutes {
  // Route names
  static const String professionalHome = '/professional/home';
  static const String professionalMain = '/professional/main';
  static const String professionalCalendar = '/professional/calendar';
  static const String professionalMessages = '/professional/messages';
  static const String professionalProfile = '/professional/profile';
  static const String professionalServices = '/professional/services';
  static const String professionalJobDetails = '/professional/job-details';
  static const String professionalEarnings = '/professional/earnings';
  static const String professionalServiceDetails =
      '/professional/service-details';
  static const String clientProfileNotes = '/professional/client-notes';

  static Map<String, Widget Function(BuildContext)> getRoutes() {
    return {
      '/login': (context) {
        LoggerService.debug('🔄 Navigating to Login Screen');
        return const LoginScreen();
      },
      '/register': (context) {
        LoggerService.debug('🔄 Navigating to Register Screen');
        return const RegisterScreen();
      },
      '/search': (context) {
        LoggerService.debug('🔄 Navigating to Search Screen');
        return const SearchScreen();
      },
      '/jobs': (context) {
        LoggerService.debug('🔄 Navigating to Jobs Screen');
        return const JobsScreen();
      },
      '/homeowner/dashboard': (context) {
        LoggerService.debug('🔄 Navigating to Homeowner Dashboard');
        return const HomeownerMainScreen();
      },
      '/homeowner/main': (context) {
        LoggerService.debug('🔄 Navigating to Homeowner Main Screen');
        return const HomeownerMainScreen();
      },
      '/homeowner/profile': (context) {
        LoggerService.debug('🔄 Navigating to Homeowner Profile');
        return const HomeownerProfileScreen();
      },
      // Professional routes
      professionalMain: (context) {
        LoggerService.debug('🔄 Navigating to Professional Main Screen');
        return const ProfessionalMainScreen();
      },
      professionalHome: (context) {
        LoggerService.debug('🔄 Navigating to Professional Home Screen');
        return const ProfessionalHomeScreen();
      },
      professionalCalendar: (context) {
        LoggerService.debug('🔄 Navigating to Professional Calendar');
        return const ProfessionalCalendarScreen();
      },
      professionalMessages: (context) {
        LoggerService.debug('🔄 Navigating to Professional Messages');
        return const ProfessionalMessagesScreen();
      },
      professionalProfile: (context) {
        LoggerService.debug('🔄 Navigating to Professional Profile');
        return const ProfessionalProfileScreen();
      },
      professionalServices: (context) {
        LoggerService.debug('🔄 Navigating to Professional Services');
        return const ProfessionalServicesManagementScreen();
      },
      professionalEarnings: (context) {
        LoggerService.debug('🔄 Navigating to Professional Earnings');
        return const ProfessionalEarningsScreen();
      },
      '/set-location': (context) {
        final args =
            ModalRoute.of(context)!.settings.arguments as Map<String, double>;
        return SetLocationScreen(
          initialLat: args['initialLat']!,
          initialLng: args['initialLng']!,
        );
      },
    };
  }

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    LoggerService.debug('🔄 Generating route for: ${settings.name}');
    LoggerService.debug('📦 Route arguments: ${settings.arguments}');

    try {
      switch (settings.name) {
        case professionalJobDetails:
          final job = settings.arguments as Map<String, dynamic>;
          LoggerService.debug('📄 Job details: $job');
          return MaterialPageRoute(
            builder: (_) => ProfessionalJobDetailsScreen(job: job),
          );

        case professionalServiceDetails:
          final serviceData = settings.arguments as Map<String, dynamic>;
          LoggerService.debug('📄 Service details: $serviceData');
          return MaterialPageRoute(
            builder: (_) =>
                ProfessionalServiceDetailsScreen(serviceData: serviceData),
          );

        case '/professional-profile':
          final professional = settings.arguments as Professional;
          LoggerService.debug('👤 Professional profile: ${professional.id}');
          return MaterialPageRoute(
            builder: (_) =>
                homeowner.ProfessionalProfileScreen(professional: professional),
          );

        case '/direct-request-map':
          final args = settings.arguments as Map<String, dynamic>;
          LoggerService.debug('🗺️ Direct request map args: $args');
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

        case '/broadcast-job':
          final service = settings.arguments as BaseService;
          LoggerService.debug(
              '📢 Broadcasting job for service: ${service.name}');
          return MaterialPageRoute(
            builder: (_) => BroadcastJobScreen(service: service),
          );

        case clientProfileNotes:
          final args = settings.arguments as Map<String, dynamic>;
          final homeownerId = args['homeownerId'] as String;
          LoggerService.debug(
              '📝 Loading client notes for homeowner: $homeownerId');
          return MaterialPageRoute(
            builder: (context) => FutureBuilder<Homeowner?>(
              future: Provider.of<DatabaseProvider>(context, listen: false)
                  .getHomeownerById(homeownerId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                }

                final homeowner = snapshot.data;
                if (homeowner == null) {
                  return const Scaffold(
                    body: Center(
                      child: Text('Homeowner not found'),
                    ),
                  );
                }

                return ClientProfileNotesScreen(homeowner: homeowner);
              },
            ),
          );

        default:
          LoggerService.warning('⚠️ No route defined for ${settings.name}');
          return null;
      }
    } catch (e, stackTrace) {
      LoggerService.error('❌ Error generating route', e, stackTrace);
      return null;
    }
  }
}
