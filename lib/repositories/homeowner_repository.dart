import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/logger_service.dart';
import '../models/homeowner_model.dart';
import '../models/profile_model.dart' as profile_models;

class HomeownerRepository {
  final SupabaseClient _client;

  HomeownerRepository(this._client);

  Future<Homeowner?> getCurrentHomeowner(
      String userId, profile_models.Profile profile) async {
    try {
      LoggerService.info('Loading homeowner data for profile: $userId');

      final response =
          await _client.from('homeowners').select().eq('id', userId).single();

      return Homeowner.fromJson(response, profile: profile);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load homeowner data', e, stackTrace);
      rethrow;
    }
  }
}
