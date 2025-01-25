import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://2acf-95-7-10-26.ngrok-free.app';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';
  static const String serviceRoleKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU';
  static const String storageUrl =
      'https://2acf-95-7-10-26.ngrok-free.app/storage/v1';
  static const String realtimeUrl =
      'wss://2acf-95-7-10-26.ngrok-free.app/realtime/v1';
  static const String restUrl =
      'https://2acf-95-7-10-26.ngrok-free.app/rest/v1';
  static const String authUrl =
      'https://2acf-95-7-10-26.ngrok-free.app/auth/v1';
  static const String functionsUrl =
      'https://2acf-95-7-10-26.ngrok-free.app/functions/v1';

  static SupabaseClient get client => Supabase.instance.client;
}
