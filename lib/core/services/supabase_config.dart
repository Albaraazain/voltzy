import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';
import '../config/supabase_config.dart' as config;

class SupabaseConfig {
  static late final SupabaseClient client;

  static Future<void> initialize() async {
    try {
      Logger.info('Initializing Supabase connection...');
      await Supabase.initialize(
        url: config.SupabaseConfig.url,
        anonKey: config.SupabaseConfig.anonKey,
      );
      client = Supabase.instance.client;
      Logger.info('Supabase connection initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize Supabase: $e');
      rethrow;
    }
  }
}
