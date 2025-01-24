import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

class SupabaseConfig {
  static late final SupabaseClient client;

  static Future<void> initialize() async {
    try {
      Logger.info('Initializing Supabase connection...');
      await Supabase.initialize(
        url: 'http://127.0.0.1:54323',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
      );
      client = Supabase.instance.client;
      Logger.info('Supabase connection initialized successfully');
    } catch (e) {
      Logger.error('Failed to initialize Supabase: $e');
      rethrow;
    }
  }
}
