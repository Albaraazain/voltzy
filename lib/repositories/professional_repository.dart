import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/logger_service.dart';
import '../models/professional_model.dart';
import '../models/profile_model.dart' as profile_models;
import '../models/service_model.dart';

class ProfessionalRepository {
  final SupabaseClient _client;

  ProfessionalRepository(this._client);

  Future<Professional?> getCurrentProfessional(String userId) async {
    try {
      LoggerService.info('Loading professional data for profile: $userId');

      final queryString = '''
        *,
        profile:profiles (
          id,
          email,
          user_type,
          name,
          created_at,
          last_login_at
        ),
        professional_services!professional_services_professional_id_fkey (
          service:services (*)
        )
      ''';

      final response = await _client
          .from('professionals')
          .select(queryString)
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        LoggerService.error(
            'No professional record found for profile: $userId');
        return null;
      }

      final userProfile = profile_models.Profile.fromJson(response['profile']);
      return Professional.fromJson({
        ...response,
        'profile': userProfile.toJson(),
      });
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load professional data', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Professional>> getAllProfessionals() async {
    try {
      LoggerService.debug('🔄 Loading all professionals...');

      final response = await _client.from('professionals').select('''
        *,
        profile:profiles (*),
        professional_services!professional_services_professional_id_fkey (
          service:services (*)
        )
      ''');

      final List<Professional> professionals = [];
      for (final row in response) {
        try {
          if (row['profile'] == null) continue;

          final profile = profile_models.Profile.fromJson(row['profile']);
          if (profile.userType != profile_models.UserType.professional)
            continue;

          final services = (row['professional_services'] as List<dynamic>?)
                  ?.map((s) => Service.fromJson(s['service']))
                  .toList() ??
              [];

          professionals.add(Professional.fromJson({
            ...row,
            'profile': profile.toJson(),
            'services': services,
          }));
        } catch (e) {
          LoggerService.error('Failed to parse professional: ${row['id']}', e);
        }
      }

      return professionals;
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load professionals', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Service>> getServicesForProfessional(
      String professionalId) async {
    try {
      LoggerService.info('Loading services for professional: $professionalId');

      final response = await _client
          .from('professional_services')
          .select('''
            *,
            service:services (*)
          ''')
          .eq('professional_id', professionalId)
          .eq('is_active', true)
          .order('created_at');

      final services = response.map((row) {
        final serviceData = row['service'] as Map<String, dynamic>;
        // If there's a custom price or duration, override the default values
        if (row['custom_price'] != null) {
          serviceData['base_price'] = row['custom_price'];
        }
        if (row['custom_duration'] != null) {
          serviceData['estimated_duration'] = row['custom_duration'];
        }
        return Service.fromJson(serviceData);
      }).toList();

      return services;
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to load professional services', e, stackTrace);
      rethrow;
    }
  }

  Future<void> addServiceToProfessional(
    String professionalId,
    String serviceId, {
    double? customPrice,
    int? customDuration,
  }) async {
    try {
      await _client.from('professional_services').upsert({
        'professional_id': professionalId,
        'service_id': serviceId,
        'is_active': true,
        'custom_price': customPrice,
        'custom_duration': customDuration,
      });
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to add service to professional', e, stackTrace);
      rethrow;
    }
  }

  Future<void> removeServiceFromProfessional(
    String professionalId,
    String serviceId,
  ) async {
    try {
      await _client
          .from('professional_services')
          .delete()
          .match({'professional_id': professionalId, 'service_id': serviceId});
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to remove service from professional', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateProfessionalService(
    String professionalId,
    String serviceId, {
    double? customPrice,
    int? customDuration,
    bool? isActive,
  }) async {
    try {
      final updates = {
        if (customPrice != null) 'custom_price': customPrice,
        if (customDuration != null) 'custom_duration': customDuration,
        if (isActive != null) 'is_active': isActive,
      };

      if (updates.isEmpty) return;

      await _client
          .from('professional_services')
          .update(updates)
          .match({'professional_id': professionalId, 'service_id': serviceId});
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to update professional service', e, stackTrace);
      rethrow;
    }
  }
}
