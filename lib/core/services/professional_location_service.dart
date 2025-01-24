import 'package:geolocator/geolocator.dart';
import '../config/supabase_config.dart';
import 'logger_service.dart';
import 'location_service.dart';

class ProfessionalLocationService {
  final _supabase = SupabaseConfig.client;

  Future<List<Map<String, dynamic>>> findNearbyProfessionals(
      double latitude, double longitude,
      {double radius = 10}) async {
    try {
      LoggerService.debug(
          'Finding nearby professionals at ($latitude, $longitude) within ${radius}km');

      final response =
          await _supabase.rpc('find_nearby_professionals', params: {
        'user_lat': latitude,
        'user_lon': longitude,
        'radius_km': radius,
      });

      LoggerService.debug('Raw response from Supabase: $response');

      if (response == null) {
        LoggerService.error('Null response from Supabase');
        return [];
      }

      // Handle the response data directly since it's already a List
      final List<dynamic> professionals = response;
      LoggerService.debug('Found ${professionals.length} nearby professionals');

      return professionals.map((e) => e as Map<String, dynamic>).toList();
    } catch (e, stackTrace) {
      LoggerService.error(
          'Error finding nearby professionals: $e\n$stackTrace');
      return [];
    }
  }

  Future<void> updateProfessionalLocation(String userId) async {
    try {
      final location = await LocationService.getCurrentLocation();
      await _supabase.from('professionals').update({
        'location_lat': location.latitude,
        'location_lng': location.longitude,
        'last_location_update': DateTime.now().toIso8601String(),
      }).eq('profile_id', userId);
      LoggerService.debug('Location updated for professional: $userId');
    } catch (e) {
      LoggerService.error('Error updating professional location: $e');
    }
  }

  Stream<Position> getLocationStream() {
    return LocationService.getLocationStream();
  }

  Future<void> startLocationTracking(String userId) async {
    try {
      final initialPosition = await LocationService.getCurrentLocation();

      getLocationStream().listen((Position position) async {
        await _supabase.from('professionals').update({
          'latitude': position.latitude,
          'longitude': position.longitude,
          'last_location_update': DateTime.now().toIso8601String(),
        }).eq('profile_id', userId);

        LoggerService.debug(
          'professional location updated - Lat: ${position.latitude}, Lon: ${position.longitude}',
        );
      });
    } catch (e) {
      LoggerService.error('Error starting location tracking: $e');
    }
  }

  Future<void> updateServiceRadius(String userId, double radiusKm) async {
    try {
      await _supabase.from('professionals').update({
        'service_radius_km': radiusKm,
      }).eq('profile_id', userId);

      LoggerService.debug('Service radius updated for professional: $userId');
    } catch (e) {
      LoggerService.error('Error updating service radius: $e');
    }
  }
}
