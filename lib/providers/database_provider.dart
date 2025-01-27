import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart' hide Category;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/logger_service.dart';
import '../models/profile_model.dart' as profile_models;
import '../models/professional_model.dart';
import '../models/homeowner_model.dart';
import '../models/job_model.dart';
import '../models/base_service_model.dart';
import '../models/review_model.dart';
import '../models/payment_info_model.dart';
import '../repositories/professional_repository.dart';
import '../repositories/homeowner_repository.dart';
import '../repositories/service_repository.dart';
import 'auth_provider.dart';
import '../models/category_model.dart';
import '../core/utils/api_response.dart';
import '../models/service_category_model.dart';
import '../core/config/supabase_config.dart';

class DatabaseProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  late final SupabaseClient _client;
  late final ProfessionalRepository _professionalRepo;
  late final HomeownerRepository _homeownerRepo;
  late final ServiceRepository _serviceRepo;

  bool _isLoading = false;
  profile_models.Profile? _currentProfile;
  Professional? _currentProfessional;
  List<Professional> _professionals = [];
  Homeowner? _currentHomeowner;
  bool _isInitialized = false;
  String? _error;

  DatabaseProvider(this._authProvider) {
    _client = SupabaseConfig.client;
    _professionalRepo = ProfessionalRepository(_client);
    _homeownerRepo = HomeownerRepository(_client);
    _serviceRepo = ServiceRepository(_client);
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
  Professional? get currentProfessional => _currentProfessional;

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
      _error = null;
      notifyListeners();

      final userId = _authProvider.userId;
      if (userId == null) {
        LoggerService.debug('No user ID available');
        return;
      }

      // Load profile first
      try {
        final profileResponse =
            await _client.from('profiles').select().eq('id', userId).single();

        _currentProfile = profile_models.Profile.fromJson(profileResponse);
        LoggerService.debug(
            'Current profile type: ${_currentProfile?.userType}');

        // Load role-specific data based on user type
        if (_currentProfile?.userType == profile_models.UserType.professional) {
          await _loadProfessionalData();
        } else if (_currentProfile?.userType ==
            profile_models.UserType.homeowner) {
          await _loadHomeownerData();
          // For homeowners, we load all verified professionals
          await loadProfessionals();
        }
      } catch (e, stackTrace) {
        LoggerService.error('Failed to load profile data', e, stackTrace);
        _error = 'Failed to load profile data: ${e.toString()}';
        rethrow;
      }

      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadProfessionalData() async {
    try {
      LoggerService.debug('🔄 Loading professional data...');

      if (_currentProfile?.id == null) {
        throw Exception('No profile ID available');
      }

      _currentProfessional =
          await _professionalRepo.getCurrentProfessional(_currentProfile!.id);

      if (_currentProfessional != null) {
        LoggerService.debug('✅ Professional data loaded successfully');
        LoggerService.debug(
            'Services count: ${_currentProfessional!.services.length}');
      } else {
        LoggerService.warning('⚠️ No professional data found');
      }

      notifyListeners();
    } catch (e, stackTrace) {
      LoggerService.error('❌ Failed to load professional data', e, stackTrace);
      _error = 'Failed to load professional data: ${e.toString()}';
      rethrow;
    }
  }

  Future<void> _loadHomeownerData() async {
    try {
      _currentHomeowner = await _homeownerRepo.getCurrentHomeowner(
        _currentProfile!.id,
        _currentProfile!,
      );
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load homeowner data', e, stackTrace);
      rethrow;
    }
  }

  Future<void> loadProfessionals() async {
    try {
      _professionals = await _professionalRepo.getAllProfessionals();
      notifyListeners();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load professionals list', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Professional>> findProfessionalsWithinRadius(
      double lat, double lng, double radiusKm) async {
    return _professionalRepo.getNearbyProfessionals(
      latitude: lat,
      longitude: lng,
      radiusKm: radiusKm,
    );
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
          *,
          profile:profiles (*)
        ),
        homeowner:homeowners (
          *,
          profile:profiles (*)
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

      final response = await query;
      return response.map((json) => Job.fromJson(json)).toList();
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

  Future<void> updateProfessional(Professional? professional) async {
    try {
      if (!_authProvider.isAuthenticated) {
        throw Exception(
            'User must be authenticated to update professional profile');
      }

      final professionalId = professional?.id;
      if (professionalId == null) {
        throw Exception('Professional ID is required for update');
      }

      final data = <String, dynamic>{};

      // Only add non-null values to the update data
      if (professional?.name != null) data['name'] = professional!.name;
      if (professional?.email != null) data['email'] = professional!.email;
      if (professional?.phone != null) data['phone'] = professional!.phone;
      if (professional?.profileImage != null) {
        data['profile_image'] = professional!.profileImage;
      }
      if (professional?.bio != null) data['bio'] = professional!.bio;
      if (professional?.hourlyRate != null) {
        data['hourly_rate'] = professional!.hourlyRate;
      }
      if (professional?.isVerified != null) {
        data['is_verified'] = professional!.isVerified;
      }
      if (professional?.location != null) {
        data['location'] = professional!.location;
      }
      if (professional?.paymentInfo != null) {
        final paymentInfo = professional!.paymentInfo;
        if (paymentInfo is Map<String, dynamic>) {
          data['payment_info'] = paymentInfo;
        }
      }
      if (professional?.createdAt != null) {
        data['created_at'] = professional!.createdAt;
      }
      if (professional?.updatedAt != null) {
        data['updated_at'] = professional!.updatedAt;
      }
      if (professional?.rating != null) data['rating'] = professional!.rating;
      if (professional?.reviewCount != null) {
        data['review_count'] = professional!.reviewCount;
      }
      if (professional?.specialties != null) {
        data['specialties'] = professional!.specialties;
      }
      if (professional?.isAvailable != null) {
        data['is_available'] = professional!.isAvailable;
      }
      if (professional?.licenseNumber != null) {
        data['license_number'] = professional!.licenseNumber;
      }
      if (professional?.yearsOfExperience != null) {
        data['years_of_experience'] = professional!.yearsOfExperience;
      }
      if (professional?.notificationPreferences != null) {
        data['notification_preferences'] =
            professional!.notificationPreferences;
      }
      if (professional?.locationLat != null) {
        data['location_lat'] = professional!.locationLat;
      }
      if (professional?.locationLng != null) {
        data['location_lng'] = professional!.locationLng;
      }
      if (professional?.jobsCompleted != null) {
        data['jobs_completed'] = professional!.jobsCompleted;
      }

      await _client.from('professionals').update(data).eq('id', professionalId);
      await loadProfessionals();
    } catch (e, stackTrace) {
      LoggerService.error('Error updating professional', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateProfessionalLocation(double lat, double lng) async {
    try {
      if (_currentProfile == null) {
        throw Exception('No user logged in');
      }

      await _professionalRepo.updateProfessionalLocation(
          _currentProfile!.id, lat, lng);
      await refreshProfessionalData();
    } catch (e) {
      LoggerService.error('Failed to update professional location', e);
      rethrow;
    }
  }

  Future<void> updateProfessionalAvailability(
      String professionalId, bool isAvailable) async {
    try {
      await _professionalRepo.updateProfessionalAvailability(
          professionalId, isAvailable);
      await refreshProfessionalData();
    } catch (e) {
      LoggerService.error('Failed to update professional availability', e);
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

  Future<List<BaseService>> getAllServices() async {
    try {
      final response = await _client
          .from('services')
          .select()
          .filter('deleted_at', 'is', null)
          .order('name');

      return response.map((row) => BaseService.fromJson(row)).toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load services', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Category>> getAllCategories() async {
    try {
      final response = await _client
          .from('service_categories')
          .select('*')
          .filter('deleted_at', 'is', null)
          .order('name');
      return (response as List<dynamic>)
          .map((json) => Category.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to fetch categories', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Category>> getServiceCategories() async {
    return getAllCategories();
  }

  Future<List<BaseService>> getBaseServicesByCategory(String categoryId) async {
    return _serviceRepo.getServicesByCategory(categoryId);
  }

  Future<List<BaseService>> getServicesByCategory(String categoryId) async {
    return _serviceRepo.getServicesByCategory(categoryId);
  }

  Future<BaseService?> getServiceById(String id) async {
    try {
      return await _serviceRepo.getBaseServiceById(id);
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load service', e, stackTrace);
      rethrow;
    }
  }

  Future<ServiceCategory?> getCategoryById(String id) async {
    try {
      return await _serviceRepo.getCategoryById(id);
    } catch (e) {
      LoggerService.error('Failed to get category', e);
      rethrow;
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
      (e) => e.profile?.id == _currentProfile?.id,
      orElse: () => throw Exception('Professional not found'),
    );
    LoggerService.debug(
        'Found professional: ${professional.profile?.name ?? 'Unknown'} with hourly rate: ${professional.hourlyRate}');

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

            if (professional.locationLat == null ||
                professional.locationLng == null) {
              LoggerService.debug(
                  'Job ${job.id} skipped: Professional location not set');
              return false;
            }

            final distance = _calculateDistance(
              professional.locationLat!,
              professional.locationLng!,
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
            final hasSufficientPrice =
                job.price >= (professional.hourlyRate ?? 0);
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

  Future<void> updateJobStatus(String jobId, String newStatus) async {
    try {
      if (!Job.VALID_STATUS_TRANSITIONS[newStatus]!.contains(newStatus)) {
        throw Exception('Invalid status transition');
      }

      await _client.from('jobs').update({
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', jobId);

      notifyListeners();
    } catch (e) {
      _error = 'Failed to update job status: $e';
      notifyListeners();
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

  String getCurrentProfessionalId() {
    if (_currentProfile == null ||
        _currentProfile!.userType != profile_models.UserType.professional) {
      throw Exception('No professional is currently logged in');
    }

    final professional = _professionals.firstWhere(
      (e) => e.profile?.id == _currentProfile?.id,
      orElse: () => throw Exception('Professional profile not found'),
    );

    return professional.id;
  }

  Future<ApiResponse<BaseService>> getService(String id) async {
    try {
      final service = await _serviceRepo.getBaseServiceById(id);
      if (service == null) {
        return ApiResponse.error('Service not found');
      }
      return ApiResponse.success(service);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<List<Category>> loadServiceCategories() async {
    try {
      final categories = await getServiceCategories();
      notifyListeners();
      return categories;
    } catch (e) {
      LoggerService.error('Failed to load service categories', e);
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

  Future<List<Map<String, dynamic>>> loadServicesByCategory(
      String categoryId) async {
    try {
      final response = await _client
          .from('services')
          .select()
          .eq('category_id', categoryId)
          .filter('deleted_at', 'is', null)
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error loading services: $e');
      rethrow;
    }
  }

  // Add this method to refresh professional data
  Future<void> refreshProfessionalData() async {
    try {
      if (_currentProfile?.id == null) {
        LoggerService.error(
            'Cannot refresh professional data: No profile ID available');
        return;
      }

      if (_currentProfile?.userType != profile_models.UserType.professional) {
        LoggerService.error(
            'Cannot refresh professional data: Current user is not a professional');
        return;
      }

      await _loadProfessionalData();
      notifyListeners();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to refresh professional data', e, stackTrace);
      rethrow;
    }
  }

  Future<Professional?> getCurrentProfessional() async {
    if (!_authProvider.isAuthenticated) return null;

    final user = _authProvider.user;
    if (user == null) return null;

    return _professionalRepo.getCurrentProfessional(user.id);
  }

  Future<List<Professional>> getAllProfessionals() async {
    return _professionalRepo.getAllProfessionals();
  }

  Future<List<Professional>> searchProfessionals(String query) async {
    return _professionalRepo.searchProfessionals(query);
  }

  Future<List<Professional>> getNearbyProfessionals({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? categoryId,
  }) async {
    return _professionalRepo.getNearbyProfessionals(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      categoryId: categoryId,
    );
  }

  Future<void> updateProfessionalProfile({
    required String professionalId,
    String? bio,
    String? phoneNumber,
    String? licenseNumber,
    int? yearsOfExperience,
    List<String>? specialties,
    double? hourlyRate,
    bool? isAvailable,
  }) async {
    await _professionalRepo.updateProfessionalProfile(
      professionalId,
      bio: bio,
      phoneNumber: phoneNumber,
      licenseNumber: licenseNumber,
      yearsOfExperience: yearsOfExperience,
      specialties: specialties,
      hourlyRate: hourlyRate,
      isAvailable: isAvailable,
    );
    await refreshProfessionalData();
  }

  Future<void> addProfessionalService(
      String professionalId, String serviceId, double price) async {
    await _professionalRepo.addProfessionalService(
        professionalId, serviceId, price);
    await refreshProfessionalData();
  }

  Future<void> removeProfessionalService(
      String professionalId, String serviceId) async {
    await _professionalRepo.removeProfessionalService(
        professionalId, serviceId);
    await refreshProfessionalData();
  }

  Future<List<Professional>> getTopRatedProfessionals({int limit = 10}) async {
    return _professionalRepo.getTopRatedProfessionals(limit: limit);
  }

  Future<void> updateHomeownerAddress(String address) async {
    if (_currentHomeowner == null || _currentProfile == null) {
      throw Exception('No homeowner data available');
    }

    try {
      await _client
          .from('homeowners')
          .update({'address': address}).eq('id', _currentHomeowner!.id);

      _currentHomeowner = _currentHomeowner!.copyWith(address: address);
      notifyListeners();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update homeowner address', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateHomeownerContactPreference(String contactMethod) async {
    if (_currentHomeowner == null) {
      throw Exception('No homeowner data available');
    }

    try {
      await _client.from('homeowners').update({
        'preferred_contact_method': contactMethod,
      }).eq('id', _currentHomeowner!.id);

      // Update local state
      _currentHomeowner = _currentHomeowner!.copyWith(
        preferredContactMethod: contactMethod,
      );

      notifyListeners();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update contact preference', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateHomeownerNotificationPreferences({
    required bool jobUpdates,
    required bool messages,
    required bool payments,
    required bool promotions,
  }) async {
    if (_currentHomeowner == null) {
      throw Exception('No homeowner data available');
    }

    try {
      await _client.from('homeowners').update({
        'notification_job_updates': jobUpdates,
        'notification_messages': messages,
        'notification_payments': payments,
        'notification_promotions': promotions,
      }).eq('id', _currentHomeowner!.id);

      // Update local state
      _currentHomeowner = _currentHomeowner!.copyWith(
        notificationJobUpdates: jobUpdates,
        notificationMessages: messages,
        notificationPayments: payments,
        notificationPromotions: promotions,
      );

      notifyListeners();
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to update notification preferences', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateHomeownerPersonalInfo({
    required String name,
    required String phone,
    required String emergencyContact,
  }) async {
    if (_currentHomeowner == null || _currentProfile == null) {
      throw Exception('No homeowner data available');
    }

    try {
      // Update profile name
      await _client
          .from('profiles')
          .update({'name': name}).eq('id', _currentProfile!.id);

      // Update homeowner info
      await _client.from('homeowners').update({
        'phone': phone,
        'emergency_contact': emergencyContact,
      }).eq('id', _currentHomeowner!.id);

      // Update local state
      _currentProfile = _currentProfile!.copyWith(name: name);
      _currentHomeowner = _currentHomeowner!.copyWith(
        phone: phone,
        emergencyContact: emergencyContact,
      );

      notifyListeners();
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to update homeowner personal info', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updatePaymentInfo(PaymentInfo paymentInfo) async {
    if (_currentProfessional == null) {
      throw Exception('No professional data available');
    }

    try {
      await _client.from('payment_info').upsert({
        'id': paymentInfo.id,
        'user_id': paymentInfo.userId,
        'account_name': paymentInfo.accountName,
        'account_number': paymentInfo.accountNumber,
        'bank_name': paymentInfo.bankName,
        'routing_number': paymentInfo.routingNumber,
        'account_type': paymentInfo.accountType,
        'is_verified': paymentInfo.isVerified,
        'created_at': paymentInfo.createdAt?.toIso8601String(),
        'updated_at': paymentInfo.updatedAt?.toIso8601String() ??
            DateTime.now().toIso8601String(),
      });

      // Update local state
      _currentProfessional = _currentProfessional!.copyWith(
        paymentInfo: {
          'accountName': paymentInfo.accountName,
          'accountNumber': paymentInfo.accountNumber,
          'bankName': paymentInfo.bankName,
          'routingNumber': paymentInfo.routingNumber,
          'accountType': paymentInfo.accountType,
        },
      );

      notifyListeners();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update payment info', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Job>> getJobsForProfessional(String professionalId) async {
    try {
      final response = await _client
          .from('jobs')
          .select('*')
          .eq('professional_id', professionalId);

      return (response as List<dynamic>)
          .map((json) => Job.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to fetch jobs for professional', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Review>> getProfessionalReviews(String professionalId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('*')
          .eq('professional_id', professionalId);

      return (response as List<dynamic>)
          .map((json) => Review.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to fetch reviews for professional', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateProfessionalRating(
      String professionalId, double newRating) async {
    try {
      await _client
          .from('professionals')
          .update({'rating': newRating}).eq('id', professionalId);
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to update professional rating', e, stackTrace);
      rethrow;
    }
  }

  Future<List<Review>> getReviewsForProfessional(String professionalId) async {
    try {
      final response = await _client
          .from('reviews')
          .select()
          .eq('reviewee_id', professionalId)
          .order('created_at', ascending: false);

      return (response as List).map((data) => Review.fromJson(data)).toList();
    } catch (e) {
      _error = 'Failed to fetch reviews: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await _client
          .from('service_categories')
          .select()
          .filter('deleted_at', 'is', null)
          .order('name', ascending: true);

      return (response as List).map((data) => Category.fromJson(data)).toList();
    } catch (e) {
      _error = 'Failed to fetch categories: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateJobPaymentStatus(String jobId, String newStatus) async {
    try {
      await _client.from('jobs').update({
        'payment_status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', jobId);

      notifyListeners();
    } catch (e) {
      _error = 'Failed to update job payment status: $e';
      notifyListeners();
      rethrow;
    }
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Radius of the earth in km
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * asin(sqrt(a));
    return earthRadius * c; // Distance in km
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }
}
