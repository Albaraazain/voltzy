import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../core/services/logger_service.dart';
import '../models/job_model.dart';
import '../models/working_hours_model.dart' as wh;
import '../models/service_model.dart';
import '../models/profile_model.dart' as models;
import 'database_provider.dart';

class ProfessionalProvider extends ChangeNotifier {
  final DatabaseProvider _databaseProvider;
  final SupabaseClient _client = SupabaseConfig.client;

  bool _isAvailable = true;
  String _currentStatus = 'Available';
  List<Job> _activeJobs = [];
  List<Service> _services = [];
  List<wh.WorkingHours> _workingHours = [];
  bool _isLoading = false;

  ProfessionalProvider(this._databaseProvider) {
    _initialize();
  }

  bool get isAvailable => _isAvailable;
  String get currentStatus => _currentStatus;
  List<Job> get activeJobs => _activeJobs;
  List<Service> get services => _services;
  List<wh.WorkingHours> get workingHours => _workingHours;
  bool get isLoading => _isLoading;

  Future<void> _initialize() async {
    await Future.wait([
      loadAvailability(),
      loadActiveJobs(),
      loadServices(),
      loadWorkingHours(),
    ]);
  }

  Future<void> loadAvailability() async {
    try {
      _isLoading = true;
      notifyListeners();

      final professionalId = getCurrentProfessionalId();
      final response = await _client
          .from('professionals')
          .select('is_available')
          .eq('id', professionalId)
          .single();

      _isAvailable = response['is_available'] ?? false;
      _currentStatus = _isAvailable ? 'Available' : 'Unavailable';

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      LoggerService.error('Failed to load availability', e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadActiveJobs() async {
    try {
      _isLoading = true;
      notifyListeners();

      final professionalId = getCurrentProfessionalId();
      final response = await _client
          .from('jobs')
          .select('''
            *,
            homeowner:homeowners (
              *,
              profile:profiles (*)
            )
          ''')
          .eq('professional_id', professionalId)
          .or('status.in.(pending,accepted,in_progress)')
          .order('date', ascending: true);

      _activeJobs = response.map((job) => Job.fromJson(job)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      LoggerService.error('Failed to load active jobs', e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadServices() async {
    try {
      _isLoading = true;
      notifyListeners();

      final professionalId = getCurrentProfessionalId();
      LoggerService.info('Loading services for professional: $professionalId');

      final response = await _client
          .from('professionals')
          .select('services')
          .eq('id', professionalId)
          .single();

      LoggerService.debug('Services response: ${response['services']}');

      if (response['services'] != null) {
        _services = (response['services'] as List)
            .map((service) => Service.fromJson(service))
            .toList();
        LoggerService.info('Loaded ${_services.length} services');
      } else {
        _services = [];
        LoggerService.info('No services found');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      LoggerService.error('Failed to load services', e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadWorkingHours() async {
    try {
      _isLoading = true;
      notifyListeners();

      final professionalId = getCurrentProfessionalId();
      final response = await _client
          .from('professionals')
          .select('working_hours')
          .eq('id', professionalId)
          .single();

      if (response['working_hours'] != null) {
        _workingHours = List<wh.WorkingHours>.from(
          (response['working_hours'] as List<dynamic>).map(
            (wh) => wh.WorkingHours.fromJson(wh as Map<String, dynamic>),
          ),
        );
      } else {
        _workingHours =
            wh.WorkingHours.defaults(professionalId: professionalId);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      LoggerService.error('Failed to load working hours', e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateAvailability(bool available) async {
    try {
      final professionalId = getCurrentProfessionalId();
      await _client
          .from('professionals')
          .update({'is_available': available}).eq('id', professionalId);

      _isAvailable = available;
      _currentStatus = available ? 'Available' : 'Unavailable';
      notifyListeners();
    } catch (e) {
      LoggerService.error('Failed to update availability', e);
      rethrow;
    }
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    try {
      await _client.from('jobs').update({'status': status}).eq('id', jobId);

      await loadActiveJobs();
    } catch (e) {
      LoggerService.error('Failed to update job status', e);
      rethrow;
    }
  }

  Future<void> addService(Service service) async {
    try {
      final professionalId = getCurrentProfessionalId();
      LoggerService.info('Adding service for professional: $professionalId');
      LoggerService.debug('Service details: ${service.toJson()}');

      // Generate a unique ID for the service
      final newService = service.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      // Get current services and add the new one
      final updatedServices = [..._services, newService];
      LoggerService.debug(
          'Updated services: ${updatedServices.map((s) => s.toJson()).toList()}');

      // Update the services column
      await _client.from('professionals').update({
        'services': updatedServices.map((s) => s.toJson()).toList(),
      }).eq('id', professionalId);

      _services = updatedServices;
      LoggerService.info('Service added successfully');
      notifyListeners();

      // Refresh the database provider to update the UI
      await _databaseProvider.loadProfessionals();
    } catch (e) {
      LoggerService.error('Failed to add service', e);
      rethrow;
    }
  }

  Future<void> updateService(Service service) async {
    try {
      final professionalId = getCurrentProfessionalId();

      // Update the service in the list
      final updatedServices = _services.map((s) {
        if (s.id == service.id) {
          return service;
        }
        return s;
      }).toList();

      // Update the services column
      await _client.from('professionals').update({
        'services': updatedServices.map((s) => s.toJson()).toList(),
      }).eq('id', professionalId);

      _services = updatedServices;
      notifyListeners();
    } catch (e) {
      LoggerService.error('Failed to update service', e);
      rethrow;
    }
  }

  Future<void> deleteService(String serviceId) async {
    try {
      final professionalId = getCurrentProfessionalId();

      // Remove the service from the list
      final updatedServices =
          _services.where((s) => s.id != serviceId).toList();

      // Update the services column
      await _client.from('professionals').update({
        'services': updatedServices.map((s) => s.toJson()).toList(),
      }).eq('id', professionalId);

      _services = updatedServices;
      notifyListeners();
    } catch (e) {
      LoggerService.error('Failed to delete service', e);
      rethrow;
    }
  }

  Future<void> updateWorkingHours(wh.WorkingHours workingHours) async {
    try {
      final professionalId = getCurrentProfessionalId();
      await _client.from('professionals').update(
          {'working_hours': workingHours.toJson()}).eq('id', professionalId);

      notifyListeners();
    } catch (e) {
      LoggerService.error('Failed to update working hours', e);
      rethrow;
    }
  }

  String getCurrentProfessionalId() {
    if (_databaseProvider.currentProfile == null ||
        _databaseProvider.currentProfile!.userType !=
            models.UserType.professional) {
      throw Exception('No professional is currently logged in');
    }

    final professional = _databaseProvider.professionals.firstWhere(
      (e) => e.profile.id == _databaseProvider.currentProfile!.id,
      orElse: () => throw Exception('Professional profile not found'),
    );

    return professional.id;
  }
}
