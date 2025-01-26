import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/providers.dart';
import 'core/config/routes.dart';
import 'core/constants/colors.dart';
import 'core/config/supabase_config.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/common/widgets/loading_indicator.dart';
import 'features/homeowner/screens/homeowner_main_screen.dart';
import 'features/professional/screens/professional_main_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/database_provider.dart';
import 'providers/bottom_navigation_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Google Maps for iOS
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await [
        Permission.location,
      ].request();
    }

    // Initialize Supabase
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: true,
    );

    // Run the app with the client
    runApp(const MyAppWrapper());
  } catch (e) {
    debugPrint('Failed to initialize app: $e');
    runApp(const ErrorApp());
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Failed to initialize app. Please try again.',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}

class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BottomNavigationProvider>(
          create: (_) => BottomNavigationProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(supabase),
        ),
        ChangeNotifierProxyProvider<AuthProvider, DatabaseProvider>(
          create: (context) => DatabaseProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, auth, previous) =>
              previous ?? DatabaseProvider(auth),
        ),
        ...AppProviders.getProviders().where((provider) {
          // Filter out providers that are already defined above
          if (provider is ChangeNotifierProvider<BottomNavigationProvider>) {
            return false;
          }
          if (provider is ChangeNotifierProvider<AuthProvider>) {
            return false;
          }
          if (provider
              is ChangeNotifierProxyProvider<AuthProvider, DatabaseProvider>) {
            return false;
          }
          return true;
        }),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return FutureBuilder(
      future: authProvider.initializationCompleted,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: AppColors.background,
              body: const Center(child: LoadingIndicator()),
            ),
          );
        }

        return MaterialApp(
          title: 'Voltz',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: AppColors.primary,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.accent,
              background: AppColors.background,
              surface: AppColors.surface,
            ),
            scaffoldBackgroundColor: AppColors.background,
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.background,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
              titleTextStyle: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              toolbarHeight: 48,
              centerTitle: true,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          home: authProvider.isAuthenticated
              ? authProvider.userType == UserType.homeowner
                  ? const HomeownerMainScreen()
                  : const ProfessionalMainScreen()
              : const LoginScreen(),
          routes: AppRoutes.getRoutes(),
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}
