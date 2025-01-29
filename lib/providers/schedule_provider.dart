import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../core/services/logger_service.dart';
import '../models/job_model.dart';
import '../models/schedule_slot_model.dart';
import '../models/reschedule_request_model.dart';
import 'auth_provider.dart';

class ScheduleProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  late final SupabaseClient _client;
  bool _isLoading = false;
  String? _error;
  List<Job> _appointments = [];
  List<ScheduleSlot> _scheduleSlots = [];
  List<RescheduleRequest> _rescheduleRequests = [];

  ScheduleProvider(this._authProvider) {
    _client = SupabaseConfig.client;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Job> get appointments => _appointments;
  List<ScheduleSlot> get scheduleSlots => _scheduleSlots;

  List<RescheduleRequest> get pendingRescheduleRequests => _rescheduleRequests
      .where((request) =>
          request.status == RescheduleRequest.STATUS_AWAITING_ACCEPTANCE)
      .toList();

  List<RescheduleRequest> get acceptedRescheduleRequests => _rescheduleRequests
      .where((request) => request.status == RescheduleRequest.STATUS_SCHEDULED)
      .toList();

  List<RescheduleRequest> get declinedRescheduleRequests => _rescheduleRequests
      .where((request) => request.status == RescheduleRequest.STATUS_CANCELLED)
      .toList();

  Future<void> loadAppointments({DateTime? date}) async {
    if (!_authProvider.isAuthenticated) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final professionalId = _authProvider.userId;
      if (professionalId == null) {
        throw Exception('No professional ID available');
      }

      LoggerService.debug(
          'Loading appointments for professional: $professionalId');
      if (date != null) {
        LoggerService.debug('Filtering by date: ${date.toIso8601String()}');
      }

      // Build the query
      final query = _client
          .from('jobs')
          .select('''
            *,
            homeowner:homeowners!jobs_homeowner_id_fkey (
              *,
              profile:profiles (*)
            ),
            service:services (*)
          ''')
          .eq('professional_id', professionalId)
          .inFilter('status', [Job.STATUS_SCHEDULED, Job.STATUS_STARTED]);

      // Add date filter if provided
      if (date != null) {
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));
        query.gte('date', startOfDay.toIso8601String());
        query.lt('date', endOfDay.toIso8601String());
      }

      // Order by date and time
      query.order('date', ascending: true);

      final response = await query;
      _appointments = response.map<Job>((job) => Job.fromJson(job)).toList();

      notifyListeners();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load appointments', e, stackTrace);
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadScheduleSlots({
    required String professionalId,
    required DateTime date,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('schedule_slots')
          .select()
          .eq('professional_id', professionalId)
          .eq('date', date.toIso8601String().split('T')[0]);

      _scheduleSlots = response
          .map<ScheduleSlot>((json) => ScheduleSlot.fromJson(json))
          .toList();

      notifyListeners();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load schedule slots', e, stackTrace);
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRescheduleRequests() async {
    if (!_authProvider.isAuthenticated) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final professionalId = _authProvider.userId;
      if (professionalId == null) {
        throw Exception('No professional ID available');
      }

      final response = await _client
          .from('reschedule_requests')
          .select('*, job:jobs(id, homeowner_id, professional_id)')
          .eq('job->professional_id', professionalId);

      _rescheduleRequests = response
          .map<RescheduleRequest>((json) => RescheduleRequest.fromJson(json))
          .toList();

      notifyListeners();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load reschedule requests', e, stackTrace);
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> respondToRescheduleRequest({
    required String requestId,
    required String status,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _client
          .from('reschedule_requests')
          .update({'status': status}).eq('id', requestId);

      await loadRescheduleRequests();
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to respond to reschedule request', e, stackTrace);
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> proposeNewTime({
    required String requestId,
    required DateTime newDate,
    required String newTime,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _client.from('reschedule_requests').update({
        'proposed_date': newDate.toIso8601String().split('T')[0],
        'proposed_time': newTime,
      }).eq('id', requestId);

      await loadRescheduleRequests();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to propose new time', e, stackTrace);
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Color getAppointmentColor(String status) {
    switch (status) {
      case Job.STATUS_SCHEDULED:
        return const Color(0xFFFFE0E6); // Light pink
      case Job.STATUS_STARTED:
        return const Color(0xFFFFF3CD); // Light amber
      case Job.STATUS_COMPLETED:
        return const Color(0xFFD1E7DD); // Light green
      default:
        return const Color(0xFFE9ECEF); // Light gray
    }
  }
}
