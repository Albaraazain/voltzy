import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job_model.dart';
import '../core/services/logger_service.dart';
import '../core/config/supabase_config.dart';
import '../providers/database_provider.dart';

class JobStatusUpdateException implements Exception {
  final String code;
  final String message;

  JobStatusUpdateException(this.code, this.message);

  @override
  String toString() => message;
}

class JobProvider extends ChangeNotifier {
  final SupabaseClient _client = SupabaseConfig.client;
  final DatabaseProvider _databaseProvider;
  List<Job> _jobs = [];
  bool _isLoading = false;
  String? _error;
  RealtimeChannel? _jobStatusChannel;

  // TODO: Add real-time job status updates (Requires: Supabase realtime subscription)
  // TODO: Add job matching algorithm (Requires: AI/ML service integration)
  // TODO: Add job scheduling system (Requires: Calendar service)
  // TODO: Add emergency job handling (Requires: Emergency response system)
  // TODO: Add job progress tracking (Requires: Progress tracking system)
  // TODO: Add job chat/messaging system (Requires: Chat service)
  // TODO: Add job location tracking (Requires: Location service)
  // TODO: Add job cost estimation (Requires: Pricing engine)
  // TODO: Add job materials management (Requires: Inventory system)
  // TODO: Add job review system (Requires: Review service)
  // TODO: Add dispute resolution system (Requires: Support system)

  JobProvider(this._databaseProvider) {
    _initializeRealtime();
  }

  void _initializeRealtime() {
    _jobStatusChannel = _client
        .channel('public:jobs')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'jobs',
          callback: (payload) => _handleJobStatusChange(payload),
        )
        .subscribe();
  }

  void _handleJobStatusChange(PostgresChangePayload payload) {
    try {
      final jobId = payload.newRecord['id'] as String;
      final newStatus = payload.newRecord['status'] as String;
      final oldStatus = payload.oldRecord['status'] as String?;

      LoggerService.debug(
          'Job status changed - ID: $jobId, Old: $oldStatus, New: $newStatus');

      if (_jobs.isNotEmpty) {
        final index = _jobs.indexWhere((job) => job.id == jobId);
        if (index != -1) {
          // Update local state with new job data
          _jobs[index] = Job.fromJson(payload.newRecord);
          notifyListeners();
        }
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error handling job status change', e, stackTrace);
    }
  }

  @override
  void dispose() {
    _jobStatusChannel?.unsubscribe();
    super.dispose();
  }

  List<Job> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Job> getJobsByStatus(String status) {
    if (_jobs.isEmpty) return [];
    return _jobs.where((job) => job.status == status).toList();
  }

  List<Job> getJobsByPaymentStatus(String paymentStatus) {
    if (_jobs.isEmpty) return [];
    return _jobs.where((job) => job.paymentStatus == paymentStatus).toList();
  }

  List<Job> getJobsByVerificationStatus(String verificationStatus) {
    if (_jobs.isEmpty) return [];
    return _jobs
        .where((job) => job.verificationStatus == verificationStatus)
        .toList();
  }

  Future<void> loadJobs(String? status) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      LoggerService.debug('🔄 Starting loadJobs with status: $status');

      final currentProfessional = _databaseProvider.currentProfessional;
      LoggerService.debug(
          '👤 Current professional: ${currentProfessional?.profile?.name ?? 'None'} (${currentProfessional?.id})');
      LoggerService.debug(
          '📍 Professional location: ${currentProfessional?.locationLat}, ${currentProfessional?.locationLng}');

      final currentProfessionalId = currentProfessional?.id;
      LoggerService.debug('🆔 Current professional ID: $currentProfessionalId');

      var query = _client.from('jobs').select('''
        *,
        service:services (*),
        homeowner:homeowners!jobs_homeowner_id_fkey (
          *,
          profile:profiles!homeowners_id_fkey (*)
        ),
        job_professional_requests (
          professional:professionals (
            *,
            profile:profiles (*)
          )
        )
      ''');

      LoggerService.debug('🔍 Building query for status: $status');

      // For professionals, show relevant jobs based on status
      if (status == Job.STATUS_AWAITING_ACCEPTANCE) {
        LoggerService.debug('📋 Loading pending/awaiting acceptance jobs');
        // For job requests, show all awaiting jobs that match their services
        query = query
            .eq('status', Job.STATUS_AWAITING_ACCEPTANCE)
            .filter('professional_id', 'is', null); // Show unassigned jobs only

        LoggerService.debug(
            '🔍 Query filters: status=${Job.STATUS_AWAITING_ACCEPTANCE}, professional_id=null');
      } else if (status == Job.STATUS_SCHEDULED) {
        LoggerService.debug('📅 Loading scheduled/accepted jobs');
        // For scheduled jobs, show only assigned jobs
        if (currentProfessionalId != null) {
          query = query
              .eq('status', Job.STATUS_SCHEDULED)
              .eq('professional_id', currentProfessionalId);

          LoggerService.debug(
              '🔍 Query filters: status=${Job.STATUS_SCHEDULED}, professional_id=$currentProfessionalId');
        }
      } else if (status != null && status != 'all') {
        LoggerService.debug('🔍 Loading jobs with specific status: $status');
        query = query.eq('status', status);
      }

      final response = await query;
      LoggerService.debug('📊 Raw database response: $response');
      LoggerService.debug('📊 Number of jobs returned: ${response.length}');

      final jobs = response.map((row) {
        final job = Job.fromJson(row);
        LoggerService.debug('📋 Processing job: ${job.id}');
        LoggerService.debug('  - Title: ${job.title}');
        LoggerService.debug('  - Status: ${job.status}');
        LoggerService.debug('  - Professional ID: ${job.professionalId}');
        LoggerService.debug(
            '  - Location: ${job.locationLat}, ${job.locationLng}');
        return job;
      }).toList();

      LoggerService.debug('✅ Returning ${jobs.length} jobs');
      _jobs = jobs;
    } catch (e, stackTrace) {
      _error = e.toString();
      LoggerService.error('❌ Error loading jobs', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Radius of the earth in km
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  Future<Job> createJob({
    required String title,
    required String description,
    required double price,
    String? professionalId,
  }) async {
    try {
      final response = await _client
          .from('jobs')
          .insert({
            'title': title,
            'description': description,
            'status': Job.STATUS_AWAITING_ACCEPTANCE,
            'date': DateTime.now().toIso8601String(),
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
            'professional_id': professionalId,
            'price': price,
            'payment_status': Job.PAYMENT_STATUS_PENDING,
            'verification_status': Job.VERIFICATION_STATUS_PENDING,
          })
          .select()
          .single();

      final newJob = Job.fromJson(response);
      _jobs.add(newJob);
      notifyListeners();
      return newJob;
    } catch (e) {
      LoggerService.error('Error creating job', e);
      rethrow;
    }
  }

  Future<void> updateJobStatus(String jobId, String newStatus) async {
    try {
      final response = await _client
          .from('jobs')
          .update({
            'status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', jobId)
          .select()
          .single();

      final updatedJob = Job.fromJson(response);
      final index = _jobs.indexWhere((job) => job.id == jobId);
      if (index != -1) {
        _jobs[index] = updatedJob;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating job status: $e');
      rethrow;
    }
  }

  Future<void> updatePaymentStatus(String jobId, String newStatus) async {
    try {
      final response = await _client
          .from('jobs')
          .update({
            'payment_status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', jobId)
          .select()
          .single();

      final updatedJob = Job.fromJson(response);
      final index = _jobs.indexWhere((job) => job.id == jobId);
      if (index != -1) {
        _jobs[index] = updatedJob;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating payment status: $e');
      rethrow;
    }
  }

  Future<void> updateVerificationStatus(String jobId, String newStatus) async {
    try {
      final response = await _client
          .from('jobs')
          .update({
            'verification_status': newStatus,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', jobId)
          .select()
          .single();

      final updatedJob = Job.fromJson(response);
      final index = _jobs.indexWhere((job) => job.id == jobId);
      if (index != -1) {
        _jobs[index] = updatedJob;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating verification status: $e');
      rethrow;
    }
  }

  Future<void> assignProfessional(String jobId, String professionalId) async {
    try {
      final response = await _client
          .from('jobs')
          .update({
            'professional_id': professionalId,
            'status': Job.STATUS_SCHEDULED,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', jobId)
          .select()
          .single();

      final updatedJob = Job.fromJson(response);
      final index = _jobs.indexWhere((job) => job.id == jobId);
      if (index != -1) {
        _jobs[index] = updatedJob;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error assigning professional: $e');
      rethrow;
    }
  }

  Future<void> cancelJob(String jobId) async {
    await updateJobStatus(jobId, Job.STATUS_CANCELLED);
  }

  // Helper method to get jobs by type
  List<Job> getJobsByType(String type, String professionalId) {
    if (_jobs.isEmpty) return [];

    LoggerService.debug('Getting jobs for type: $type');
    return _jobs.where((job) {
      if (type == 'new') {
        // Show awaiting acceptance jobs that are either unassigned or assigned to this professional
        final isAwaiting = job.status == Job.STATUS_AWAITING_ACCEPTANCE;
        final isUnassigned = job.professionalId == null;
        final isAssignedToMe = job.professionalId == professionalId;

        LoggerService.debug(
            'Filtering job ${job.id} - status: ${job.status}, professionalId: ${job.professionalId}, isAwaiting: $isAwaiting, isUnassigned: $isUnassigned, isAssignedToMe: $isAssignedToMe');

        return isAwaiting && (isUnassigned || isAssignedToMe);
      } else {
        // Show started jobs assigned to this professional
        final isStarted = job.status == Job.STATUS_STARTED;
        final isAssignedToMe = job.professionalId == professionalId;

        LoggerService.debug(
            'Filtering job ${job.id} - status: ${job.status}, professionalId: ${job.professionalId}, isStarted: $isStarted, isAssignedToMe: $isAssignedToMe');

        return isStarted && isAssignedToMe;
      }
    }).toList();
  }

  Future<void> startJob(String jobId) async {
    await updateJobStatus(jobId, Job.STATUS_STARTED);
  }

  Future<void> completeJob(String jobId) async {
    await updateJobStatus(jobId, Job.STATUS_COMPLETED);
  }
}
