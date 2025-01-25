import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../../providers/auth_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/professional_stats_provider.dart';
import '../../providers/schedule_provider.dart';
import '../services/supabase_config.dart';

class AppProviders {
  static List<SingleChildWidget> getProviders() {
    return [
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(SupabaseConfig.client),
      ),
      ChangeNotifierProxyProvider<AuthProvider, DatabaseProvider>(
        create: (context) => DatabaseProvider(
          context.read<AuthProvider>(),
        ),
        update: (context, auth, previous) => previous ?? DatabaseProvider(auth),
      ),
      ChangeNotifierProvider<JobProvider>(
        create: (_) => JobProvider(),
      ),
      ChangeNotifierProxyProvider<DatabaseProvider, NotificationProvider>(
        create: (context) => NotificationProvider(
          context.read<DatabaseProvider>(),
        ),
        update: (context, db, previous) => previous ?? NotificationProvider(db),
      ),
      ChangeNotifierProvider<PaymentProvider>(
        create: (_) => PaymentProvider(SupabaseConfig.client),
      ),
      ChangeNotifierProxyProvider<DatabaseProvider, ProfessionalStatsProvider>(
        create: (context) => ProfessionalStatsProvider(
          context.read<DatabaseProvider>(),
        ),
        update: (context, db, previous) =>
            previous ?? ProfessionalStatsProvider(db),
      ),
      ChangeNotifierProvider<ScheduleProvider>(
        create: (_) => ScheduleProvider(SupabaseConfig.client),
      ),
    ];
  }
}
