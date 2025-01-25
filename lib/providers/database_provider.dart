import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/logger_service.dart';
import '../models/professional_model.dart';
import '../models/homeowner_model.dart';
import '../models/profile_model.dart' as profile_models;
import '../models/job_model.dart';
import '../models/review_model.dart';
import '../models/service_model.dart';
import '../models/working_hours_model.dart';
import '../models/payment_info_model.dart';
import '../models/notification_preferences_model.dart';
import 'auth_provider.dart';
import '../models/schedule_slot_model.dart' as schedule;
import '../models/category_model.dart' as category_model;
import '../core/config/supabase_config.dart';
import '../core/utils/api_response.dart';
import '../models/service_category_model.dart';
import '../features/homeowner/models/service.dart';

// Import the USE_DEVELOPMENT_ENV constant

class DatabaseProvider with ChangeNotifier {
  late final SupabaseClient _client;
  final AuthProvider _authProvider;
  List<Professional> _professionals = [];
  Homeowner? _currentHomeowner;
  profile_models.Profile? _currentProfile;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  DatabaseProvider(this._authProvider) {
    _client = _authProvider.client;
    _initialize();
    _authProvider.addListener(_onAuthStateChanged);
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    try {
      // Wait for auth to be initialized first
      await _authProvider.initializationCompleted;

      if (_authProvider.isAuthenticated) {
        await loadInitialData();
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to initialize database provider', e, stackTrace);
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void _onAuthStateChanged() async {
    if (_authProvider.isAuthenticated) {
      // Reset state before loading new data
      _currentHomeowner = null;
      _currentProfile = null;
      _professionals = [];
      _isInitialized = false;
      notifyListeners();

      // Load new data
      await loadInitialData();
    } else {
      // Clear all state on sign out
      _currentHomeowner = null;
      _currentProfile = null;
      _professionals = [];
      _isInitialized = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Expose client for debugging
  SupabaseClient get client => _client;

  List<Professional> get professionals => _professionals;
  Homeowner? get currentHomeowner => _currentHomeowner;
  profile_models.Profile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCurrentProfile() async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      notifyListeners();

      final userId = _authProvider.userId;
      if (userId == null) {
        LoggerService.debug('No user ID available');
        return;
      }

      LoggerService.info('Loading profile for user: $userId');

      final profileResponse =
          await _client.from('profiles').select().eq('id', userId).single();

      _currentProfile = profile_models.Profile.fromJson(profileResponse);
      notifyListeners();

      if (_currentProfile?.userType == profile_models.UserType.professional) {
        await _loadProfessionalData();
      } else if (_currentProfile?.userType ==
          profile_models.UserType.homeowner) {
        await _loadHomeownerData();
        await loadProfessionals();
      }
    } catch (e, stackTrace) {
      LoggerService.debug('Error loading profile: $e\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInitialData() async {
    if (!_authProvider.isAuthenticated) return;

    try {
      _isLoading = true;
      notifyListeners();

      final userId = _authProvider.userId;
      if (userId == null) {
        LoggerService.debug('No user ID available');
        return;
      }

      // Load profile first
      final profileResponse =
          await _client.from('profiles').select().eq('id', userId).single();

      _currentProfile = profile_models.Profile.fromJson(profileResponse);
      LoggerService.debug('Current profile type: ${_currentProfile?.userType}');

      // Load role-specific data based on user type
      if (_currentProfile?.userType == profile_models.UserType.professional) {
        await _loadProfessionalData();
        // For professionals, we only need their own profile
        await loadProfessionals();
      } else if (_currentProfile?.userType ==
          profile_models.UserType.homeowner) {
        await _loadHomeownerData();
        // For homeowners, we load all verified professionals
        await loadProfessionals();
      }

      notifyListeners();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load initial data', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadProfessionalData() async {
    try {
      LoggerService.info(
          'Loading professional data for profile: ${_currentProfile!.id}');

      final queryString = '''
        *,
        hourly_rate::float as hourly_rate,
        profile:profiles (
          id,
          email,
          user_type,
          name,
          created_at,
          last_login_at
        )
      ''';

      final professionalResponse = await _client
          .from('professionals')
          .select(queryString)
          .eq('profile_id', _currentProfile!.id)
          .single();

      // Store the professional data in the _professionals list
      final userProfile =
          profile_models.Profile.fromJson(professionalResponse['profile']);
      _professionals = [
        Professional.fromJson({
          ...professionalResponse,
          'profile': userProfile.toJson(),
        })
      ];

      LoggerService.info('Successfully loaded professional profile');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load professional data', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _loadHomeownerData() async {
    try {
      LoggerService.info(
          'Loading homeowner data for profile: ${_currentProfile!.id}');
      final homeownerResponse = await _client
          .from('homeowners')
          .select()
          .eq('profile_id', _currentProfile!.id)
          .single();
      LoggerService.debug('Loaded homeowner data: $homeownerResponse');
      _currentHomeowner = Homeowner.fromJson(
        homeownerResponse,
        profile: _currentProfile!,
      );
      LoggerService.info('Successfully loaded homeowner profile');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load homeowner data', e, stackTrace);
      rethrow;
    }
  }

  Future<void> loadProfessionals() async {
    try {
      LoggerService.debug('🔄 Starting to load professionals...');

      final response = await _client.from('professionals').select('''
        *,
        profile:profiles!professionals_profile_id_fkey (*),
        services:professional_services (
          service:services (*)
        )
      ''');

      LoggerService.debug(
          '📥 Received ${response.length} professionals from database');

      final List<Professional> professionals = [];
      for (final row in response) {
        try {
          if (row['profile'] == null) {
            LoggerService.error(
                '❌ Professional has no profile data: ${row['id']}');
            continue;
          }

          final profileData = row['profile'] as Map<String, dynamic>;
          LoggerService.debug(
              '📋 Processing professional ${row['id']} with profile data: $profileData');

          final profile = profile_models.Profile.fromJson(profileData);

          if (profile.userType == profile_models.UserType.professional) {
            try {
              // Extract services from the junction table data
              final services = (row['services'] as List<dynamic>?)
                      ?.map((s) => Service.fromJson(
                          s['service'] as Map<String, dynamic>))
                      .toList() ??
                  [];

              // Combine profile data with professional data
              final professionalData = {
                ...row,
                'name': profile.name,
                'email': profile.email,
                'created_at':
                    row['created_at'] ?? profile.createdAt.toIso8601String(),
                'updated_at':
                    row['updated_at'] ?? DateTime.now().toIso8601String(),
                'profile': profile.toJson(),
                'services': services,
              };

              LoggerService.debug(
                  '🔨 Constructed professional data: $professionalData');

              professionals.add(Professional.fromJson(professionalData));
              LoggerService.debug(
                  '✅ Successfully added professional ${row['id']}');
            } catch (e, stackTrace) {
              LoggerService.error(
                '❌ Failed to parse professional data for ID: ${row['id']}',
                e,
                stackTrace,
              );
            }
          }
        } catch (e, stackTrace) {
          LoggerService.error(
            '❌ Failed to parse profile data for professional',
            e,
            stackTrace,
          );
        }
      }

      _professionals = professionals;
      LoggerService.info(
          '✅ Successfully loaded ${professionals.length} professionals');
      notifyListeners();
    } catch (e, stackTrace) {
      LoggerService.error('❌ Failed to load professionals list', e, stackTrace);
      rethrow;
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    if (lat1 == 0 || lon1 == 0 || lat2 == 0 || lon2 == 0) {
      LoggerService.debug(
          'Invalid coordinates detected: ($lat1, $lon1) -> ($lat2, $lon2)');
      return double.infinity;
    }

    const double earthRadius = 6371; // Radius of the earth in km

    // Convert degrees to radians
    final double lat1Rad = lat1 * pi / 180;
    final double lon1Rad = lon1 * pi / 180;
    final double lat2Rad = lat2 * pi / 180;
    final double lon2Rad = lon2 * pi / 180;

    // Haversine formula
    final double dLat = lat2Rad - lat1Rad;
    final double dLon = lon2Rad - lon1Rad;
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;

    LoggerService.debug(
        'Distance calculated: ${distance.toStringAsFixed(2)}km between ($lat1, $lon1) -> ($lat2, $lon2)');
    return distance;
  }

  Future<List<Professional>> findProfessionalsWithinRadius(
      double lat, double lng, double radiusKm) async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to search professionals');
      }

      final professionals = _professionals.where((professional) {
        if (professional.locationLat == null ||
            professional.locationLng == null) {
          return false;
        }
        final distance = calculateDistance(
          lat,
          lng,
          professional.locationLat!,
          professional.locationLng!,
        );
        return distance <= radiusKm;
      }).toList();

      return professionals;
    } catch (e) {
      LoggerService.error('Error finding professionals within radius: $e');
      rethrow;
    }
  }

  Future<void> addProfessional(Professional professional) async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to add an professional');
      }

      await _client.from('professionals').upsert(professional.toJson());
      await loadProfessionals();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to add professional', e, stackTrace);
      rethrow;
    }
  }

  Future<void> clearAllData() async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to clear data');
      }

      await _client.from('jobs').delete().neq('id', '0');
      await _client.from('professionals').delete().neq('id', '0');
      await _client.from('homeowners').delete().neq('id', '0');
      await loadProfessionals();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to clear data', e, stackTrace);
      rethrow;
    }
  }

  Future<void> initializeData() async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to initialize data');
      }

      // Sample profiles data
      final profiles = [
        {
          'id': '1',
          'email': 'john@example.com',
          'user_type': 'professional',
          'name': 'John Doe',
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'email': 'jane@example.com',
          'user_type': 'professional',
          'name': 'Jane Smith',
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      // Insert sample profiles
      for (final profile in profiles) {
        await _client.from('profiles').upsert(profile);
      }

      // Sample professionals data
      final professionals = [
        {
          'id': '1',
          'profile_id': '1',
          'rating': 4.5,
          'jobs_completed': 25,
          'hourly_rate': 75.0,
          'is_available': true,
          'specialties': ['Residential', 'Commercial'],
          'license_number': 'EL123456',
          'years_of_experience': 5,
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'profile_id': '2',
          'rating': 4.8,
          'jobs_completed': 42,
          'hourly_rate': 85.0,
          'is_available': true,
          'specialties': ['Emergency', 'Installation'],
          'license_number': 'EL789012',
          'years_of_experience': 8,
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      // Insert sample professionals
      for (final professional in professionals) {
        await _client.from('professionals').upsert(professional);
      }

      // Sample jobs data
      final jobs = [
        {
          'id': '1',
          'homeowner_id': _authProvider.userId,
          'professional_id': '1',
          'title': 'Fix Kitchen Lights',
          'description': 'Kitchen lights are flickering and need repair',
          'status': 'pending',
          'date': DateTime.now().toIso8601String(),
          'price': 150.0,
          'created_at': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'homeowner_id': _authProvider.userId,
          'professional_id': '2',
          'title': 'Install Outdoor Lighting',
          'description': 'Need to install outdoor security lights',
          'status': 'completed',
          'date': DateTime.now().toIso8601String(),
          'price': 300.0,
          'created_at': DateTime.now().toIso8601String(),
        },
      ];

      // Insert sample jobs
      for (final job in jobs) {
        await _client.from('jobs').upsert(job);
      }

      await loadProfessionals();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to initialize data', e, stackTrace);
      rethrow;
    }
  }

  // Job Management Methods
  Future<List<Job>> loadJobs({String? status}) async {
    try {
      LoggerService.info('Loading jobs');
      if (!_authProvider.isAuthenticated) {
        throw Exception('User not authenticated');
      }

      var query = _client.from('jobs').select('''
        *,
        professional:professionals (
          id,
          profile:profiles (
            id,
            name,
            email
          )
        ),
        homeowner:homeowners!inner (
          id,
          profile:profiles!inner (
            id,
            name,
            email
          )
        )
      ''');

      // Filter based on user type and status
      if (_currentProfile?.userType.name == 'homeowner') {
        query = query.eq('homeowner_id', _currentProfile!.id);
      } else if (_currentProfile?.userType.name == 'professional') {
        query = query.eq('professional_id', _currentProfile!.id);
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      LoggerService.debug(
          'Executing jobs query for user type: ${_currentProfile?.userType}');
      LoggerService.debug('User ID: ${_currentProfile?.id}');

      final response = await query.order('created_at', ascending: false);
      LoggerService.debug('Jobs query response: $response');

      return response.map((data) => Job.fromJson(data)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load jobs', e, stackTrace);
      rethrow;
    }
  }

  Future<Job> createJob(Job job) async {
    try {
      LoggerService.info('Creating job: ${job.title}');
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to create a job');
      }

      final response =
          await _client.from('jobs').insert(job.toJson()).select().single();

      return Job.fromJson(response);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to create job', e, stackTrace);
      rethrow;
    }
  }

  Future<Job> updateJob(Job job) async {
    try {
      LoggerService.info('Updating job: ${job.id}');
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to update a job');
      }

      final response = await _client
          .from('jobs')
          .update(job.toJson())
          .eq('id', job.id)
          .select()
          .single();

      return Job.fromJson(response);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update job', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to delete a job');
      }

      await _client.from('jobs').delete().eq('id', jobId);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to delete job', e, stackTrace);
      rethrow;
    }
  }

  // Profile Management Methods
  Future<void> updateProfile(profile_models.Profile profile) async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to update profile');
      }

      await _client
          .from('profiles')
          .update(profile.toJson())
          .eq('id', profile.id);
      await loadCurrentProfile();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update profile', e, stackTrace);
      rethrow;
    }
  }

  Future<String> uploadProfileImage(File file) async {
    try {
      LoggerService.info('Uploading profile image');
      if (!_authProvider.isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final fileName =
          '${_currentProfile!.id}_${DateTime.now().millisecondsSinceEpoch}';
      await _client.storage.from('profile_images').upload(fileName, file);

      final imageUrl =
          _client.storage.from('profile_images').getPublicUrl(fileName);

      return imageUrl;
    } catch (e, stackTrace) {
      LoggerService.error('Failed to upload profile image', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateProfessionalProfile(Professional professional) async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception(
            'User must be authenticated to update professional profile');
      }

      final data = professional.toJson();
      data['hourly_rate'] = (data['hourly_rate'] as num).toDouble();

      await _client
          .from('professionals')
          .update(data)
          .eq('id', professional.id);

      await loadProfessionals();
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to update professional profile', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateProfessionalLocation(double lat, double lng) async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to update location');
      }

      final professional = _professionals.firstWhere(
        (e) => e.profile.id == _currentProfile!.id,
        orElse: () => throw Exception('Professional not found'),
      );

      await _client.from('professionals').update({
        'location_lat': lat,
        'location_lng': lng,
      }).eq('id', professional.id);

      // Update local state
      final index = _professionals.indexWhere((p) => p.id == professional.id);
      if (index != -1) {
        _professionals[index] = professional.copyWith(
          locationLat: lat,
          locationLng: lng,
        );
        notifyListeners();
      }
    } catch (e) {
      LoggerService.error('Error updating professional location: $e');
      rethrow;
    }
  }

  Future<void> updateProfessionalAvailability(
      String professionalId, bool isAvailable) async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to update availability');
      }

      await _client
          .from('professionals')
          .update({'is_available': isAvailable}).eq('id', professionalId);

      await loadProfessionals();
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to update professional availability', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateProfessionalServices(
      String professionalId, List<String> serviceIds) async {
    try {
      // Delete existing service relationships
      await _client
          .from('professional_services')
          .delete()
          .eq('professional_id', professionalId);

      // Insert new service relationships
      if (serviceIds.isNotEmpty) {
        final serviceRelations = serviceIds
            .map((serviceId) => {
                  'professional_id': professionalId,
                  'service_id': serviceId,
                })
            .toList();

        await _client.from('professional_services').insert(serviceRelations);
      }

      // Update local state
      await loadProfessionals();
    } catch (e) {
      LoggerService.error('Failed to update professional services', e);
      rethrow;
    }
  }

  Future<List<Service>> getServicesByIds(List<String> serviceIds) async {
    try {
      final response = await _client
          .from('services')
          .select()
          .filter('id', 'in', serviceIds);

      final List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(response);
      return data.map((item) => Service.fromJson(item)).toList();
    } catch (e) {
      LoggerService.error('Failed to get services by IDs', e);
      rethrow;
    }
  }

  Future<void> addService(String professionalId, String serviceId) async {
    try {
      final professional =
          _professionals.firstWhere((e) => e.id == professionalId);
      final currentServiceIds = professional.services.map((s) => s.id).toList();
      if (!currentServiceIds.contains(serviceId)) {
        await updateProfessionalServices(
            professionalId, [...currentServiceIds, serviceId]);
      }
    } catch (e) {
      LoggerService.error('Failed to add service', e);
      rethrow;
    }
  }

  Future<void> removeService(String professionalId, String serviceId) async {
    try {
      final professional =
          _professionals.firstWhere((e) => e.id == professionalId);
      final currentServiceIds = professional.services.map((s) => s.id).toList();
      if (currentServiceIds.contains(serviceId)) {
        await updateProfessionalServices(
          professionalId,
          currentServiceIds.where((id) => id != serviceId).toList(),
        );
      }
    } catch (e) {
      LoggerService.error('Failed to remove service', e);
      rethrow;
    }
  }

  Future<void> updateProfessionalWorkingHours(
      String professionalId, List<WorkingHours> workingHours) async {
    try {
      final hoursJson = workingHours.map((w) => w.toJson()).toList();
      await _client.from('professionals').update({
        'working_hours': hoursJson,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', professionalId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfessionalPaymentInfo(PaymentInfo paymentInfo) async {
    try {
      final currentProfessional = _professionals.firstWhere(
        (e) => e.profile.id == currentProfile?.id,
      );

      // Update the professional in the database with the payment info as JSONB
      await _client.from('professionals').update({
        'payment_info': paymentInfo.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentProfessional.id);

      // Update local state with the new payment info
      final index =
          _professionals.indexWhere((p) => p.id == currentProfessional.id);
      if (index != -1) {
        _professionals[index] = currentProfessional.copyWith(
          paymentInfo: paymentInfo,
          updatedAt: DateTime.now(),
        );
      }

      notifyListeners();
    } catch (e) {
      LoggerService.error('Error updating payment info: $e');
      rethrow;
    }
  }

  Future<void> updateProfessionalRating(
      String professionalId, double? rating) async {
    try {
      if (rating == null) return;
      final num ratingValue = rating;
      await _client.from('professionals').update({
        'rating': ratingValue,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', professionalId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfessionalNotificationPreferences(
      NotificationPreferences preferences) async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception(
            'User must be authenticated to update notification preferences');
      }

      final professional = _professionals.firstWhere(
          (e) => e.profile.id == _currentProfile!.id,
          orElse: () => throw Exception('Professional not found'));

      await _client
          .from('professionals')
          .update({'notificationPreferences': preferences.toJson()}).eq(
              'id', professional.id);

      await loadProfessionals();
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to update notification preferences', e, stackTrace);
      rethrow;
    }
  }

  // Real-time subscriptions
  void subscribeToJobs(void Function(Job) onJobUpdate) {
    _client
        .from('jobs')
        .stream(primaryKey: ['id']).listen((List<Map<String, dynamic>> data) {
      if (data.isNotEmpty) {
        final job = Job.fromJson(data.first);
        onJobUpdate(job);
      }
    });
  }

  // Professional Management Methods
  Future<void> searchProfessionals({
    String? searchQuery,
    List<String>? specialties,
    double? minRating,
    double? maxPrice,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final query = _client.from('professionals').select('''
            *,
            hourly_rate::float as hourly_rate,
            profile:profiles (
              id,
              email,
              user_type,
              name,
              created_at
            )
          ''').eq('is_verified', true);

      // Apply filters using filter() for complex queries
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query.filter('profile.name', 'ilike', '%$searchQuery%');
      }

      if (specialties != null && specialties.isNotEmpty) {
        query.filter('specialties', 'cs', specialties);
      }

      if (minRating != null) {
        query.filter('rating', 'gte', minRating);
      }

      if (maxPrice != null) {
        query.filter('hourly_rate', 'lte', maxPrice);
      }

      // Apply pagination and ordering
      final response = await query
          .range(offset, offset + limit - 1)
          .order('rating', ascending: false);

      _professionals = response.map((data) {
        final profile = profile_models.Profile.fromJson(data['profile']);
        return Professional.fromJson(data);
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      LoggerService.error('Failed to load professionals', e, stackTrace);
      notifyListeners();
      rethrow;
    }
  }

  // Cache Management
  final Map<String, dynamic> _cache = {};
  final Duration _cacheDuration = const Duration(minutes: 15);

  Future<T> _withCache<T>(String key, Future<T> Function() fetchData) async {
    final cacheEntry = _cache[key];
    if (cacheEntry != null) {
      final timestamp = cacheEntry['timestamp'] as DateTime;
      if (DateTime.now().difference(timestamp) < _cacheDuration) {
        return cacheEntry['data'] as T;
      }
    }

    final data = await fetchData();
    _cache[key] = {
      'data': data,
      'timestamp': DateTime.now(),
    };
    return data;
  }

  void clearCache() {
    _cache.clear();
  }

  // Enhanced Job Search
  Future<List<Job>> searchJobs({
    String? searchQuery,
    String? status,
    String? professionalId,
    String? homeownerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _client.from('jobs').select();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query
            .or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      if (status != null) {
        query = query.eq('status', status);
      }

      if (professionalId != null) {
        query = query.eq('professional_id', professionalId);
      }

      if (homeownerId != null) {
        query = query.eq('homeowner_id', homeownerId);
      }

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String());
      }

      final response = await query.order('created_at', ascending: false);

      return response.map((data) => Job.fromJson(data)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to search jobs', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Review>> getProfessionalReviews(String professionalId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('''
            *,
            reviewer:profiles!reviewer_id(*)
          ''')
          .eq('professional_id', professionalId)
          .order('created_at', ascending: false);

      return response.map((review) => Review.fromJson(review)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get professional reviews', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Job>> getJobsForProfessional(String professionalId) async {
    try {
      final response = await _client
          .from('jobs')
          .select()
          .eq('professional_id', professionalId);
      return response.map((job) => Job.fromJson(job)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get jobs for professional', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Job>> getJobsForHomeowner(String homeownerId) async {
    try {
      final response =
          await _client.from('jobs').select().eq('homeowner_id', homeownerId);
      return response.map((job) => Job.fromJson(job)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get jobs for homeowner', e, stackTrace);
      rethrow;
    }
  }

  Future<Job> getJob(String jobId) async {
    try {
      final response = await _client.from('jobs').select('''
            *,
            homeowner:homeowners!homeowner_id (
              id,
              profile_id,
              phone,
              address,
              preferred_contact_method,
              emergency_contact,
              created_at,
              profile:profiles!profile_id (
                id,
                email,
                user_type,
                name,
                created_at,
                last_login_at
              )
            ),
            professional:professionals(professional_id) (
              id,
              profile_id,
              profile_image,
              phone,
              license_number,
              years_of_experience,
              hourly_rate,
              rating,
              jobs_completed,
              is_available,
              is_verified,
              services,
              specialties,
              profile:profiles (
                id,
                email,
                user_type,
                name,
                created_at,
                last_login_at
              )
            )
          ''').eq('id', jobId).single();

      return Job.fromJson(response);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get job', e, stackTrace);
      throw Exception('Failed to get job: $e');
    }
  }

  Future<List<Review>> getReviewsForProfessional(String professionalId) async {
    try {
      final response = await _client
          .from('reviews')
          .select()
          .eq('reviewee_id', professionalId)
          .eq('reviewer_type', 'HOMEOWNER');
      return response.map((review) => Review.fromJson(review)).toList();
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to get reviews for professional', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updatePaymentInfo(PaymentInfo paymentInfo) async {
    if (!_authProvider.isAuthenticated) {
      throw Exception(
          'User must be authenticated to update payment information');
    }

    try {
      final currentProfessional = _professionals.firstWhere(
        (e) => e.profile.id == currentProfile?.id,
      );

      // Update the professional in the database with the payment info as JSONB
      await _client.from('professionals').update({
        'payment_info': paymentInfo.toJson(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', currentProfessional.id);

      // Update local state with the new payment info
      final index =
          _professionals.indexWhere((p) => p.id == currentProfessional.id);
      if (index != -1) {
        _professionals[index] = currentProfessional.copyWith(
          paymentInfo: paymentInfo,
          updatedAt: DateTime.now(),
        );
      }

      notifyListeners();
    } catch (e) {
      LoggerService.error('Error updating payment info: $e');
      rethrow;
    }
  }

  Future<void> updateHomeownerNotificationPreferences({
    required bool jobUpdates,
    required bool messages,
    required bool payments,
    required bool promotions,
  }) async {
    try {
      if (_currentHomeowner == null) {
        throw Exception('No homeowner logged in');
      }

      await _client.from('homeowners').update({
        'notification_job_updates': jobUpdates,
        'notification_messages': messages,
        'notification_payments': payments,
        'notification_promotions': promotions,
      }).eq('id', _currentHomeowner!.id);

      // Update local state
      _currentHomeowner = Homeowner(
        id: _currentHomeowner!.id,
        profile: _currentHomeowner!.profile,
        phone: _currentHomeowner!.phone,
        address: _currentHomeowner!.address,
        preferredContactMethod: _currentHomeowner!.preferredContactMethod,
        emergencyContact: _currentHomeowner!.emergencyContact,
        createdAt: _currentHomeowner!.createdAt,
        notificationJobUpdates: jobUpdates,
        notificationMessages: messages,
        notificationPayments: payments,
        notificationPromotions: promotions,
      );

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateHomeownerContactPreference(String method) async {
    try {
      if (_currentHomeowner == null) {
        throw Exception('No homeowner logged in');
      }

      await _client.from('homeowners').update({
        'preferred_contact_method': method,
      }).eq('id', _currentHomeowner!.id);

      // Update local state
      _currentHomeowner = Homeowner(
        id: _currentHomeowner!.id,
        profile: _currentHomeowner!.profile,
        phone: _currentHomeowner!.phone,
        address: _currentHomeowner!.address,
        preferredContactMethod: method,
        emergencyContact: _currentHomeowner!.emergencyContact,
        createdAt: _currentHomeowner!.createdAt,
        notificationJobUpdates: _currentHomeowner!.notificationJobUpdates,
        notificationMessages: _currentHomeowner!.notificationMessages,
        notificationPayments: _currentHomeowner!.notificationPayments,
        notificationPromotions: _currentHomeowner!.notificationPromotions,
      );

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateHomeownerPersonalInfo({
    required String name,
    required String phone,
    required String emergencyContact,
  }) async {
    try {
      if (_currentHomeowner == null) {
        throw Exception('No homeowner logged in');
      }

      // Update profile name
      await _client.from('profiles').update({
        'name': name,
      }).eq('id', _currentProfile!.id);

      // Update homeowner phone and emergency contact
      await _client.from('homeowners').update({
        'phone': phone,
        'emergency_contact': emergencyContact,
      }).eq('id', _currentHomeowner!.id);

      // Update local profile state
      _currentProfile = profile_models.Profile(
        id: _currentProfile!.id,
        email: _currentProfile!.email,
        userType: _currentProfile!.userType,
        name: name,
        createdAt: _currentProfile!.createdAt,
      );

      // Update local homeowner state
      _currentHomeowner = Homeowner(
        id: _currentHomeowner!.id,
        profile: _currentProfile!,
        phone: phone,
        address: _currentHomeowner!.address,
        preferredContactMethod: _currentHomeowner!.preferredContactMethod,
        emergencyContact: emergencyContact,
        createdAt: _currentHomeowner!.createdAt,
        notificationJobUpdates: _currentHomeowner!.notificationJobUpdates,
        notificationMessages: _currentHomeowner!.notificationMessages,
        notificationPayments: _currentHomeowner!.notificationPayments,
        notificationPromotions: _currentHomeowner!.notificationPromotions,
      );

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateHomeownerAddress(String address) async {
    try {
      if (_currentHomeowner == null) {
        throw Exception('No homeowner logged in');
      }

      await _client.from('homeowners').update({
        'address': address,
      }).eq('id', _currentHomeowner!.id);

      // Update local state
      _currentHomeowner = Homeowner(
        id: _currentHomeowner!.id,
        profile: _currentHomeowner!.profile,
        phone: _currentHomeowner!.phone,
        address: address,
        preferredContactMethod: _currentHomeowner!.preferredContactMethod,
        emergencyContact: _currentHomeowner!.emergencyContact,
        createdAt: _currentHomeowner!.createdAt,
        notificationJobUpdates: _currentHomeowner!.notificationJobUpdates,
        notificationMessages: _currentHomeowner!.notificationMessages,
        notificationPayments: _currentHomeowner!.notificationPayments,
        notificationPromotions: _currentHomeowner!.notificationPromotions,
      );

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  String getCurrentHomeownerId() {
    if (_currentHomeowner == null) {
      throw Exception('No homeowner is currently logged in');
    }
    return _currentHomeowner!.id;
  }

  Future<void> bookAppointment({
    required String professionalId,
    required String homeownerId,
    required String slotId,
    required String description,
  }) async {
    LoggerService.info('Booking appointment');
    LoggerService.debug('Booking details:\n'
        'Professional ID: $professionalId\n'
        'Homeowner ID: $homeownerId\n'
        'Slot ID: $slotId\n'
        'Description: $description');

    try {
      // First, update the slot status to booked
      final slotResponse = await _client
          .from('schedule_slots')
          .update({
            'status': schedule.ScheduleSlot.STATUS_BOOKED,
          })
          .eq('id', slotId)
          .eq('status', schedule.ScheduleSlot.STATUS_AVAILABLE)
          .select()
          .single();

      LoggerService.debug('Updated slot: $slotResponse');

      // Get the professional's hourly rate and services
      final professionalResponse = await _client
          .from('professionals')
          .select('hourly_rate, services')
          .eq('id', professionalId)
          .single();

      final hourlyRate = professionalResponse['hourly_rate'] as num;
      final services = professionalResponse['services'] as List<dynamic>;

      // Use service price if available, otherwise use hourly rate
      double price = hourlyRate.toDouble();
      if (services.isNotEmpty) {
        // Find matching service based on description
        final matchingService = services.firstWhere(
          (service) => description
              .toLowerCase()
              .contains(service['title'].toString().toLowerCase()),
          orElse: () => null,
        );
        if (matchingService != null) {
          price = (matchingService['price'] as num).toDouble();
        }
      }

      // Ensure minimum price
      price = price <= 0 ? 20.0 : price;

      // Then, create a job for this appointment
      final jobResponse = await _client
          .from('jobs')
          .insert({
            'title': 'Service Appointment',
            'description': description,
            'status': 'PENDING',
            'date': DateTime.now().toIso8601String(),
            'professional_id': professionalId,
            'homeowner_id': homeownerId,
            'created_at': DateTime.now().toIso8601String(),
            'payment_status': 'payment_pending',
            'verification_status': 'verification_pending',
            'price': price,
          })
          .select()
          .single();

      LoggerService.debug('Created job: $jobResponse');

      // Finally, link the job to the slot
      await _client.from('schedule_slots').update({
        'job_id': jobResponse['id'],
      }).eq('id', slotId);

      LoggerService.info('Successfully booked appointment');
    } catch (e) {
      LoggerService.error(
        'Failed to book appointment: ${e.toString()}',
      );
      throw Exception('Failed to book appointment: ${e.toString()}');
    }
  }

  Future<Service?> getServiceById(String serviceId) async {
    try {
      // Try to get from cache first
      return await _withCache<Service?>('service_$serviceId', () async {
        final response = await _client
            .from('services')
            .select()
            .eq('id', serviceId)
            .maybeSingle();

        if (response == null) {
          LoggerService.debug('Service not found with ID: $serviceId');
          return null;
        }

        return Service.fromJson(response);
      });
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get service by ID', e, stackTrace);
      return null;
    }
  }

  @override
  void dispose() {
    LoggerService.debug('Disposing DatabaseProvider');
    super.dispose();
  }

  Future<Job> createJobRequest({
    required String title,
    required String description,
    required DateTime scheduledDate,
    double? price,
    double? locationLat,
    double? locationLng,
    double? radiusKm,
    String? professionalId,
    String requestType = Job.REQUEST_TYPE_DIRECT,
  }) async {
    try {
      LoggerService.debug('Starting createJobRequest with params:');
      LoggerService.debug('Title: $title');
      LoggerService.debug('Description: $description');
      LoggerService.debug('Scheduled Date: $scheduledDate');
      LoggerService.debug('Professional ID: $professionalId');
      LoggerService.debug('Price: $price');
      LoggerService.debug('Location: ($locationLat, $locationLng)');
      LoggerService.debug('Radius: $radiusKm km');
      LoggerService.debug('Request Type: $requestType');

      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');
      LoggerService.debug('Current user ID: ${user.id}');

      // First get the homeowner ID
      LoggerService.debug('Fetching homeowner ID for user ${user.id}');
      final homeownerResponse = await _client
          .from('homeowners')
          .select('id')
          .eq('profile_id', user.id)
          .single();

      final homeownerId = homeownerResponse['id'] as String;
      LoggerService.debug('Homeowner ID: $homeownerId');

      // Create the job request with all required fields
      final jobData = {
        'title': title,
        'description': description,
        'status': Job.STATUS_AWAITING_ACCEPTANCE,
        'date': scheduledDate.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'homeowner_id': homeownerId,
        'professional_id': professionalId,
        'price': price ?? 0.0,
        'request_type': requestType,
        if (locationLat != null) 'location_lat': locationLat,
        if (locationLng != null) 'location_lng': locationLng,
        if (radiusKm != null) 'radius_km': radiusKm,
        if (requestType == Job.REQUEST_TYPE_BROADCAST)
          'expires_at':
              DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      };

      LoggerService.debug('Creating job with data: $jobData');

      // Insert the job and return the full job data including related records
      final response = await _client.from('jobs').insert(jobData).select('''
        *,
        homeowner:homeowners (
          id,
          profile_id,
          phone,
          address,
          preferred_contact_method,
          emergency_contact,
          created_at,
          profile:profiles (
            id,
            email,
            user_type,
            name,
            created_at,
            last_login_at
          )
        ),
        professional:professionals (
          id,
          profile_id,
          profile_image,
          phone,
          license_number,
          years_of_experience,
          hourly_rate,
          rating,
          jobs_completed,
          is_available,
          is_verified,
          services,
          specialties,
          payment_info,
          notification_preferences,
          latitude,
          longitude,
          profile:profiles (
            id,
            name,
            email,
            user_type,
            created_at,
            last_login_at
          )
        )
      ''').single();

      final job = Job.fromJson(response);
      LoggerService.debug('Created job with ID: ${job.id}');
      return job;
    } catch (e, stackTrace) {
      LoggerService.error('Error creating job request', e, stackTrace);
      rethrow;
    }
  }

  Stream<Job?> streamJobUpdates(String jobId) {
    return _client
        .from('jobs')
        .stream(primaryKey: ['id'])
        .eq('id', jobId)
        .map((event) => event.isEmpty ? null : Job.fromJson(event.first));
  }

  Future<void> acceptJobRequest(String jobId, {double? proposedPrice}) async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to accept job request');
      }

      final updateData = {
        'status': 'scheduled',
        if (proposedPrice != null) 'price': proposedPrice,
        'verification_details': {
          'accepted_at': DateTime.now().toIso8601String(),
          'accepted_price': proposedPrice,
        },
      };

      await _client.from('jobs').update(updateData).eq('id', jobId);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to accept job request', e, stackTrace);
      rethrow;
    }
  }

  Future<void> declineJobRequest(String jobId, {String? reason}) async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception('User must be authenticated to decline job request');
      }

      final updateData = {
        'status': 'cancelled',
        'verification_details': {
          'declined_at': DateTime.now().toIso8601String(),
          'decline_reason': reason,
        },
      };

      await _client.from('jobs').update(updateData).eq('id', jobId);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to decline job request', e, stackTrace);
      rethrow;
    }
  }

  Future<void> startJob(String jobId) async {
    try {
      await _client.from('jobs').update({
        'status': Job.STATUS_STARTED,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', jobId);
    } catch (e) {
      LoggerService.error('Error starting job: $e');
      rethrow;
    }
  }

  Future<void> completeJob(String jobId) async {
    try {
      await _client.from('jobs').update({
        'status': Job.STATUS_COMPLETED,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', jobId);
    } catch (e) {
      LoggerService.error('Error completing job: $e');
      rethrow;
    }
  }

  Future<void> cancelJob(String jobId) async {
    try {
      await _client.from('jobs').update({
        'status': Job.STATUS_CANCELLED,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', jobId);
    } catch (e) {
      LoggerService.error('Error cancelling job: $e');
      rethrow;
    }
  }

  Future<List<Job>> getPendingJobs() async {
    try {
      final response = await _client
          .from('jobs')
          .select()
          .eq('status', Job.STATUS_AWAITING_ACCEPTANCE)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((job) => Job.fromJson(job))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting pending jobs: $e');
      rethrow;
    }
  }

  Stream<List<Job>> streamNearbyJobRequests() {
    if (!_authProvider.isAuthenticated) {
      throw Exception('User must be authenticated to stream job requests');
    }

    LoggerService.debug('Starting streamNearbyJobRequests');
    final professional = _professionals.firstWhere(
      (e) => e.profile.id == _currentProfile!.id,
      orElse: () => throw Exception('Professional not found'),
    );
    LoggerService.debug(
        'Found professional: ${professional.profile.name} with hourly rate: ${professional.hourlyRate}');

    final now = DateTime.now().toIso8601String();
    return _client
        .from('jobs')
        .stream(primaryKey: ['id'])
        .eq('status', Job.STATUS_AWAITING_ACCEPTANCE)
        .map((data) {
          LoggerService.debug('Received ${data.length} jobs from stream');
          return data.map((json) => json['id'] as String).toList();
        })
        .asyncMap((jobIds) async {
          if (jobIds.isEmpty) {
            LoggerService.debug('No jobs found in stream');
            return <Job>[];
          }

          LoggerService.debug('Found job IDs: ${jobIds.join(', ')}');
          // Fetch full job data for each job
          final fullJobsResponse = await _client.from('jobs').select('''
                *,
                homeowner:homeowners (
                  id,
                  profile_id,
                  phone,
                  address,
                  preferred_contact_method,
                  emergency_contact,
                  created_at,
                  profile:profiles (
                    id,
                    name,
                    email,
                    user_type,
                    created_at,
                    last_login_at
                  )
                ),
                professional:professionals (
                  id,
                  profile_id,
                  profile_image,
                  phone,
                  license_number,
                  years_of_experience,
                  hourly_rate,
                  rating,
                  jobs_completed,
                  is_available,
                  is_verified,
                  services,
                  specialties,
                  payment_info,
                  notification_preferences,
                  latitude,
                  longitude,
                  profile:profiles (
                    id,
                    name,
                    email,
                    user_type,
                    created_at,
                    last_login_at
                  )
                )
              ''').inFilter('id', jobIds);

          LoggerService.debug('Fetched full job data');
          final List<Map<String, dynamic>> response = fullJobsResponse;
          final jobs = response.map((json) => Job.fromJson(json)).where((job) {
            LoggerService.debug('Checking job ${job.id}:');
            // Filter expired jobs
            if (job.expiresAt?.isBefore(DateTime.now()) ?? true) {
              LoggerService.debug('Job ${job.id} skipped: Job is expired');
              return false;
            }
            if (job.locationLat == null || job.locationLng == null) {
              LoggerService.debug(
                  'Job ${job.id} skipped: Missing location data');
              return false;
            }

            if (professional.location == null) {
              LoggerService.debug(
                  'Job ${job.id} skipped: Professional location not set');
              return false;
            }

            final distance = calculateDistance(
              professional.location!.latitude,
              professional.location!.longitude,
              job.locationLat!,
              job.locationLng!,
            );

            LoggerService.debug('Job ${job.id} checks:\n'
                '- Distance: ${distance}km (limit: ${job.radiusKm}km)\n'
                '- Price: ${job.price} (min: ${professional.hourlyRate})\n'
                '- Professional available: ${professional.isAvailable}\n'
                '- Professional verified: ${professional.isVerified}');

            final isWithinRadius =
                job.radiusKm != null && distance <= job.radiusKm!;
            final hasSufficientPrice = job.price >= professional.hourlyRate;
            final isAvailable = professional.isAvailable;
            final isVerified = professional.isVerified;

            if (!isWithinRadius) {
              LoggerService.debug(
                  'Job ${job.id} skipped: Distance ${distance}km > radius ${job.radiusKm}km');
              return false;
            }
            if (!hasSufficientPrice) {
              LoggerService.debug(
                  'Job ${job.id} skipped: Price ${job.price} < hourly rate ${professional.hourlyRate}');
              return false;
            }
            if (!isAvailable) {
              LoggerService.debug(
                  'Job ${job.id} skipped: Professional not available');
              return false;
            }
            if (!isVerified) {
              LoggerService.debug(
                  'Job ${job.id} skipped: Professional not verified');
              return false;
            }

            LoggerService.debug('Job ${job.id} accepted: All checks passed');
            return true;
          }).toList();

          LoggerService.debug('Returning ${jobs.length} filtered jobs');
          return jobs;
        });
  }

  Future<List<Professional>> getProfessionals({
    String? searchQuery,
    List<String>? specialties,
    double? minRating,
    double? maxPrice,
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final query = _client.from('professionals').select('''
        *,
        hourly_rate::float as hourly_rate,
        profile:profiles (
          id,
          email,
          user_type,
          name,
          created_at
        )
      ''').eq('is_verified', true);

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query.filter('profile.name', 'ilike', '%$searchQuery%');
      }

      if (specialties != null && specialties.isNotEmpty) {
        query.filter('specialties', 'cs', specialties);
      }

      if (minRating != null) {
        query.filter('rating', 'gte', minRating);
      }

      if (maxPrice != null) {
        query.filter('hourly_rate', 'lte', maxPrice);
      }

      final response = await query
          .range(offset, offset + limit - 1)
          .order('rating', ascending: false);

      return response.map((data) => Professional.fromJson(data)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get professionals', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProfessionalsBySpecialty(String specialty) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client
          .from('professionals')
          .select('''
            *,
            hourly_rate::float as hourly_rate,
            profile:profiles (
              id,
              email,
              user_type,
              name,
              created_at
            )
          ''')
          .contains('specialties', [specialty])
          .eq('is_verified', true)
          .order('rating', ascending: false);

      _professionals = response
          .map<Professional>((json) => Professional.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error loading professionals by specialty: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    try {
      if (status == Job.STATUS_SCHEDULED) {
        await _client.from('jobs').update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', jobId);
      } else if (status == Job.STATUS_STARTED) {
        await _client.from('jobs').update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', jobId);
      } else if (status == Job.STATUS_COMPLETED) {
        await _client.from('jobs').update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', jobId);
      } else if (status == Job.STATUS_CANCELLED) {
        await _client.from('jobs').update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', jobId);
      }
    } catch (e) {
      LoggerService.error('Error updating job status: $e');
      rethrow;
    }
  }

  Future<List<Job>> getJobsByStatus(String status) async {
    try {
      final response = await _client
          .from('jobs')
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((job) => Job.fromJson(job))
          .toList();
    } catch (e) {
      LoggerService.error('Error getting jobs by status: $e');
      rethrow;
    }
  }

  Future<List<category_model.Category>> getCategories() async {
    try {
      final response = await _client.from('categories').select().order('name');

      return (response as List<dynamic>)
          .map((json) => category_model.Category.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get categories', e, stackTrace);
      rethrow;
    }
  }

  Future<List<CategoryService>> getServicesByCategory(String categoryId) async {
    try {
      final response = await _client
          .from('services')
          .select()
          .filter('category_id', 'eq', categoryId)
          .filter('deleted_at', 'is', null)
          .order('name');

      return (response as List<dynamic>)
          .map((json) => CategoryService.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      LoggerService.error('Failed to get services by category', e);
      rethrow;
    }
  }

  Future<category_model.Category> getCategoryById(String categoryId) async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('id', categoryId)
          .single();

      return category_model.Category.fromJson(response);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get category by ID', e, stackTrace);
      rethrow;
    }
  }

  String getCurrentProfessionalId() {
    if (_currentProfile == null ||
        _currentProfile!.userType != profile_models.UserType.professional) {
      throw Exception('No professional is currently logged in');
    }

    final professional = _professionals.firstWhere(
      (e) => e.profile.id == _currentProfile!.id,
      orElse: () => throw Exception('Professional profile not found'),
    );

    return professional.id;
  }

  Future<ApiResponse<Service>> getService(String id) async {
    try {
      final response =
          await _client.from('services').select().eq('id', id).single();

      return ApiResponse.success(Service.fromJson(response));
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<List<ServiceCategory>> loadServiceCategories() async {
    try {
      final response = await _client
          .from('service_categories')
          .select()
          .filter('deleted_at', 'is', null)
          .order('name');

      return (response as List)
          .map((json) => ServiceCategory.fromJson(json))
          .toList();
    } catch (e) {
      LoggerService.error('Error loading service categories', e);
      rethrow;
    }
  }

  Future<int> countNearbyProfessionals({
    required String serviceId,
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    try {
      final response = await _client.rpc(
        'count_nearby_professionals',
        params: {
          'service_id': serviceId,
          'lat': lat,
          'lng': lng,
          'radius_km': radiusKm,
        },
      );
      return response as int;
    } catch (e) {
      throw Exception('Failed to count nearby professionals: $e');
    }
  }

  Future<void> createBroadcastJob({
    required String title,
    required String description,
    required String serviceId,
    required double hours,
    required double pricePerHour,
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    try {
      final homeowner = currentHomeowner;
      if (homeowner == null) {
        throw Exception('No homeowner profile found');
      }

      await _client.from('jobs').insert({
        'title': title,
        'description': description,
        'status': 'awaiting_acceptance',
        'date': DateTime.now().toIso8601String(),
        'homeowner_id': homeowner.id,
        'price': pricePerHour * hours,
        'location_lat': lat,
        'location_lng': lng,
        'radius_km': radiusKm,
        'request_type': 'broadcast',
        'service_id': serviceId,
        'payment_status': 'payment_pending',
        'verification_status': 'verification_pending',
      });
    } catch (e) {
      throw Exception('Failed to create broadcast job: $e');
    }
  }

  Future<void> updateHomeownerLocation(double lat, double lng) async {
    try {
      if (_currentHomeowner == null) {
        throw Exception('No homeowner logged in');
      }

      await _client.from('homeowners').update({
        'location_lat': lat,
        'location_lng': lng,
      }).eq('id', _currentHomeowner!.id);

      // Update local state
      _currentHomeowner = _currentHomeowner!.copyWith(
        locationLat: lat,
        locationLng: lng,
      );

      notifyListeners();
    } catch (e) {
      LoggerService.error('Error updating homeowner location: $e');
      rethrow;
    }
  }
}
