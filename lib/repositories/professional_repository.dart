import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../models/professional_model.dart';
import '../core/services/logger_service.dart';
import '../models/base_service_model.dart';
import '../models/professional_service_model.dart';
import '../models/profile_model.dart' as profile_models;

class ProfessionalRepository {
  final SupabaseClient _client;

  ProfessionalRepository(this._client);

  Future<Professional?> getProfessionalById(String id) async {
    try {
      final response = await _client.from('professionals').select('''
        *,
        profile:profiles (*),
        professional_services:professional_services (
          *,
          service:services (*)
        )
      ''').eq('id', id).single();

      return response == null ? null : Professional.fromJson(response);
    } catch (e) {
      LoggerService.error('Failed to get professional by id', e);
      rethrow;
    }
  }

  Future<List<Professional>> searchProfessionals(String query) async {
    try {
      final response = await _client.from('professionals').select('''
        *,
        profile:profiles (*),
        professional_services:professional_services (
          *,
          service:services (*)
        )
      ''').ilike('profile.name', '%$query%').order('created_at');

      return (response as List)
          .map((data) => Professional.fromJson(data))
          .toList();
    } catch (e) {
      LoggerService.error('Failed to search professionals', e);
      rethrow;
    }
  }

  Future<List<Professional>> getNearbyProfessionals({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? categoryId,
  }) async {
    try {
      var rpcParams = {
        'lat': latitude,
        'lng': longitude,
        'radius_km': radiusKm,
        'category_id': categoryId,
      };

      // Remove null values
      rpcParams.removeWhere((key, value) => value == null);

      final response = await _client.rpc(
        'get_nearby_professionals',
        params: rpcParams,
      );

      return (response as List<dynamic>)
          .map((json) => Professional.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get nearby professionals', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Professional>> getProfessionalsByService(String serviceId) async {
    try {
      final response = await _client.from('professionals').select('''
        *,
        profile:profiles (*),
        professional_services:professional_services (
          *,
          service:services (*)
        )
      ''').eq('professional_services.service_id', serviceId);

      return response
          .map((json) => Professional.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to get professionals by service', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Professional>> searchProfessionalsNearby(
      Position userLocation, double radiusInKm) async {
    try {
      final response = await _client.from('professionals').select('''
        *,
        profile:profiles (*),
        professional_services:professional_services (
          *,
          service:services (*)
        )
      ''').not('location_lat', 'is', null).not('location_lng', 'is', null);

      final professionals = (response as List)
          .map((data) => Professional.fromJson(data))
          .toList();

      return professionals.where((professional) {
        if (professional.locationLat == null ||
            professional.locationLng == null) return false;

        final distance = Geolocator.distanceBetween(
            userLocation.latitude,
            userLocation.longitude,
            professional.locationLat!,
            professional.locationLng!);

        return distance <= (radiusInKm * 1000); // Convert km to meters
      }).toList();
    } catch (e) {
      LoggerService.error('Failed to search professionals nearby', e);
      rethrow;
    }
  }

  Future<void> updateProfessionalLocation(
      String professionalId, double lat, double lng) async {
    try {
      await _client.from('professionals').update({
        'location_lat': lat,
        'location_lng': lng,
      }).eq('id', professionalId);
    } catch (e) {
      LoggerService.error('Failed to update professional location', e);
      rethrow;
    }
  }

  Future<void> updateProfessionalProfile(
    String professionalId, {
    String? bio,
    String? phoneNumber,
    String? licenseNumber,
    int? yearsOfExperience,
    List<String>? specialties,
    double? hourlyRate,
    bool? isAvailable,
  }) async {
    try {
      final updates = {
        if (bio != null) 'bio': bio,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        if (licenseNumber != null) 'license_number': licenseNumber,
        if (yearsOfExperience != null) 'years_of_experience': yearsOfExperience,
        if (specialties != null) 'specialties': specialties,
        if (hourlyRate != null) 'hourly_rate': hourlyRate,
        if (isAvailable != null) 'is_available': isAvailable,
      };

      if (updates.isEmpty) return;

      await _client
          .from('professionals')
          .update(updates)
          .eq('id', professionalId);
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to update professional profile', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateProfessionalAvailability(
      String professionalId, bool isAvailable) async {
    try {
      await _client
          .from('professionals')
          .update({'is_available': isAvailable}).eq('id', professionalId);
    } catch (e) {
      LoggerService.error('Failed to update professional availability', e);
      rethrow;
    }
  }

  Future<Professional?> getCurrentProfessional(String userId) async {
    try {
      final response = await _client.from('professionals').select('''
        *,
        profile:profiles (*),
        professional_services:professional_services (
          *,
          service:services (*)
        )
      ''').eq('id', userId).single();

      if (response == null) return null;
      return Professional.fromJson(response);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get current professional', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Professional>> getAllProfessionals() async {
    try {
      final response = await _client.from('professionals').select('''
        *,
        profile:profiles (*),
        professional_services:professional_services (
          *,
          service:services (*)
        )
      ''').order('created_at');

      return response.map((json) => Professional.fromJson(json)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get all professionals', e, stackTrace);
      rethrow;
    }
  }

  Future<void> addProfessionalService(
      String professionalId, String serviceId, double price) async {
    try {
      await _client.from('professional_services').insert({
        'professional_id': professionalId,
        'service_id': serviceId,
        'price': price,
      });
    } catch (e) {
      LoggerService.error('Failed to add professional service', e);
      rethrow;
    }
  }

  Future<void> removeProfessionalService(
      String professionalId, String serviceId) async {
    try {
      await _client
          .from('professional_services')
          .delete()
          .eq('professional_id', professionalId)
          .eq('service_id', serviceId);
    } catch (e) {
      LoggerService.error('Failed to remove professional service', e);
      rethrow;
    }
  }

  Future<List<Professional>> getTopRatedProfessionals({int limit = 10}) async {
    try {
      final response = await _client.from('professionals').select('''
        *,
        profile:profiles (*),
        professional_services:professional_services (
          *,
          service:services (*)
        )
      ''').order('rating', ascending: false).limit(limit);

      return (response as List)
          .map((data) => Professional.fromJson(data))
          .toList();
    } catch (e) {
      LoggerService.error('Failed to get top rated professionals', e);
      rethrow;
    }
  }
}
