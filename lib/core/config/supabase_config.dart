import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'http://127.0.0.1:54323';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';
  static const String serviceRoleKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU';
  static const String storageUrl = 'http://127.0.0.1:54323/storage/v1';
  static const String realtimeUrl = 'ws://127.0.0.1:54323/realtime/v1';
  static const String restUrl = 'http://127.0.0.1:54323/rest/v1';
  static const String authUrl = 'http://127.0.0.1:54323/auth/v1';
  static const String functionsUrl = 'http://127.0.0.1:54323/functions/v1';

  static SupabaseClient get client => Supabase.instance.client;
}
