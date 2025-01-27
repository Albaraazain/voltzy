import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/logger_service.dart';
import '../models/base_service_model.dart';
import '../models/category_model.dart';
import '../models/professional_service_model.dart';
import '../models/service_category_model.dart';

class ServiceRepository {
  final SupabaseClient _client;

  ServiceRepository(this._client);

  // Base Service Operations
  Future<List<BaseService>> getAllBaseServices() async {
    try {
      final response = await _client
          .from('services')
          .select()
          .filter('deleted_at', 'is', null)
          .order('name');

      return response.map((row) => BaseService.fromJson(row)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load base services', e, stackTrace);
      rethrow;
    }
  }

  Future<List<BaseService>> getServicesByCategory(String categoryId) async {
    try {
      final response = await _client
          .from('services')
          .select()
          .eq('category_id', categoryId)
          .order('name');

      return (response as List)
          .map((data) => BaseService.fromJson(data))
          .toList();
    } catch (e) {
      LoggerService.error('Failed to get services by category', e);
      rethrow;
    }
  }

  Future<BaseService?> getBaseServiceById(String id) async {
    try {
      final response = await _client
          .from('services')
          .select()
          .eq('id', id)
          .filter('deleted_at', 'is', null)
          .single();

      return response == null ? null : BaseService.fromJson(response);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get base service', e, stackTrace);
      rethrow;
    }
  }

  // Category Operations
  Future<List<Category>> getAllCategories() async {
    try {
      final response = await _client
          .from('service_categories')
          .select()
          .eq('deleted_at', '')
          .order('name');

      return (response as List)
          .map((data) => Category.fromJson(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.error('Failed to get service categories', e);
      rethrow;
    }
  }

  Future<ServiceCategory?> getCategoryById(String id) async {
    try {
      final response = await _client
          .from('service_categories')
          .select()
          .eq('id', id)
          .filter('deleted_at', 'is', null)
          .single();

      return response == null ? null : ServiceCategory.fromJson(response);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get category', e, stackTrace);
      rethrow;
    }
  }

  // Professional Service Operations
  Future<List<ProfessionalService>> getProfessionalServices(
      String professionalId) async {
    try {
      final response = await _client.from('professional_services').select('''
            *,
            service:services (*)
          ''').eq('professional_id', professionalId);

      return response.map((row) {
        final baseService = BaseService.fromJson(row['service']);
        return ProfessionalService.fromJson(row, baseService);
      }).toList();
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to load professional services', e, stackTrace);
      rethrow;
    }
  }

  Future<ProfessionalService> addServiceToProfessional({
    required String professionalId,
    required String serviceId,
    double? customPrice,
    double? customDuration,
  }) async {
    try {
      // First get the base service
      final baseService = await getBaseServiceById(serviceId);
      if (baseService == null) throw Exception('Base service not found');

      // Add professional service
      final response = await _client
          .from('professional_services')
          .insert({
            'professional_id': professionalId,
            'service_id': serviceId,
            'custom_price': customPrice,
            'custom_duration': customDuration,
            'is_active': true,
            'available_today': true,
          })
          .select('*, service:services (*)')
          .single();

      return ProfessionalService.fromJson(response, baseService);
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to add service to professional', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> toggleServiceActive(
      String professionalId, String serviceId, bool isActive) async {
    try {
      LoggerService.debug(
          'Toggling service $serviceId active state to $isActive for professional $professionalId');

      await _client
          .from('professional_services')
          .update({'is_active': isActive}).match({
        'service_id': serviceId,
        'professional_id': professionalId,
      });

      return true;
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to toggle service active state', e, stackTrace);
      return false;
    }
  }

  Future<bool> toggleServiceAvailability(
      String professionalId, String serviceId, bool availableToday) async {
    try {
      LoggerService.debug(
          'Toggling service $serviceId availability to $availableToday for professional $professionalId');

      await _client
          .from('professional_services')
          .update({'available_today': availableToday}).match({
        'service_id': serviceId,
        'professional_id': professionalId,
      });

      return true;
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to toggle service availability', e, stackTrace);
      return false;
    }
  }

  Future<ProfessionalService> getProfessionalServiceById(
      String serviceId, String professionalId) async {
    try {
      final response = await _client.from('professional_services').select('''
            *,
            service:services (*)
          ''').match({
        'service_id': serviceId,
        'professional_id': professionalId,
      }).single();

      final baseService = BaseService.fromJson(response['service']);
      return ProfessionalService.fromJson(response, baseService);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get professional service', e, stackTrace);
      rethrow;
    }
  }

  Future<void> removeServiceFromProfessional(
      String professionalId, String serviceId) async {
    try {
      await _client.from('professional_services').delete().match({
        'professional_id': professionalId,
        'service_id': serviceId,
      });
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
    double? customDuration,
    bool? isActive,
  }) async {
    try {
      final updates = {
        if (customPrice != null) 'custom_price': customPrice,
        if (customDuration != null) 'custom_duration': customDuration,
        if (isActive != null) 'is_active': isActive,
      };

      if (updates.isEmpty) return;

      await _client.from('professional_services').update(updates).match({
        'professional_id': professionalId,
        'service_id': serviceId,
      });
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to update professional service', e, stackTrace);
      rethrow;
    }
  }

  Future<List<BaseService>> searchServices(String query) async {
    try {
      final response = await _client
          .from('services')
          .select()
          .ilike('name', '%$query%')
          .order('name');

      return (response as List)
          .map((data) => BaseService.fromJson(data))
          .toList();
    } catch (e) {
      LoggerService.error('Failed to search services', e);
      rethrow;
    }
  }

  Future<Map<String, double>> getBaseServicePriceRange(String serviceId) async {
    try {
      final response = await _client
          .from('professional_services')
          .select('custom_price')
          .eq('service_id', serviceId)
          .not('custom_price', 'is', null);

      final prices = (response as List)
          .map((row) => (row['custom_price'] as num).toDouble())
          .toList();

      if (prices.isEmpty) {
        final baseService = await getBaseServiceById(serviceId);
        if (baseService == null) throw Exception('Base service not found');
        return {
          'min': baseService.basePrice,
          'max': baseService.basePrice,
          'avg': baseService.basePrice,
        };
      }

      prices.sort();
      final min = prices.first;
      final max = prices.last;
      final avg = prices.reduce((a, b) => a + b) / prices.length;

      return {
        'min': min,
        'max': max,
        'avg': avg,
      };
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to get base service price range', e, stackTrace);
      rethrow;
    }
  }
}
