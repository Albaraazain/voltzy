import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/logger_service.dart';
import '../models/service_model.dart';
import '../models/service_category_model.dart';

class ServiceRepository {
  final SupabaseClient _client;

  ServiceRepository(this._client);

  Future<List<Service>> getAllServices() async {
    try {
      final response = await _client
          .from('services')
          .select()
          .filter('deleted_at', 'is', null)
          .order('name');

      return response.map((row) => Service.fromJson(row)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load services', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Service>> getServicesByCategory(String categoryId) async {
    try {
      final response = await _client
          .from('services')
          .select()
          .eq('category_id', categoryId)
          .filter('deleted_at', 'is', null)
          .order('name');

      return response.map((row) => Service.fromJson(row)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load services by category', e, stackTrace);
      rethrow;
    }
  }

  Future<Service> createService({
    required String categoryId,
    required String name,
    String? description,
    double? basePrice,
    int? estimatedDuration,
  }) async {
    try {
      final response = await _client
          .from('services')
          .insert({
            'category_id': categoryId,
            'name': name,
            'description': description,
            'base_price': basePrice,
            'estimated_duration': estimatedDuration,
          })
          .select()
          .single();

      return Service.fromJson(response);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to create service', e, stackTrace);
      rethrow;
    }
  }

  Future<Service> updateService(
    String serviceId, {
    String? name,
    String? description,
    double? basePrice,
    int? estimatedDuration,
  }) async {
    try {
      final updates = {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (basePrice != null) 'base_price': basePrice,
        if (estimatedDuration != null) 'estimated_duration': estimatedDuration,
      };

      if (updates.isEmpty) return getService(serviceId);

      final response = await _client
          .from('services')
          .update(updates)
          .eq('id', serviceId)
          .select()
          .single();

      return Service.fromJson(response);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update service', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      await _client.from('services').update(
          {'deleted_at': DateTime.now().toIso8601String()}).eq('id', serviceId);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to delete service', e, stackTrace);
      rethrow;
    }
  }

  Future<Service> getService(String serviceId) async {
    try {
      final response = await _client
          .from('services')
          .select()
          .eq('id', serviceId)
          .filter('deleted_at', 'is', null)
          .single();

      return Service.fromJson(response);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get service', e, stackTrace);
      rethrow;
    }
  }

  Future<List<ServiceCategory>> getAllCategories() async {
    try {
      final response = await _client
          .from('service_categories')
          .select()
          .filter('deleted_at', 'is', null)
          .order('name');

      return response.map((row) => ServiceCategory.fromJson(row)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load service categories', e, stackTrace);
      rethrow;
    }
  }
}
